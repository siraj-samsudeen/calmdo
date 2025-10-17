defmodule CalmdoWeb.TaskLive.Index do
  use CalmdoWeb, :live_view

  alias Calmdo.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Tasks
        <:actions>
          <.button variant="primary" navigate={~p"/tasks/new"}>
            <.icon name="hero-plus" /> New Task
          </.button>
        </:actions>
      </.header>

      <.form for={%{}} id="task-filters" phx-change="filter" class="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <.input
          name="status"
          type="select"
          label="Status"
          options={[{"All", ""} | Enum.map(@statuses, &{format_status(&1), &1})]}
          value={@filters.status}
        />
        <.input
          name="assignee_id"
          type="select"
          label="Assignee"
          options={[{"All", ""} | Enum.map(@assignees, &{&1.email, &1.id})]}
          value={@filters.assignee_id}
        />
      </.form>

      <div class="space-y-8">
        <div :if={@streams.tasks_started |> Enum.any?()}>
          <h2 class="mb-2 text-sm font-semibold">Started</h2>
          <.table id="tasks-started" rows={@streams.tasks_started} row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}>
            <:col :let={{_id, task}} label="Title">{task.title}</:col>
            <:col :let={{_id, task}} label="Project">{task.project && task.project.name}</:col>
            <:col :let={{_id, task}} label="Assignee">{task.assignee && task.assignee.email}</:col>
            <:col :let={{_id, task}} label="Priority">{task.priority}</:col>
            <:col :let={{_id, task}} label="Due date">{task.due_date}</:col>
            <:col :let={{_id, task}} label="Hours">
              <.link navigate={~p"/activity_logs?task_id=#{task.id}"} class="link">
                {format_hours(total_hours(task))}
              </.link>
            </:col>
            <:action :let={{_id, task}}>
              <.link navigate={log_time_path(task)}>Log Time</.link>
            </:action>
          </.table>
        </div>

        <div :if={@streams.tasks_work_in_progress |> Enum.any?()}>
          <h2 class="mb-2 text-sm font-semibold">Work In Progress</h2>
          <.table id="tasks-wip" rows={@streams.tasks_work_in_progress} row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}>
            <:col :let={{_id, task}} label="Title">{task.title}</:col>
            <:col :let={{_id, task}} label="Project">{task.project && task.project.name}</:col>
            <:col :let={{_id, task}} label="Assignee">{task.assignee && task.assignee.email}</:col>
            <:col :let={{_id, task}} label="Priority">{task.priority}</:col>
            <:col :let={{_id, task}} label="Due date">{task.due_date}</:col>
            <:col :let={{_id, task}} label="Hours">
              <.link navigate={~p"/activity_logs?task_id=#{task.id}"} class="link">
                {format_hours(total_hours(task))}
              </.link>
            </:col>
            <:action :let={{_id, task}}>
              <.link navigate={log_time_path(task)}>Log Time</.link>
            </:action>
          </.table>
        </div>

        <div :if={@streams.tasks_completed |> Enum.any?()}>
          <h2 class="mb-2 text-sm font-semibold">Completed</h2>
          <.table id="tasks-completed" rows={@streams.tasks_completed} row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}>
            <:col :let={{_id, task}} label="Title">{task.title}</:col>
            <:col :let={{_id, task}} label="Project">{task.project && task.project.name}</:col>
            <:col :let={{_id, task}} label="Assignee">{task.assignee && task.assignee.email}</:col>
            <:col :let={{_id, task}} label="Priority">{task.priority}</:col>
            <:col :let={{_id, task}} label="Due date">{task.due_date}</:col>
            <:col :let={{_id, task}} label="Hours">
              <.link navigate={~p"/activity_logs?task_id=#{task.id}"} class="link">
                {format_hours(total_hours(task))}
              </.link>
            </:col>
            <:action :let={{_id, task}}>
              <.link navigate={log_time_path(task)}>Log Time</.link>
            </:action>
          </.table>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp log_time_path(task) do
    if task.project_id do
      ~p"/activity_logs/new?task_id=#{task.id}&project_id=#{task.project_id}"
    else
      ~p"/activity_logs/new?task_id=#{task.id}"
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Tasks.subscribe_tasks(socket.assigns.current_scope)
    end

    socket =
      socket
      |> assign(:page_title, "Listing Tasks")
      |> assign(:statuses, Ecto.Enum.values(Calmdo.Tasks.Task, :status))
      |> assign(:assignees, Calmdo.Accounts.list_users())
      |> assign(:filters, %{status: nil, assignee_id: nil})
      |> assign_task_groups()

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(socket.assigns.current_scope, id)
    {:ok, _} = Tasks.delete_task(socket.assigns.current_scope, task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  @impl true
  def handle_info({type, %Calmdo.Tasks.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, assign_task_groups(socket)}
  end

  defp list_tasks(current_scope, filters \\ %{status: nil, assignee_id: nil}) do
    status = if is_nil(filters.status) or filters.status == "", do: nil, else: String.to_existing_atom(to_string(filters.status))

    assignee_id =
      case filters.assignee_id do
        nil -> nil
        "" -> nil
        id when is_integer(id) -> id
        id when is_binary(id) -> String.to_integer(id)
      end

    Tasks.list_tasks(current_scope, status: status, assignee_id: assignee_id)
  end

  defp total_hours(task) do
    Enum.reduce(task.activity_logs || [], 0, fn al, acc ->
      (al.duration_in_hours || 0) + (acc + ((al.duration_in_minutes || 0) / 60))
    end)
  end

  defp format_hours(value) when is_number(value) do
    value
    |> Float.round(2)
    |> to_string()
  end

  defp format_status(:work_in_progress), do: "Work In Progress"
  defp format_status(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  @impl true
  def handle_event("filter", params, socket) do
    filters = %{
      status: Map.get(params, "status"),
      assignee_id: Map.get(params, "assignee_id")
    }

    {:noreply, socket |> assign(:filters, filters) |> assign_task_groups()}
  end

  defp assign_task_groups(socket) do
    tasks = list_tasks(socket.assigns.current_scope, socket.assigns.filters)

    started = Enum.filter(tasks, &(&1.status == :started))
    wip = Enum.filter(tasks, &(&1.status == :work_in_progress))
    completed = Enum.filter(tasks, &(&1.status == :completed))

    socket
    |> stream(:tasks_started, started, reset: true)
    |> stream(:tasks_work_in_progress, wip, reset: true)
    |> stream(:tasks_completed, completed, reset: true)
  end
end
