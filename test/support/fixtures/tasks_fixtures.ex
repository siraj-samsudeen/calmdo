defmodule Calmdo.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Calmdo.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        due_date: ~D[2025-09-21],
        notes: "some notes",
        priority: :low,
        status: :started,
        title: "some title"
      })

    {:ok, task} = Calmdo.Tasks.create_task(scope, attrs)
    task
  end
end
