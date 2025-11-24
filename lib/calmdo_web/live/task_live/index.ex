defmodule CalmdoWeb.TaskLive.Index do
  use CalmdoWeb, :live_view

  alias Calmdo.Projects
  alias Calmdo.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} no_wrapper no_padding>
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
          prompt="All"
          options={status_options(@statuses)}
          value={@filters.status}
          phx-debounce="300"
        />
        <.input
          name="assignee_id"
          type="select"
          label="Assignee"
          prompt="All"
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
          select?={true}
          all_selected?={@all_selected?}
          selected_ids={@selected_task_ids}
          select_all_click="toggle_all"
          row_select_click="toggle_task"
          row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}/edit") end}
        >
          <:col :let={{_id, task}} label="Title">{task.title}</:col>
          <:col :let={{_id, task}} label="Project">{task.project && task.project.name}</:col>
          <:col :let={{_id, task}} label="Assignee">
            {task.assignee && display_username(task.assignee)}
          </:col>
          <:col :let={{_id, task}} label="Status">{format_label(task.status)}</:col>
          <:col :let={{_id, task}} label="Priority">{format_label(task.priority)}</:col>
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
            <div class="sr-only">
              <.link navigate={~p"/tasks/#{task}/edit"}>Edit</.link>
            </div>
            <.link navigate={log_time_path(task)} class="link link-primary">Log Time</.link>
          </:action>
        </.table>

        <%!-- Bold Modern Bulk Edit Panel - Sticky at bottom --%>
        <div
          :if={@selected_task_ids != []}
          class="fixed bottom-0 left-0 lg:left-72 right-0 bg-base-100 border-t-2 border-primary/30 shadow-2xl z-50"
        >
          <.form for={%{}} id="task-bulk-edit" phx-submit="apply_bulk_edit">
            <div class="bg-primary text-primary-content px-4 py-2 flex items-center justify-between">
              <div class="flex items-center gap-2">
                <.icon name="hero-pencil-square" class="w-5 h-5" />
                <span class="font-semibold">Bulk Edit</span>
                <div class="badge badge-sm bg-primary-content text-primary font-bold">
                  {length(@selected_task_ids)} selected
                </div>
              </div>
              <button
                type="button"
                phx-click="cancel_bulk_edit"
                class="btn btn-ghost btn-xs text-primary-content hover:bg-primary-content/20"
              >
                <.icon name="hero-x-mark" class="w-4 h-4" />
              </button>
            </div>

            <div class="p-4">
              <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <.input
                  name="project_id"
                  type="select"
                  label="Project"
                  prompt="No change"
                  options={project_options(@projects)}
                  value={nil}
                />
                <.input
                  name="assignee_id"
                  type="select"
                  label="Assignee"
                  prompt="No change"
                  options={assignee_options(@assignees)}
                  value={nil}
                />
                <.input
                  name="status"
                  type="select"
                  label="Status"
                  prompt="No change"
                  options={status_options(@statuses)}
                  value={nil}
                />
                <.input
                  name="priority"
                  type="select"
                  label="Priority"
                  prompt="No change"
                  options={priority_options(@priorities)}
                  value={nil}
                />
              </div>

              <div class="flex gap-2 justify-between mt-4 pt-4 border-t border-base-300">
                <.button
                  type="button"
                  phx-click="bulk_delete"
                  data-confirm={"Are you sure you want to delete #{length(@selected_task_ids)} task(s)?"}
                  class="btn-sm btn-error gap-1"
                >
                  <.icon name="hero-trash" class="w-4 h-4" />
                  Delete {length(@selected_task_ids)} task(s)
                </.button>
                <div class="flex gap-2">
                  <.button type="submit" variant="primary" class="btn-sm gap-1">
                    <.icon name="hero-check" class="w-4 h-4" /> Apply Changes
                  </.button>
                  <.button type="button" phx-click="cancel_bulk_edit" class="btn-sm btn-ghost">
                    Cancel
                  </.button>
                </div>
              </div>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Tasks.subscribe_tasks(socket.assigns.current_scope)
    end

    socket =
      socket
      |> assign(:statuses, Ecto.Enum.values(Calmdo.Tasks.Task, :status))
      |> assign(:priorities, Ecto.Enum.values(Calmdo.Tasks.Task, :priority))
      |> assign(:assignees, Calmdo.Accounts.list_users())
      |> assign(:projects, Projects.list_projects(socket.assigns.current_scope))
      |> assign(:selected_task_ids, [])
      |> assign(:all_selected?, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tasks = Tasks.list_tasks(socket.assigns.current_scope, params)

    socket =
      socket
      |> assign(:filters, %{status: params["status"], assignee_id: params["assignee_id"]})
      |> assign(:tasks_empty?, tasks == [])
      |> assign(:selected_task_ids, [])
      |> assign(:all_selected?, false)
      |> stream(:tasks, tasks, reset: true)

    {:noreply, socket}
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
  def handle_event("toggle_task", %{"id" => id}, socket) do
    id = String.to_integer(id)
    selected = socket.assigns.selected_task_ids

    updated_selected =
      if id in selected do
        List.delete(selected, id)
      else
        [id | selected]
      end

    {:noreply, assign(socket, selected_task_ids: updated_selected, all_selected?: false)}
  end

  @impl true
  def handle_event("toggle_all", _params, socket) do
    all_selected? = socket.assigns.all_selected?

    updated_selected =
      if all_selected? do
        []
      else
        # Get all task IDs from the stream
        Tasks.list_tasks(socket.assigns.current_scope, socket.assigns.filters)
        |> Enum.map(& &1.id)
      end

    {:noreply, assign(socket, selected_task_ids: updated_selected, all_selected?: !all_selected?)}
  end

  @impl true
  def handle_event("cancel_bulk_edit", _params, socket) do
    {:noreply, assign(socket, selected_task_ids: [], all_selected?: false)}
  end

  @impl true
  def handle_event("bulk_delete", _params, socket) do
    case Tasks.bulk_delete_tasks(
           socket.assigns.current_scope,
           socket.assigns.selected_task_ids
         ) do
      {:ok, count} ->
        socket =
          socket
          |> put_flash(:info, "Successfully deleted #{count} task(s)")
          |> assign(selected_task_ids: [], all_selected?: false)

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to delete tasks")}
    end
  end

  @impl true
  def handle_event("apply_bulk_edit", params, socket) do
    # Build updates map from non-empty form values
    updates =
      params
      |> Map.take(["status", "priority", "assignee_id", "project_id"])
      |> Enum.reject(fn {_k, v} -> v == "" end)
      |> Enum.map(&parse_bulk_edit_param/1)
      |> Enum.into(%{})

    if updates == %{} do
      {:noreply, put_flash(socket, :error, "Please select at least one field to update")}
    else
      # Apply bulk update
      case Tasks.bulk_update_tasks(
             socket.assigns.current_scope,
             socket.assigns.selected_task_ids,
             updates
           ) do
        {:ok, _count} ->
          socket =
            socket
            |> put_flash(
              :info,
              "Successfully updated #{length(socket.assigns.selected_task_ids)} task(s)"
            )
            |> assign(selected_task_ids: [], all_selected?: false)

          {:noreply, socket}

        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, "Failed to update tasks")}
      end
    end
  end

  @impl true
  def handle_info({type, %Calmdo.Tasks.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :tasks, Tasks.list_tasks(socket.assigns.current_scope), reset: true)}
  end

  defp parse_bulk_edit_param({"status", value}),
    do: {:status, String.to_existing_atom(value)}

  defp parse_bulk_edit_param({"priority", value}),
    do: {:priority, String.to_existing_atom(value)}

  defp parse_bulk_edit_param({"assignee_id", value}),
    do: {:assignee_id, String.to_integer(value)}

  defp parse_bulk_edit_param({"project_id", value}),
    do: {:project_id, String.to_integer(value)}

  defp total_hours(task),
    do: Map.get(task, :total_hours, 0) || 0

  defp format_hours(value) when is_number(value) do
    value
    |> Kernel.+(0.0)
    |> Float.round(2)
    |> to_string()
  end

  defp format_label(nil), do: ""

  defp format_label(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp options_from_atoms(list),
    do: Enum.map(list, &{format_label(&1), &1})

  defp status_options(statuses),
    do: options_from_atoms(statuses)

  defp priority_options(priorities),
    do: options_from_atoms(priorities)

  defp assignee_options(assignees),
    do: Enum.map(assignees, &{display_username(&1), &1.id})

  defp project_options(projects),
    do: Enum.map(projects, &{&1.name, &1.id})

  defp log_time_path(%{project_id: nil, id: id}),
    do: ~p"/activity_logs/new?return_to=tasks&task_id=#{id}"

  defp log_time_path(%{project_id: project_id, id: id}),
    do: ~p"/activity_logs/new?return_to=tasks&task_id=#{id}&project_id=#{project_id}"

  defp display_username(%{email: email}) when is_binary(email),
    do: email |> String.split("@") |> List.first()

  defp display_username(_), do: ""
end
