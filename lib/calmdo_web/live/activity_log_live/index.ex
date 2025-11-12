defmodule CalmdoWeb.ActivityLogLive.Index do
  use CalmdoWeb, :live_view

  alias Calmdo.ActivityLogs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Activity logs
        <:actions>
          <.button variant="primary" navigate={~p"/activity_logs/new"}>
            <.icon name="hero-plus" /> New Activity log
          </.button>
        </:actions>
      </.header>

      <.table
        id="activity_logs"
        rows={@streams.activity_logs}
        row_click={fn {_id, activity_log} -> JS.navigate(~p"/activity_logs/#{activity_log}") end}
      >
        <:col :let={{_id, activity_log}} label="Project">
          {activity_log.project && activity_log.project.name}
        </:col>
        <:col :let={{_id, activity_log}} label="Task">
          {activity_log.task && activity_log.task.title}
        </:col>
        <:col :let={{_id, activity_log}} label="Duration in hours">
          {activity_log.duration_in_hours}
        </:col>
        <:col :let={{_id, activity_log}} label="Notes">
          <div class="prose prose-sm text-sm">
            {raw(Earmark.as_html!(activity_log.notes))}
          </div>
        </:col>
        <:action :let={{_id, activity_log}}>
          <div class="sr-only">
            <.link navigate={~p"/activity_logs/#{activity_log}"}>Show</.link>
          </div>
          <.link navigate={~p"/activity_logs/#{activity_log}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, activity_log}}>
          <.link
            phx-click={JS.push("delete", value: %{id: activity_log.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      ActivityLogs.subscribe_activity_logs(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, page_title(params))
     |> stream(:activity_logs, list_activity_logs(socket.assigns.current_scope, params))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity_log = ActivityLogs.get_activity_log!(socket.assigns.current_scope, id)
    {:ok, _} = ActivityLogs.delete_activity_log(socket.assigns.current_scope, activity_log)

    {:noreply, stream_delete(socket, :activity_logs, activity_log)}
  end

  @impl true
  def handle_info({type, %Calmdo.ActivityLogs.ActivityLog{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :activity_logs, list_activity_logs(socket.assigns.current_scope), reset: true)}
  end

  defp list_activity_logs(current_scope, params \\ %{}) do
    task_id = Map.get(params, "task_id")
    project_id = Map.get(params, "project_id")

    cond do
      task_id ->
        ActivityLogs.list_activity_logs(current_scope, task_id: String.to_integer(task_id))

      project_id ->
        ActivityLogs.list_activity_logs(current_scope,
          project_id: String.to_integer(project_id)
        )

      true ->
        ActivityLogs.list_activity_logs(current_scope)
    end
  end

  defp page_title(%{"task_id" => _}), do: "Activity logs for task"
  defp page_title(%{"project_id" => _}), do: "Activity logs for project"
  defp page_title(_), do: "Listing Activity logs"
end
