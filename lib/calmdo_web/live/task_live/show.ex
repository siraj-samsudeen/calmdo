defmodule CalmdoWeb.TaskLive.Show do
  use CalmdoWeb, :live_view

  alias Calmdo.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Task {@task.id}
        <:subtitle>This is a task record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/tasks"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/tasks/#{@task}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit task
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@task.title}</:item>
        <:item title="Notes">{@task.notes}</:item>
        <:item title="Status">{@task.status}</:item>
        <:item title="Priority">{@task.priority}</:item>
        <:item title="Due date">{@task.due_date}</:item>
        <:item title="Hours Logged">
          <.link navigate={~p"/activity_logs?task_id=#{@task.id}"} class="link">
            {format_hours(total_hours(@task))}
          </.link>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Tasks.subscribe_tasks(socket.assigns.current_scope)
    end

    task =
      Tasks.get_task!(socket.assigns.current_scope, id)
      |> Calmdo.Repo.preload(:activity_logs)

    {:ok,
     socket
     |> assign(:page_title, "Show Task")
     |> assign(:task, task)}
  end

  @impl true
  def handle_info(
        {:updated, %Calmdo.Tasks.Task{id: id} = task},
        %{assigns: %{task: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :task, task)}
  end

  def handle_info(
        {:deleted, %Calmdo.Tasks.Task{id: id}},
        %{assigns: %{task: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current task was deleted.")
     |> push_navigate(to: ~p"/tasks")}
  end

  def handle_info({type, %Calmdo.Tasks.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
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
