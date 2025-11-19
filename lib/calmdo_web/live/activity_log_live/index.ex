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
          <.markdown text={activity_log.notes || ""} class="prose-sm text-sm" />
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

      <div class="text-center mt-8 pt-8 border-t border-gray-200">
        <p class="text-sm text-gray-500 mb-3">
          Showing activity from the last {@days_back} days
        </p>
        <button phx-click="load_more" class="btn btn-outline btn-sm">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
            />
          </svg>
          Load More (7 more days)
        </button>
      </div>
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
     |> assign(:page_title, page_title(params))}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    days_back = String.to_integer(params["days"] || "2")
    params_with_days = Map.put(params, "days", to_string(days_back))
    activity_logs = ActivityLogs.list_activity_logs(socket.assigns.current_scope, params_with_days)

    {:noreply,
     socket
     |> assign(:days_back, days_back)
     |> assign(:filter_params, Map.drop(params, ["days"]))
     |> stream(:activity_logs, activity_logs, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity_log = ActivityLogs.get_activity_log!(socket.assigns.current_scope, id)
    {:ok, _} = ActivityLogs.delete_activity_log(socket.assigns.current_scope, activity_log)

    {:noreply, stream_delete(socket, :activity_logs, activity_log)}
  end

  @impl true
  def handle_event("load_more", _params, socket) do
    new_days = socket.assigns.days_back + 7
    params = Map.put(socket.assigns.filter_params, "days", to_string(new_days))

    to =
      if params == %{"days" => to_string(new_days)},
        do: ~p"/activity_logs?days=#{new_days}",
        else: ~p"/activity_logs?#{params}"

    {:noreply, socket |> push_patch(to: to)}
  end

  @impl true
  def handle_info({type, %Calmdo.ActivityLogs.ActivityLog{}}, socket)
      when type in [:created, :updated, :deleted] do
    params = Map.put(socket.assigns.filter_params, "days", to_string(socket.assigns.days_back))

    {:noreply,
     stream(
       socket,
       :activity_logs,
       ActivityLogs.list_activity_logs(socket.assigns.current_scope, params),
       reset: true
     )}
  end

  defp page_title(%{"task_id" => _}), do: "Activity logs for task"
  defp page_title(%{"project_id" => _}), do: "Activity logs for project"
  defp page_title(_), do: "Listing Activity logs"
end
