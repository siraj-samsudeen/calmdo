defmodule CalmdoWeb.ActivityLogLive.Form do
  use CalmdoWeb, :live_view

  alias Calmdo.ActivityLogs
  alias Calmdo.ActivityLogs.ActivityLog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage activity_log records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="activity_log-form" phx-change="validate" phx-submit="save">
        <%!-- TODO: detect viewer timezone and seed a local date instead of UTC --%>
        <.input
          field={@form[:date]}
          type="date"
          label="Date"
          value={@form[:date].value || Date.utc_today()}
        />
        <.input
          field={@form[:project_id]}
          type="select"
          label="Project"
          prompt="Choose a project"
          options={@projects}
        />
        <.input
          field={@form[:task_id]}
          type="select"
          label="Task"
          prompt="Choose a task"
          options={@tasks}
          disabled={@creating_task?}
          phx-change="task_selected"
        />

        <div class="rounded-lg border border-slate-200 p-4">
          <div class="flex items-center justify-between">
            <h3 class="text-sm font-semibold">Create a new task instead</h3>
            <button type="button" class="btn btn-sm" phx-click="toggle_new_task">
              {if @creating_task?, do: "Cancel", else: "Create new task"}
            </button>
          </div>

          <div :if={@creating_task?} class="mt-3 space-y-3">
            <input type="hidden" name="creating_task" value="true" />
            <.input
              name="new_task[title]"
              type="text"
              label="New task title"
              value={Map.get(@new_task_params, "title") || ""}
            />
            <.input
              name="new_task[notes]"
              type="textarea"
              label="New task notes"
              value={Map.get(@new_task_params, "notes") || ""}
            />
          </div>
        </div>
        <.input field={@form[:duration_in_hours]} type="number" label="Duration in hours" />
        <.input field={@form[:duration_in_minutes]} type="number" label="Duration in minutes" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <.input field={@form[:billable]} type="checkbox" label="Billable" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Activity log</.button>
          <.button navigate={return_path(@current_scope, @return_to, @activity_log)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    projects = Calmdo.Tasks.list_projects(socket.assigns.current_scope)
    tasks = Calmdo.Tasks.list_tasks(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:creating_task?, false)
     |> assign(:new_task_params, %{})
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:projects, Enum.map(projects, &{&1.name, &1.id}))
     |> assign(:tasks, Enum.map(tasks, &{&1.title, &1.id}))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to("projects"), do: "projects"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    activity_log = ActivityLogs.get_activity_log!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Activity log")
    |> assign(:activity_log, activity_log)
    |> assign(
      :form,
      to_form(ActivityLogs.change_activity_log(socket.assigns.current_scope, activity_log))
    )
  end

  defp apply_action(socket, :new, params) do
    task_id = params["task_id"]
    project_id = params["project_id"]

    activity_log =
      if task_id do
        task = Calmdo.Tasks.get_task!(socket.assigns.current_scope, task_id)

        %ActivityLog{
          logged_by_id: socket.assigns.current_scope.user.id,
          task_id: task.id,
          project_id: task.project_id
        }
      else
        %ActivityLog{
          logged_by_id: socket.assigns.current_scope.user.id,
          # Use project_id from params if no task
          project_id: project_id
        }
      end

    socket
    |> assign(:page_title, "New Activity log")
    |> assign(:activity_log, activity_log)
    |> assign(
      :form,
      to_form(ActivityLogs.change_activity_log(socket.assigns.current_scope, activity_log))
    )
  end

  @impl true
  def handle_event("task_selected", %{"activity_log" => %{"task_id" => task_id}}, socket) do
    if task_id == "" do
      # If task is deselected, do not update project_id automatically
      {:noreply, socket}
    else
      task = Calmdo.Tasks.get_task!(socket.assigns.current_scope, task_id)

      updated_changeset =
        socket.assigns.form.source
        |> Ecto.Changeset.put_change(:project_id, task.project_id)

      {:noreply, assign(socket, form: to_form(updated_changeset))}
    end
  end

  def handle_event("validate", %{"activity_log" => activity_log_params} = params, socket) do
    new_task_params = Map.get(params, "new_task", socket.assigns.new_task_params) || %{}

    changeset =
      ActivityLogs.change_activity_log(
        socket.assigns.current_scope,
        socket.assigns.activity_log,
        activity_log_params
      )

    {:noreply,
     socket
     |> assign(:new_task_params, new_task_params)
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", params, socket) do
    %{"activity_log" => activity_log_params} = params
    new_task_params = Map.get(params, "new_task", %{}) || %{}

    socket = assign(socket, :new_task_params, new_task_params)

    save_activity_log(socket, socket.assigns.live_action, activity_log_params, new_task_params)
  end

  @impl true
  def handle_event("toggle_new_task", _params, socket) do
    creating_task? = !socket.assigns.creating_task?
    new_task_params = if creating_task?, do: socket.assigns.new_task_params, else: %{}

    {:noreply,
     socket
     |> assign(:creating_task?, creating_task?)
     |> assign(:new_task_params, new_task_params)}
  end

  defp save_activity_log(socket, :edit, activity_log_params, _new_task_params) do
    case ActivityLogs.update_activity_log(
           socket.assigns.current_scope,
           socket.assigns.activity_log,
           activity_log_params
         ) do
      {:ok, activity_log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity log updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, activity_log)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_activity_log(socket, :new, activity_log_params, new_task_params) do
    activity_log_params =
      activity_log_params
      |> blank_to_nil("task_id")
      |> blank_to_nil("project_id")

    activity_log_params =
      if socket.assigns.creating_task? do
        title =
          new_task_params
          |> Map.get("title", "")
          |> String.trim()

        notes = Map.get(new_task_params, "notes", "")

        if title == "" do
          send(self(), {:flash_error, "Enter a title for the new task"})
          activity_log_params
        else
          project_id = Map.get(activity_log_params, "project_id")

          {:ok, task} =
            Calmdo.Tasks.create_task(socket.assigns.current_scope, %{
              "title" => title,
              "notes" => notes,
              "project_id" => project_id
            })

          activity_log_params
          |> Map.put("task_id", task.id)
          |> Map.put("project_id", task.project_id)
        end
      else
        activity_log_params
      end

    case ActivityLogs.create_activity_log(socket.assigns.current_scope, activity_log_params) do
      {:ok, activity_log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity log created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, activity_log)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _activity_log), do: ~p"/activity_logs"
  defp return_path(_scope, "show", activity_log), do: ~p"/activity_logs/#{activity_log}"
  defp return_path(_scope, "projects", activity_log), do: ~p"/projects/#{activity_log.project_id}"

  defp blank_to_nil(map, key) when is_map(map) do
    case Map.get(map, key) do
      "" -> Map.put(map, key, nil)
      _ -> map
    end
  end

  @impl true
  def handle_info({:flash_error, msg}, socket) do
    {:noreply, put_flash(socket, :error, msg)}
  end
end
