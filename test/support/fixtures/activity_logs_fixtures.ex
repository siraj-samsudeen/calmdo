defmodule Calmdo.ActivityLogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Calmdo.ActivityLogs` context.
  """

  @doc """
  Generate a activity_log.
  """
  def activity_log_fixture(scope, attrs \\ %{}) do
    project_id =
      attrs
      |> Map.get(:project_id)
      |> case do
        nil ->
          Calmdo.TasksFixtures.project_fixture(scope).id

        id ->
          id
      end

    attrs =
      Enum.into(attrs, %{
        date: Date.utc_today(),
        duration_in_hours: 42,
        duration_in_minutes: 0,
        notes: "some notes",
        billable: false,
        project_id: project_id
      })

    {:ok, activity_log} = Calmdo.ActivityLogs.create_activity_log(scope, attrs)

    # Preload associations to match the shape of data returned by the context
    # functions. This is necessary for tests that do a direct struct-to-struct
    # comparison.
    activity_log
    |> Calmdo.Repo.preload([:task, :project])
  end
end
