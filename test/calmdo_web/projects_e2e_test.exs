defmodule CalmdoWeb.ProjectsE2eTest do
  use CalmdoWeb.ConnCase

  import Calmdo.ProjectsFixtures
  import Calmdo.TasksFixtures
  import Calmdo.ActivityLogsFixtures

  alias Calmdo.Projects

  setup :register_and_log_in_user

  describe "project e2e" do
    test "project CRUD", %{conn: conn, scope: scope} do
      conn
      |> visit(projects_path())
      # create the project
      |> click_link("New Project")
      |> fill_in("Name", with: "Test Project 1")
      |> submit()
      |> assert_text("Test Project 1")

      # visit the show page, assuming a single project
      |> click_link("Show")
      |> assert_text("Test Project 1")
      # back to project lists page
      |> click_link("Back")

      # edit the project, assuming a single project
      |> click_link("Edit")
      |> fill_in("Name", with: "Test Project 1 updated")
      |> submit()
      |> assert_text("Test Project 1 updated")

      # delete the project, assuming a single project
      |> click_link("Delete")
      |> refute_text("Test Project 1 updated")

      # verify DB deletion
      assert [] = Projects.list_projects(scope)
    end

    # separate test to check more complex features not covered in CRUD
    test "show project", %{conn: conn, scope: scope} do
      project = project_fixture(scope, %{name: "Test Project 1"})

      conn
      |> visit(project_path(project))
      |> assert_text("Test Project 1")
    end

    test "edit project in show project page", %{conn: conn, scope: scope} do
      project = project_fixture(scope, %{name: "Test Project 1"})

      conn
      |> visit(project_path(project))
      |> click_link("Edit")
      |> fill_in("Name", with: "Test Project 1 updated")
      |> submit()
      |> assert_path(project_path(project))
      |> assert_text("Test Project 1 updated")
    end

    test "create and display task in show project page", %{conn: conn, scope: scope} do
      project = project_fixture(scope)

      conn
      |> visit(project_path(project))
      |> click_link("New Task")
      |> fill_in("Title", with: "Test Task 1")
      |> submit()
      |> assert_path(project_path(project))
      |> assert_text("Test Task 1")
    end

    test "create and display log in show project page", %{conn: conn, scope: scope} do
      project = project_fixture(scope)

      conn
      |> visit(project_path(project))
      |> click_link("New Log")
      |> fill_in("Duration in hours", with: "1")
      |> fill_in("Notes", with: "Test Activity log 1")
      |> submit()
      |> assert_path(project_path(project))
      |> assert_text("Test Activity log 1")
    end

    test "create and display log from task's log time link in show project page", %{
      conn: conn,
      scope: scope
    } do
      project = project_fixture(scope)
      task_fixture(scope, %{project_id: project.id})

      conn
      |> visit(project_path(project))
      # assuming a single task
      |> click_link("Log Time")
      |> fill_in("Duration in hours", with: "1")
      |> fill_in("Notes", with: "Test Activity log 1")
      |> submit()
      |> assert_path(project_path(project))
      |> assert_text("Test Activity log 1")
    end

    test "display task logs when clicking hours in show project page", %{
      conn: conn,
      scope: scope
    } do
      project = project_fixture(scope)
      task = task_fixture(scope, %{project_id: project.id})

      activity_log_fixture(scope, %{
        project_id: project.id,
        task_id: task.id,
        notes: "Test Activity log 1",
        duration_in_hours: 1
      })

      different_task = task_fixture(scope, %{project_id: project.id})

      activity_log_fixture(scope, %{
        project_id: project.id,
        task_id: different_task.id,
        notes: "Test Activity log 2",
        duration_in_hours: 2
      })

      conn
      |> visit(project_path(project))
      |> click_link("1.0")
      |> assert_text("Test Activity log 1")
      # The second log should not be visible, as it belongs to a different task
      |> refute_text("Test Activity log 2")
    end

    test "edit task from show project page", %{conn: conn, scope: scope} do
      project = project_fixture(scope)
      task_fixture(scope, %{project_id: project.id, title: "Test Task 1"})

      conn
      |> visit(project_path(project))
      |> click_link("Edit task")
      |> fill_in("Title", with: "Test Task 1 updated")
      |> submit()
      |> assert_path(project_path(project))
      |> assert_text("Test Task 1 updated")
    end

    test "edit log from show project page", %{conn: conn, scope: scope} do
      project = project_fixture(scope)
      task = task_fixture(scope, %{project_id: project.id})

      activity_log_fixture(scope, %{
        project_id: project.id,
        task_id: task.id,
        notes: "Test Activity log 1"
      })

      conn
      |> visit(project_path(project))
      |> click_link("Edit log")
      |> fill_in("Notes", with: "Test Activity log 1 updated", exact: false)
      |> submit()
      |> assert_path(project_path(project))
      |> assert_text("Test Activity log 1 updated")
    end
  end

  defp projects_path, do: ~p"/projects"
  defp project_path(project), do: ~p"/projects/#{project.id}"
end
