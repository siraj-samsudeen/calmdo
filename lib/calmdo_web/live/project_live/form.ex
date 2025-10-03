defmodule CalmdoWeb.ProjectLive.Form do
  use CalmdoWeb, :live_view

  alias Calmdo.Tasks
  alias Calmdo.Tasks.Project

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage project records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="project-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:completed]} type="checkbox" label="Completed" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Project</.button>
          <.button navigate={return_path(@current_scope, @return_to, @project)}>Cancel</.button>
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
    project = Tasks.get_project!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, project)
    |> assign(:form, to_form(Tasks.change_project(socket.assigns.current_scope, project)))
  end

  defp apply_action(socket, :new, _params) do
    project = %Project{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, project)
    |> assign(:form, to_form(Tasks.change_project(socket.assigns.current_scope, project)))
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = Tasks.change_project(socket.assigns.current_scope, socket.assigns.project, project_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.live_action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Tasks.update_project(socket.assigns.current_scope, socket.assigns.project, project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, project)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Tasks.create_project(socket.assigns.current_scope, project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, project)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _project), do: ~p"/projects"
  defp return_path(_scope, "show", project), do: ~p"/projects/#{project}"
end
