defmodule CalmdoWeb.HomeLive.Index do
  use CalmdoWeb, :live_view

  alias Calmdo.ActivityLogs

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      ActivityLogs.subscribe_activity_logs(socket.assigns.current_scope)
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    activity_logs = ActivityLogs.list_activity_logs(socket.assigns.current_scope)
    grouped_activities = group_by_date(activity_logs)

    {:noreply,
     socket
     |> assign(:grouped_activities, grouped_activities)
     |> assign(:page_title, "Activity Feed")}
  end

  @impl true
  def handle_info({:created, _activity_log}, socket) do
    activity_logs = ActivityLogs.list_activity_logs(socket.assigns.current_scope)
    grouped_activities = group_by_date(activity_logs)

    {:noreply, assign(socket, :grouped_activities, grouped_activities)}
  end

  def handle_info({:updated, _activity_log}, socket) do
    activity_logs = ActivityLogs.list_activity_logs(socket.assigns.current_scope)
    grouped_activities = group_by_date(activity_logs)

    {:noreply, assign(socket, :grouped_activities, grouped_activities)}
  end

  def handle_info({:deleted, _activity_log}, socket) do
    activity_logs = ActivityLogs.list_activity_logs(socket.assigns.current_scope)
    grouped_activities = group_by_date(activity_logs)

    {:noreply, assign(socket, :grouped_activities, grouped_activities)}
  end

  defp group_by_date(activity_logs) do
    activity_logs
    |> Enum.group_by(& &1.date)
    |> Enum.map(fn {date, logs} -> {date, logs} end)
    |> Enum.sort_by(fn {date, _logs} -> date end, {:desc, Date})
  end

  defp format_duration(activity) do
    hours = activity.duration_in_hours || 0
    minutes = activity.duration_in_minutes || 0

    cond do
      hours > 0 and minutes > 0 -> "#{hours}h #{minutes}m"
      hours > 0 -> "#{hours}h"
      minutes > 0 -> "#{minutes}m"
      true -> "0m"
    end
  end

  defp format_date_header(date) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)

    cond do
      Date.compare(date, today) == :eq -> "Today"
      Date.compare(date, yesterday) == :eq -> "Yesterday"
      true -> Calendar.strftime(date, "%B %d, %Y")
    end
  end

  defp relative_time(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      true -> Calendar.strftime(datetime, "%I:%M %p")
    end
  end
end
