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

      <.form
        for={%{}}
        id="task-filters"
        phx-change="filter"
        class="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-3"
      >
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
        <p :if={@tasks_empty?} class="text-sm text-base-content/70">
          No tasks match the current filters.
        </p>
        <.table
          id="tasks"
          rows={@streams.tasks}
          row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}
        >
          <:col :let={{_id, task}} label="Title">{task.title}</:col>
          <:col :let={{_id, task}} label="Project">{task.project && task.project.name}</:col>
          <:col :let={{_id, task}} label="Assignee">{task.assignee && task.assignee.email}</:col>
          <:col :let={{_id, task}} label="Status">{format_status(task.status)}</:col>
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
          <:action :let={{_id, task}}>
            <div class="sr-only">
              <.link navigate={~p"/tasks/#{task}"}>Show</.link>
            </div>
            <.link navigate={~p"/tasks/#{task}/edit"}>Edit</.link>
          </:action>
          <:action :let={{id, task}}>
            <.link
              phx-click={JS.push("delete", value: %{id: task.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </:action>
        </.table>
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
      |> stream_configure(:tasks, dom_id: &"task-#{&1.id}")
      |> assign_tasks()

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(socket.assigns.current_scope, id)

    {:ok, _} = Tasks.delete_task(socket.assigns.current_scope, task)
    {:noreply, assign_tasks(socket)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    filters = %{
      status: Map.get(params, "status"),
      assignee_id: Map.get(params, "assignee_id")
    }

    {:noreply, socket |> assign(:filters, filters) |> assign_tasks()}
  end

  @impl true
  def handle_info({type, %Calmdo.Tasks.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, assign_tasks(socket)}
  end

  defp list_tasks(current_scope, filters) do
    filters = filters || %{status: nil, assignee_id: nil}

    status =
      case filters.status do
        nil ->
          nil

        "" ->
          nil

        value ->
          Map.get(
            %{
              "not_started" => :not_started,
              :not_started => :not_started,
              "started" => :started,
              :started => :started,
              "work_in_progress" => :work_in_progress,
              :work_in_progress => :work_in_progress,
              "completed" => :completed,
              :completed => :completed
            },
            value,
            nil
          )
      end

    assignee_id =
      case filters.assignee_id do
        nil -> nil
        "" -> nil
        id when is_integer(id) -> id
        id when is_binary(id) -> String.to_integer(id)
      end

    status =
      cond do
        status == :not_started -> nil
        true -> status
      end

    Tasks.list_tasks(current_scope, status: status, assignee_id: assignee_id)
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

  defp format_status(nil), do: "Not started"
  defp format_status(:work_in_progress), do: "Work In Progress"

  defp format_status(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp assign_tasks(socket) do
    tasks = list_tasks(socket.assigns.current_scope, socket.assigns.filters)

    socket
    |> assign(:tasks_empty?, tasks == [])
    |> stream(:tasks, tasks, reset: true)
  end
end
