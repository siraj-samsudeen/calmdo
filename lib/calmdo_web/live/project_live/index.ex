defmodule CalmdoWeb.ProjectLive.Index do
  use CalmdoWeb, :live_view

  alias Calmdo.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} no_wrapper no_padding>
      <.header>
        Listing Projects
        <:actions>
          <.button variant="primary" navigate={~p"/projects/new"}>
            <.icon name="hero-plus" /> New Project
          </.button>
        </:actions>
      </.header>

      <.table
        id="projects"
        rows={@streams.projects}
        row_click={fn {_id, project} -> JS.navigate(~p"/projects/#{project}") end}
      >
        <:col :let={{_id, project}} label="Name">{project.name}</:col>
        <:col :let={{_id, project}} label="Completed">{project.completed}</:col>
        <:action :let={{_id, project}}>
          <div class="sr-only">
            <.link navigate={~p"/projects/#{project}"}>Show</.link>
          </div>
          <.link navigate={~p"/projects/#{project}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, project}}>
          <.link
            phx-click={JS.push("delete", value: %{id: project.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Projects.subscribe_projects(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Projects")
     |> stream(:projects, list_projects(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(socket.assigns.current_scope, id)
    {:ok, _} = Projects.delete_project(socket.assigns.current_scope, project)

    {:noreply, stream_delete(socket, :projects, project)}
  end

  @impl true
  def handle_info({type, %Calmdo.Projects.Project{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :projects, list_projects(socket.assigns.current_scope), reset: true)}
  end

  defp list_projects(current_scope) do
    Projects.list_projects(current_scope)
  end
end
