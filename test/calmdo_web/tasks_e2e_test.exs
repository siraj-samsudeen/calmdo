defmodule CalmdoWeb.TasksE2eTest do
  use CalmdoWeb.ConnCase

  alias Calmdo.Tasks

  import Calmdo.ProjectsFixtures
  import Calmdo.TasksFixtures
  import Calmdo.ActivityLogsFixtures
  import Calmdo.AccountsFixtures, only: [user_scope_fixture: 0]

  setup :register_and_log_in_user

  describe "task e2e" do
    test "task CRUD", %{conn: conn} do
      conn
      |> visit(tasks_path())
      # create the task
      |> click_link("New Task")
      |> fill_in("Title", with: "Test Task 1")
      |> submit()
      |> assert_text("Test Task 1")

      # edit the task, assuming a single task
      |> click_link("Edit")
      |> fill_in("Title", with: "Test Task 1 updated")
      |> submit()
      |> assert_text("Test Task 1 updated")

      # delete will be handled on bulk edit
    end

    test "create log from log time link", %{conn: conn, scope: scope} do
      task_fixture(scope)

      conn
      |> visit(tasks_path())
      # assuming a single task
      |> click_link("Log Time")
      |> fill_in("Duration in hours", with: "1")
      |> fill_in("Notes", with: "Test Activity log 1")
      |> submit()
      |> assert_has("a", text: "1.0")
    end

    test "display task logs when clicking hours", %{conn: conn, scope: scope} do
      task = task_fixture(scope)

      activity_log_fixture(scope, %{
        task_id: task.id,
        notes: "Test Activity log 1",
        duration_in_hours: 1
      })

      different_task = task_fixture(scope)

      activity_log_fixture(scope, %{
        task_id: different_task.id,
        notes: "Test Activity log 2",
        duration_in_hours: 2
      })

      conn
      |> visit(tasks_path())
      |> click_link("1.0")
      |> assert_text("Test Activity log 1")
      # The second log should not be visible, as it belongs to a different task
      |> refute_text("Test Activity log 2")
    end

    test "filter tasks page", %{conn: conn, scope: scope} do
      task_fixture(scope, %{
        title: "Test Task 1",
        duration_in_hours: 1,
        status: :work_in_progress,
        assignee_id: scope.user.id
      })

      other_scope = user_scope_fixture()

      task_fixture(other_scope, %{
        title: "Test Task 2",
        duration_in_hours: 2,
        status: :completed,
        assignee_id: other_scope.user.id
      })

      conn
      |> visit(tasks_path())
      # filter by status
      |> select("Status", option: "Work In Progress")
      |> assert_text("Test Task 1")
      |> refute_text("Test Task 2")

      # reset filters, then filter by assignee
      |> visit(tasks_path())
      # filter by assignee
      |> select("Assignee", option: extract_name(other_scope.user.email))
      |> assert_text("Test Task 2")
      |> refute_text("Test Task 1")

      # filter using `My Tasks` link
      |> click_link("My Tasks")
      |> assert_text("Test Task 1")
      |> refute_text("Test Task 2")
    end

    test "user can bulk update selected tasks", %{conn: conn, scope: scope} do
      project = project_fixture(scope, %{name: "Test Project 1"})

      task =
        task_fixture(scope, %{
          title: "Test Task 1",
          project_id: project.id,
          assignee_id: nil,
          status: :work_in_progress,
          priority: :low
        })

      other_project = project_fixture(scope, %{name: "Test Project 2"})

      other_task =
        task_fixture(scope, %{
          title: "Test Task 2",
          project_id: other_project.id,
          assignee_id: scope.user.id,
          status: :work_in_progress,
          priority: :medium
        })

      conn
      |> visit(tasks_path())
      # select the task, which will show the bulk edit panel
      |> check("Tasks #{task.id}")

      # Update the task
      |> within("#task-bulk-edit", fn conn ->
        conn
        |> select("Project", option: "Test Project 2")
        |> select("Assignee", option: extract_name(scope.user.email))
        |> select("Status", option: "Completed")
        |> select("Priority", option: "High")
        |> submit()
      end)

      # Verify the task was updated
      |> assert_has("#tasks-#{task.id} td", text: "Test Project 2")
      |> assert_has("#tasks-#{task.id} td", text: extract_name(scope.user.email))
      |> assert_has("#tasks-#{task.id} td", text: "Completed")
      |> assert_has("#tasks-#{task.id} td", text: "High")

      # Verify the other task was not updated
      |> assert_has("#tasks-#{other_task.id} td", text: "Work In Progress")
      |> assert_has("#tasks-#{other_task.id} td", text: "Medium")
    end

    test "user can bulk delete using the select all checkbox", %{conn: conn, scope: scope} do
      task_fixture(scope, %{title: "Test Task 1"})
      task_fixture(scope, %{title: "Test Task 2"})

      conn
      |> visit(tasks_path())
      # select toggle all checkbox
      |> check("Select all")

      # delete tasks
      |> within("#task-bulk-edit", fn conn ->
        conn
        |> click_button("Delete")
      end)

      # verify the tasks were deleted
      |> refute_text("Test Task 1")
      |> refute_text("Test Task 2")

      # verify the tasks were deleted
      assert [] = Tasks.list_tasks(scope)
    end
  end

  defp extract_name(nil), do: ""
  defp extract_name(email), do: String.split(email, "@") |> Enum.at(0)

  defp tasks_path, do: ~p"/tasks"
end
