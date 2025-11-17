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
          options={status_options(@statuses)}
          value={@filters.status}
          phx-debounce="300"
        />
        <.input
          name="assignee_id"
          type="select"
          label="Assignee"
          options={assignee_options(@assignees)}
          value={@filters.assignee_id}
          phx-debounce="300"
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

  defp status_options(statuses), do: [{"All", nil} | Enum.map(statuses, &{format_status(&1), &1})]

  defp assignee_options(assignees),
    do: [{"All", nil} | Enum.map(assignees, &{&1.email, &1.id})]

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
      |> assign(:statuses, Ecto.Enum.values(Calmdo.Tasks.Task, :status))
      |> assign(:assignees, Calmdo.Accounts.list_users())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = %{status: params["status"], assignee_id: params["assignee_id"]}
    tasks = Tasks.list_tasks(socket.assigns.current_scope, Map.to_list(filters))

    socket =
      socket
      |> assign(:filters, filters)
      |> assign(:tasks_empty?, tasks == [])
      |> stream(:tasks, tasks, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(socket.assigns.current_scope, id)

    {:ok, _} = Tasks.delete_task(socket.assigns.current_scope, task)
    {:noreply, stream_delete(socket, :tasks, task)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    cleaned_params =
      params
      |> Map.take(["status", "assignee_id"])
      |> Enum.reject(fn {_k, v} -> v in ["", nil] end)
      |> Enum.into(%{})

    to =
      if cleaned_params == %{}, do: ~p"/tasks", else: ~p"/tasks?#{cleaned_params}"

    {:noreply, socket |> push_patch(to: to)}
  end

  @impl true
  def handle_info({type, %Calmdo.Tasks.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :tasks, Tasks.list_tasks(socket.assigns.current_scope), reset: true)}
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

  defp format_status(nil), do: ""

  defp format_status(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
