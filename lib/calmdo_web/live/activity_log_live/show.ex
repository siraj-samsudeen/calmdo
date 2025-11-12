defmodule CalmdoWeb.ActivityLogLive.Show do
  use CalmdoWeb, :live_view

  alias Calmdo.ActivityLogs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Activity log {@activity_log.id}
        <:subtitle>This is a activity_log record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/activity_logs"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/activity_logs/#{@activity_log}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit activity_log
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Duration in hours">{@activity_log.duration_in_hours}</:item>
        <:item title="Notes">
          <div class="prose">
            {raw(Earmark.as_html!(@activity_log.notes))}
          </div>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      ActivityLogs.subscribe_activity_logs(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Activity log")
     |> assign(:activity_log, ActivityLogs.get_activity_log!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Calmdo.ActivityLogs.ActivityLog{id: id} = activity_log},
        %{assigns: %{activity_log: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :activity_log, activity_log)}
  end

  def handle_info(
        {:deleted, %Calmdo.ActivityLogs.ActivityLog{id: id}},
        %{assigns: %{activity_log: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current activity_log was deleted.")
     |> push_navigate(to: ~p"/activity_logs")}
  end

  def handle_info({type, %Calmdo.ActivityLogs.ActivityLog{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
