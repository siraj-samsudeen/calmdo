defmodule CalmdoWeb.ProjectLive.Show do
  use CalmdoWeb, :live_view

  alias Calmdo.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@project.name}
        <:subtitle>Project overview with tasks and logs.</:subtitle>
        <:actions>
          <.button navigate={~p"/projects"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/projects/#{@project}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit project
          </.button>
        </:actions>
      </.header>

      <section class="space-y-6">
        <.list>
          <:item title="Name">{@project.name}</:item>
          <:item title="Completed">{to_string(@project.completed)}</:item>
        </.list>

        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold">Tasks</h2>
            <.link
              navigate={~p"/tasks/new?return_to=projects&project_id=#{@project.id}"}
              class="btn btn-sm"
            >
              <.icon name="hero-plus" /> New Task
            </.link>
          </div>

          <.table
            id="project-tasks"
            rows={@streams.tasks_rows}
            row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}/edit") end}
          >
            <:col :let={{_id, task}} label="Title">{task.title}</:col>
            <:col :let={{_id, task}} label="Status">{task.status}</:col>
            <:col :let={{_id, task}} label="Due date">{task.due_date}</:col>
            <:col :let={{_id, task}} label="Hours">
              <%= if total_hours(task) > 0 do %>
                <.link navigate={~p"/activity_logs?task_id=#{task.id}"} class="link">
                  {format_hours(total_hours(task))}
                </.link>
              <% else %>
                {format_hours(total_hours(task))}
              <% end %>
            </:col>
            <:action :let={{_id, task}}>
              <.link navigate={
                ~p"/activity_logs/new?return_to=projects&task_id=#{task.id}&project_id=#{@project.id}"
              }>
                Log Time
              </.link>
            </:action>
          </.table>
        </div>

        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold">Logs</h2>
            <.link
              navigate={~p"/activity_logs/new?return_to=projects&project_id=#{@project.id}"}
              class="btn btn-sm"
            >
              <.icon name="hero-plus" /> New Log
            </.link>
          </div>

          <.table
            id="project-logs"
            rows={@streams.logs_rows}
            row_click={fn {_id, log} -> JS.navigate(~p"/activity_logs/#{log}") end}
          >
            <:col :let={{_id, log}} label="Date">{log.date}</:col>
            <:col :let={{_id, log}} label="Task">{log.task && log.task.title}</:col>
            <:col :let={{_id, log}} label="Project">{log.project && log.project.name}</:col>
            <:col :let={{_id, log}} label="Duration">
              {((log.duration_in_hours || 0) + (log.duration_in_minutes || 0) / 60) |> Float.round(2)}
            </:col>
          </.table>

          <div class="text-center mt-4">
            <p class="text-sm text-gray-500 mb-2">
              Showing logs from the last {@days_back} days
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
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Tasks.subscribe_projects(socket.assigns.current_scope)
      Tasks.subscribe_tasks(socket.assigns.current_scope)
      Calmdo.ActivityLogs.subscribe_activity_logs(socket.assigns.current_scope)
    end

    project = Tasks.get_project!(socket.assigns.current_scope, id)
    tasks = Tasks.list_tasks_for_project(socket.assigns.current_scope, project.id)

    {:ok,
     socket
     |> assign(:page_title, "Show Project")
     |> assign(:project, project)
     |> assign(:days_back, 2)
     |> stream(:tasks_rows, tasks, reset: true)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    days_back = String.to_integer(params["days"] || "2")

    logs =
      Calmdo.ActivityLogs.list_activity_logs_for_project(
        socket.assigns.current_scope,
        socket.assigns.project.id,
        days_back
      )

    {:noreply,
     socket
     |> assign(:days_back, days_back)
     |> stream(:logs_rows, logs, reset: true)}
  end

  @impl true
  def handle_info(
        {:updated, %Calmdo.Tasks.Project{id: id} = project},
        %{assigns: %{project: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :project, project)}
  end

  def handle_info(
        {:deleted, %Calmdo.Tasks.Project{id: id}},
        %{assigns: %{project: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current project was deleted.")
     |> push_navigate(to: ~p"/projects")}
  end

  def handle_info({type, %Calmdo.Tasks.Project{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  def handle_info({type, %Calmdo.Tasks.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    tasks = Tasks.list_tasks_for_project(socket.assigns.current_scope, socket.assigns.project.id)
    {:noreply, stream(socket, :tasks_rows, tasks, reset: true)}
  end

  def handle_info({type, %Calmdo.ActivityLogs.ActivityLog{}}, socket)
      when type in [:created, :updated, :deleted] do
    logs =
      Calmdo.ActivityLogs.list_activity_logs_for_project(
        socket.assigns.current_scope,
        socket.assigns.project.id,
        socket.assigns.days_back
      )

    {:noreply, stream(socket, :logs_rows, logs, reset: true)}
  end

  @impl true
  def handle_event("load_more", _params, socket) do
    new_days = socket.assigns.days_back + 7

    {:noreply,
     socket
     |> push_patch(to: ~p"/projects/#{socket.assigns.project}?days=#{new_days}")}
  end

  defp total_hours(task) do
    # total_hours is calculated in the database query
    Map.get(task, :total_hours, 0) || 0
  end

  defp format_hours(value) when is_number(value) do
    value
    |> Kernel.+(0.0)
    |> Float.round(2)
    |> to_string()
  end
end
