defmodule CalmdoWeb.ActivityLogsE2eTest do
  use CalmdoWeb.ConnCase

  alias Calmdo.ActivityLogs

  import Calmdo.ProjectsFixtures
  import Calmdo.TasksFixtures
  import Calmdo.ActivityLogsFixtures

  setup :register_and_log_in_user

  describe "activity log e2e" do
    test "activity log CRUD", %{conn: conn, scope: scope} do
      task_fixture(scope, title: "Test Task 1")

      conn
      |> visit(~p"/activity_logs")
      |> click_link("New Activity log")
      |> select("Task", option: "Test Task 1")
      |> fill_in("Duration in hours", with: "1")
      |> fill_in("Notes", with: "Test Activity log 1")
      |> submit()
      |> assert_text("Test Activity log 1")

      # edit the activity log, assuming a single activity log
      |> click_link("Edit")
      # to update the textarea, we need to use `exact: false`
      |> fill_in("Notes", with: "Test Activity log 1 updated", exact: false)
      |> submit()
      |> assert_text("Test Activity log 1 updated")

      # delete the activity log, assuming a single activity log
      |> click_link("Delete")
      |> refute_text("Test Activity log 1 updated")

      assert [] = ActivityLogs.list_activity_logs(scope)
    end

    test "notes should be rendered as markdown", %{conn: conn, scope: scope} do
      markdown = "[Markdown link](https://example.com)"
      activity_log_fixture(scope, %{notes: markdown})

      conn
      |> visit(~p"/activity_logs")
      |> assert_has("a[href='https://example.com']", text: "Markdown link")
    end

    test "task dropdown filters correctly based on selected project in activity log form", %{
      conn: conn,
      scope: scope
    } do
      project = project_fixture(scope, %{name: "Test Project 1"})
      task_1 = task_fixture(scope, %{project_id: project.id, title: "Test Task 1"})
      task_2 = task_fixture(scope, %{project_id: project.id, title: "Test Task 2"})

      other_project = project_fixture(scope, %{name: "Test Project 2"})
      task_3 = task_fixture(scope, %{project_id: other_project.id, title: "Test Task 3"})

      conn
      |> visit(~p"/activity_logs/new")
      |> select("Project", option: "Test Project 1")
      |> assert_has("option[value='#{task_1.id}']", text: "Test Task 1")
      |> assert_has("option[value='#{task_2.id}']", text: "Test Task 2")
      |> refute_has("option[value='#{task_3.id}']", text: "Test Task 3")
    end
  end
end
