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
        <.input field={@form[:duration_in_hours]} type="number" label="Duration in hours" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
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
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    activity_log = ActivityLogs.get_activity_log!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Activity log")
    |> assign(:activity_log, activity_log)
    |> assign(:form, to_form(ActivityLogs.change_activity_log(socket.assigns.current_scope, activity_log)))
  end

  defp apply_action(socket, :new, _params) do
    activity_log = %ActivityLog{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Activity log")
    |> assign(:activity_log, activity_log)
    |> assign(:form, to_form(ActivityLogs.change_activity_log(socket.assigns.current_scope, activity_log)))
  end

  @impl true
  def handle_event("validate", %{"activity_log" => activity_log_params}, socket) do
    changeset = ActivityLogs.change_activity_log(socket.assigns.current_scope, socket.assigns.activity_log, activity_log_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"activity_log" => activity_log_params}, socket) do
    save_activity_log(socket, socket.assigns.live_action, activity_log_params)
  end

  defp save_activity_log(socket, :edit, activity_log_params) do
    case ActivityLogs.update_activity_log(socket.assigns.current_scope, socket.assigns.activity_log, activity_log_params) do
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

  defp save_activity_log(socket, :new, activity_log_params) do
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
end
