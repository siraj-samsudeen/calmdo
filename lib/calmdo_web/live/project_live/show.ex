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
            row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}
          >
            <:col :let={{_id, task}} label="Title">{task.title}</:col>
            <:col :let={{_id, task}} label="Status">{task.status}</:col>
            <:col :let={{_id, task}} label="Due date">{task.due_date}</:col>
            <:col :let={{_id, task}} label="Hours">
              <.link navigate={~p"/activity_logs?task_id=#{task.id}"} class="link">
                {format_hours(total_hours(task))}
              </.link>
            </:col>
            <:action :let={{_id, task}}>
              <.link navigate={~p"/activity_logs/new?task_id=#{task.id}&project_id=#{@project.id}"}>
                Log Time
              </.link>
            </:action>
          </.table>
        </div>

        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold">Logs</h2>
            <.link navigate={~p"/activity_logs/new?project_id=#{@project.id}"} class="btn btn-sm">
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

    logs =
      Calmdo.ActivityLogs.list_activity_logs_for_project(socket.assigns.current_scope, project.id)

    {:ok,
     socket
     |> assign(:page_title, "Show Project")
     |> assign(:project, project)
     |> stream(:tasks_rows, tasks, reset: true)
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
        socket.assigns.project.id
      )

    {:noreply, stream(socket, :logs_rows, logs, reset: true)}
  end

  defp total_hours(task) do
    Enum.reduce(task.activity_logs || [], 0, fn al, acc ->
      (al.duration_in_hours || 0) + (acc + (al.duration_in_minutes || 0) / 60)
    end)
  end

  defp format_hours(value) when is_number(value) do
    value
    |> Kernel.+(0.0)
    |> Float.round(2)
    |> to_string()
  end
end
