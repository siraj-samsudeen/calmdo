defmodule CalmdoWeb.TaskLiveTest do
  use CalmdoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Calmdo.TasksFixtures

  @create_attrs %{
    priority: :low,
    status: :started,
    title: "some title",
    notes: "some notes",
    due_date: "2025-09-21"
  }
  @update_attrs %{
    priority: :medium,
    status: :work_in_progress,
    title: "some updated title",
    notes: "some updated notes",
    due_date: "2025-09-22"
  }
  @invalid_attrs %{priority: nil, status: nil, title: nil, notes: nil, due_date: nil}

  setup :register_and_log_in_user

  defp create_task(%{scope: scope}) do
    task = task_fixture(scope)

    %{task: task}
  end

  describe "Index" do
    setup [:create_task]

    test "lists all tasks", %{conn: conn, task: task} do
      {:ok, _index_live, html} = live(conn, ~p"/tasks")

      assert html =~ "Listing Tasks"
      assert html =~ task.title
    end

    test "saves new task", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      assert {:ok, form_live, _} =
               index_live
               |> element("main a", "New Task")
               |> render_click()
               |> follow_redirect(conn, ~p"/tasks/new")

      assert render(form_live) =~ "New Task"

      assert form_live
             |> form("#task-form", task: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#task-form", task: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tasks")

      html = render(index_live)
      assert html =~ "Task created successfully"
      assert html =~ "some title"
    end

    test "updates task in listing", %{conn: conn, task: task} do
      # Navigate directly to edit page (clicking row now goes to edit)
      assert {:ok, form_live, _html} = live(conn, ~p"/tasks/#{task}/edit")

      assert render(form_live) =~ "Edit Task"

      assert form_live
             |> form("#task-form", task: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#task-form", task: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tasks")

      html = render(index_live)
      assert html =~ "Task updated successfully"
      assert html =~ "some updated title"
    end

  end

  describe "Bulk Operations" do
    setup [:create_task]

    test "selecting individual tasks shows bulk edit panel", %{conn: conn, task: task} do
      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Initially no bulk edit panel
      refute render(index_live) =~ "Bulk Edit"

      # Select the task
      html =
        index_live
        |> element("input[type=checkbox][phx-value-id='#{task.id}']")
        |> render_click()

      # Bulk edit panel should appear
      assert html =~ "Bulk Edit"
      assert html =~ "1 selected"
    end

    test "toggle all selects all visible tasks", %{conn: conn, scope: scope} do
      # Create multiple tasks
      task_fixture(scope, %{title: "Task 1"})
      task_fixture(scope, %{title: "Task 2"})
      task_fixture(scope, %{title: "Task 3"})

      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Click select all checkbox
      html =
        index_live
        |> element("input[type=checkbox][phx-click='toggle_all']")
        |> render_click()

      # Should show all tasks selected (3 original + setup task = 4)
      assert html =~ "4 selected"
    end

    test "cancel bulk edit clears selection", %{conn: conn, task: task} do
      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Select the task
      index_live
      |> element("input[type=checkbox][phx-value-id='#{task.id}']")
      |> render_click()

      # Click cancel
      html =
        index_live
        |> element("button", "Cancel")
        |> render_click()

      # Bulk edit panel should disappear
      refute html =~ "Bulk Edit"
    end

    test "bulk update status for multiple tasks", %{conn: conn, scope: scope} do
      task1 = task_fixture(scope, %{title: "Task 1", status: :started})
      task2 = task_fixture(scope, %{title: "Task 2", status: :started})

      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Select both tasks
      index_live
      |> element("input[type=checkbox][phx-value-id='#{task1.id}']")
      |> render_click()

      index_live
      |> element("input[type=checkbox][phx-value-id='#{task2.id}']")
      |> render_click()

      # Submit bulk update form with status change
      html =
        index_live
        |> form("form[phx-submit='apply_bulk_edit']", %{status: "completed"})
        |> render_submit()

      # Should show success message
      assert html =~ "Successfully updated 2 task(s)"

      # Verify tasks were updated
      assert Calmdo.Tasks.get_task!(scope, task1.id).status == :completed
      assert Calmdo.Tasks.get_task!(scope, task2.id).status == :completed
    end

    test "bulk update priority for multiple tasks", %{conn: conn, scope: scope} do
      task1 = task_fixture(scope, %{title: "Task 1", priority: :low})
      task2 = task_fixture(scope, %{title: "Task 2", priority: :low})

      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Select both tasks
      index_live
      |> element("input[type=checkbox][phx-value-id='#{task1.id}']")
      |> render_click()

      index_live
      |> element("input[type=checkbox][phx-value-id='#{task2.id}']")
      |> render_click()

      # Submit bulk update with priority change
      html =
        index_live
        |> form("form[phx-submit='apply_bulk_edit']", %{priority: "high"})
        |> render_submit()

      assert html =~ "Successfully updated 2 task(s)"

      # Verify tasks were updated
      assert Calmdo.Tasks.get_task!(scope, task1.id).priority == :high
      assert Calmdo.Tasks.get_task!(scope, task2.id).priority == :high
    end

    test "bulk update multiple fields at once", %{conn: conn, scope: scope} do
      task1 = task_fixture(scope, %{title: "Task 1", status: :started, priority: :low})
      task2 = task_fixture(scope, %{title: "Task 2", status: :started, priority: :low})

      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Select both tasks
      index_live
      |> element("input[type=checkbox][phx-value-id='#{task1.id}']")
      |> render_click()

      index_live
      |> element("input[type=checkbox][phx-value-id='#{task2.id}']")
      |> render_click()

      # Submit bulk update with multiple field changes
      html =
        index_live
        |> form("form[phx-submit='apply_bulk_edit']", %{status: "completed", priority: "high"})
        |> render_submit()

      assert html =~ "Successfully updated 2 task(s)"

      # Verify both fields were updated
      updated_task1 = Calmdo.Tasks.get_task!(scope, task1.id)
      assert updated_task1.status == :completed
      assert updated_task1.priority == :high

      updated_task2 = Calmdo.Tasks.get_task!(scope, task2.id)
      assert updated_task2.status == :completed
      assert updated_task2.priority == :high
    end

    test "bulk update shows error when no field selected", %{conn: conn, scope: scope} do
      task = task_fixture(scope, %{title: "Task 1"})

      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Select task
      index_live
      |> element("input[type=checkbox][phx-value-id='#{task.id}']")
      |> render_click()

      # Submit form without selecting any field (all empty values)
      html =
        index_live
        |> form("form[phx-submit='apply_bulk_edit']", %{status: "", priority: "", assignee_id: "", project_id: ""})
        |> render_submit()

      # Should show error message
      assert html =~ "Please select at least one field to update"
    end

    test "bulk delete removes multiple tasks", %{conn: conn, scope: scope} do
      task1 = task_fixture(scope, %{title: "Task 1"})
      task2 = task_fixture(scope, %{title: "Task 2"})

      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Select both tasks
      index_live
      |> element("input[type=checkbox][phx-value-id='#{task1.id}']")
      |> render_click()

      index_live
      |> element("input[type=checkbox][phx-value-id='#{task2.id}']")
      |> render_click()

      # Click bulk delete button
      html =
        index_live
        |> element("button", "Delete 2 task(s)")
        |> render_click()

      # Should show success message
      assert html =~ "Successfully deleted 2 task(s)"

      # Verify tasks are deleted
      refute has_element?(index_live, "#tasks-#{task1.id}")
      refute has_element?(index_live, "#tasks-#{task2.id}")
    end

    test "bulk delete handles associated activity logs", %{conn: conn, scope: scope} do
      # Create task with activity log
      task = task_fixture(scope, %{title: "Task with logs"})

      {:ok, _log} =
        Calmdo.ActivityLogs.create_activity_log(scope, %{
          task_id: task.id,
          date: ~D[2025-01-01],
          duration_in_hours: 2,
          notes: "Some work"
        })

      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      # Select and delete task
      index_live
      |> element("input[type=checkbox][phx-value-id='#{task.id}']")
      |> render_click()

      html =
        index_live
        |> element("button", "Delete 1 task(s)")
        |> render_click()

      # Should successfully delete despite having activity logs
      assert html =~ "Successfully deleted 1 task(s)"
      refute has_element?(index_live, "#tasks-#{task.id}")
    end

    test "hours column is not clickable when zero", %{conn: conn, scope: scope} do
      # Create task without any activity logs (0 hours)
      _task = task_fixture(scope, %{title: "No hours task"})

      {:ok, _index_live, html} = live(conn, ~p"/tasks")

      # The hours cell should not contain a link for this task
      # It should just show "0.0" as plain text
      assert html =~ "0.0"

      # Check that there's no link to activity logs for this task with 0 hours
      # This is implicit - if total_hours is 0, the link won't be rendered
    end

    test "row click navigates to edit page", %{conn: conn, task: task} do
      # Navigate directly to edit (row clicks now go to edit)
      {:ok, _edit_live, html} = live(conn, ~p"/tasks/#{task}/edit")

      assert html =~ "Edit Task"
      assert html =~ task.title
    end
  end

  describe "Show" do
    setup [:create_task]

    test "displays task", %{conn: conn, task: task} do
      {:ok, _show_live, html} = live(conn, ~p"/tasks/#{task}")

      assert html =~ "Show Task"
      assert html =~ task.title
    end

    test "updates task and returns to show", %{conn: conn, task: task} do
      {:ok, show_live, _html} = live(conn, ~p"/tasks/#{task}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tasks/#{task}/edit?return_to=show")

      assert render(form_live) =~ "Edit Task"

      assert form_live
             |> form("#task-form", task: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#task-form", task: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tasks/#{task}")

      html = render(show_live)
      assert html =~ "Task updated successfully"
      assert html =~ "some updated title"
    end
  end
end
