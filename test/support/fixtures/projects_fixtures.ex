defmodule Calmdo.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Calmdo.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        completed: false,
        name: "some name"
      })

    {:ok, project} = Calmdo.Projects.create_project(scope, attrs)
    project
  end
end
