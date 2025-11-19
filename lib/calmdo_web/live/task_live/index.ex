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
        <div class="overflow-x-auto">
          <table class="table w-full bg-base-100 text-base-content">
            <thead class="bg-slate-100 text-slate-600">
              <tr>
                <th class="w-12">
                  <input
                    type="checkbox"
                    class="checkbox checkbox-sm"
                    phx-click="toggle_all"
                    checked={@all_selected?}
                  />
                </th>
                <th>Title</th>
                <th>Project</th>
                <th>Assignee</th>
                <th>Status</th>
                <th>Priority</th>
                <th>Due date</th>
                <th>Hours</th>
                <th>
                  <span class="sr-only">Actions</span>
                </th>
              </tr>
            </thead>
            <tbody id="tasks" phx-update="stream">
              <tr
                :for={{id, task} <- @streams.tasks}
                id={id}
                class="border-b border-slate-100 last:border-b-0 even:bg-white odd:bg-slate-50"
              >
                <td>
                  <label class="cursor-pointer">
                    <input
                      type="checkbox"
                      class="checkbox checkbox-sm"
                      phx-click="toggle_task"
                      phx-value-id={task.id}
                      checked={task.id in @selected_task_ids}
                    />
                  </label>
                </td>
                <td
                  phx-click={JS.navigate(~p"/tasks/#{task}/edit")}
                  class="align-middle hover:cursor-pointer hover:text-[#2563eb]"
                >
                  {task.title}
                </td>
                <td
                  phx-click={JS.navigate(~p"/tasks/#{task}/edit")}
                  class="align-middle hover:cursor-pointer hover:text-[#2563eb]"
                >
                  {task.project && task.project.name}
                </td>
                <td
                  phx-click={JS.navigate(~p"/tasks/#{task}/edit")}
                  class="align-middle hover:cursor-pointer hover:text-[#2563eb]"
                >
                  {task.assignee && task.assignee.email}
                </td>
                <td
                  phx-click={JS.navigate(~p"/tasks/#{task}/edit")}
                  class="align-middle hover:cursor-pointer hover:text-[#2563eb]"
                >
                  {format_status(task.status)}
                </td>
                <td
                  phx-click={JS.navigate(~p"/tasks/#{task}/edit")}
                  class="align-middle hover:cursor-pointer hover:text-[#2563eb]"
                >
                  {task.priority}
                </td>
                <td
                  phx-click={JS.navigate(~p"/tasks/#{task}/edit")}
                  class="align-middle hover:cursor-pointer hover:text-[#2563eb]"
                >
                  {task.due_date}
                </td>
                <td
                  phx-click={JS.navigate(~p"/tasks/#{task}/edit")}
                  class="align-middle hover:cursor-pointer hover:text-[#2563eb]"
                >
                  <%= if total_hours(task) > 0 do %>
                    <.link navigate={~p"/activity_logs?task_id=#{task.id}"} class="link">
                      {format_hours(total_hours(task))}
                    </.link>
                  <% else %>
                    {format_hours(total_hours(task))}
                  <% end %>
                </td>
                <td class="w-0 font-semibold">
                  <.link navigate={log_time_path(task)} class="link link-primary">
                    Log Time
                  </.link>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <%!-- Bold Modern Bulk Edit Panel - Sticky at bottom --%>
        <div
          :if={@selected_task_ids != []}
          class="fixed bottom-0 left-0 right-0 bg-gradient-to-r from-primary/5 to-primary/10 border-t-2 border-primary/30 shadow-2xl z-50"
        >
          <.form for={%{}} phx-submit="apply_bulk_edit">
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
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold text-xs uppercase tracking-wide">
                      <.icon name="hero-folder" class="w-3 h-3 inline" /> Project
                    </span>
                  </label>
                  <select name="project_id" class="select select-bordered select-sm">
                    <option value="">No change</option>
                    <option :for={project <- @projects} value={project.id}>
                      {project.name}
                    </option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold text-xs uppercase tracking-wide">
                      <.icon name="hero-user" class="w-3 h-3 inline" /> Assignee
                    </span>
                  </label>
                  <select name="assignee_id" class="select select-bordered select-sm">
                    <option value="">No change</option>
                    <option :for={assignee <- @assignees} value={assignee.id}>
                      {assignee.email}
                    </option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold text-xs uppercase tracking-wide">
                      <.icon name="hero-flag" class="w-3 h-3 inline" /> Status
                    </span>
                  </label>
                  <select name="status" class="select select-bordered select-sm">
                    <option value="">No change</option>
                    <option value="started">Started</option>
                    <option value="work_in_progress">Work In Progress</option>
                    <option value="completed">Completed</option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold text-xs uppercase tracking-wide">
                      <.icon name="hero-signal" class="w-3 h-3 inline" /> Priority
                    </span>
                  </label>
                  <select name="priority" class="select select-bordered select-sm">
                    <option value="">No change</option>
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                  </select>
                </div>
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
                    <.icon name="hero-check" class="w-4 h-4" />
                    Apply Changes
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
      |> assign(:projects, Tasks.list_projects(socket.assigns.current_scope))
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
            |> put_flash(:info, "Successfully updated #{length(socket.assigns.selected_task_ids)} task(s)")
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

  defp parse_bulk_edit_param({"status", value}), do: {:status, String.to_existing_atom(value)}
  defp parse_bulk_edit_param({"priority", value}), do: {:priority, String.to_existing_atom(value)}

  defp parse_bulk_edit_param({"assignee_id", value}),
    do: {:assignee_id, String.to_integer(value)}

  defp parse_bulk_edit_param({"project_id", value}),
    do: {:project_id, String.to_integer(value)}

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
