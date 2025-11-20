defmodule CalmdoWeb.ProjectLiveTest do
  use CalmdoWeb.ConnCase

  import Calmdo.ProjectsFixtures
  alias Calmdo.Projects
  alias Calmdo.Tasks.Project
  alias Calmdo.Repo

  setup :register_and_log_in_user

  defp create_project(%{scope: scope}) do
    project = project_fixture(scope)

    %{project: project}
  end

  describe "basic project CRUD" do
    test "creating a project", %{conn: conn} do
      conn
      |> visit_projects()
      |> click_link("New Project")
      |> fill_in("Name", with: "Launch Campaign")
      |> submit()
      |> assert_text("Launch Campaign")

      # Verify DB persistence - direct Repo for test verification
      assert Repo.get_by(Project, name: "Launch Campaign")
    end

    test "viewing a project", %{conn: conn, scope: scope} do
      project = project_fixture(scope, name: "Product Launch")

      conn
      |> visit(~p"/projects/#{project}")
      |> assert_text("Product Launch")
    end

    test "editing a project", %{conn: conn, scope: scope} do
      project = project_fixture(scope, name: "Old Name")

      conn
      |> visit(~p"/projects/#{project}")
      |> click_link("Edit")
      |> fill_in("Name", with: "New Name")
      |> submit()
      |> assert_text("New Name")

      # Verify DB update via Context (function exists)
      assert Projects.get_project!(scope, project.id).name == "New Name"
    end

    test "deleting a project", %{conn: conn, scope: scope} do
      _project = project_fixture(scope, name: "To Delete")

      conn
      |> visit_projects()
      |> click_link("Delete")
      |> refute_text("To Delete")

      # Verify DB deletion - direct Repo for test verification
      refute Repo.get_by(Project, name: "To Delete")
    end
  end

  describe "project listing" do
    setup [:create_project]

    test "lists all projects", %{conn: conn, project: project} do
      conn
      |> visit_projects()
      |> assert_text(project.name)
    end

    test "updates project from listing", %{conn: conn, project: project, scope: scope} do
      conn
      |> visit_projects()
      |> click_link("#projects-#{project.id} a", "Edit")
      |> fill_in("Name", with: "Updated from List")
      |> submit()
      |> assert_text("Updated from List")

      # Verify DB update via Context (function exists)
      assert Projects.get_project!(scope, project.id).name == "Updated from List"
    end
  end

  # Simple helper - transparent, reusable
  defp visit_projects(conn) do
    visit(conn, ~p"/projects")
  end
end
