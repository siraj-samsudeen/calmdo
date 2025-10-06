defmodule Calmdo.ActivityLogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Calmdo.ActivityLogs` context.
  """

  @doc """
  Generate a activity_log.
  """
  def activity_log_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        duration_in_hours: 42,
        notes: "some notes"
      })

    {:ok, activity_log} = Calmdo.ActivityLogs.create_activity_log(scope, attrs)
    activity_log
  end
end
