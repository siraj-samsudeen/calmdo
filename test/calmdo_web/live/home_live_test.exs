defmodule CalmdoWeb.HomeLiveTest do
  use CalmdoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Calmdo.ActivityLogsFixtures
  import Calmdo.TasksFixtures

  setup :register_and_log_in_user

  describe "Index" do
    test "displays activity feed page", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Activity Feed"
    end

    test "shows empty state when no activity logs exist", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "No activity yet"
      assert html =~ "Start logging your team&#39;s work to see it here"
    end

    test "displays activity logs grouped by date", %{conn: conn, scope: scope} do
      # Create activity logs with different dates
      project = project_fixture(scope)

      _today_log =
        activity_log_fixture(scope, %{
          notes: "Today's work",
          date: Date.utc_today(),
          project_id: project.id
        })

      _yesterday_log =
        activity_log_fixture(scope, %{
          notes: "Yesterday's work",
          date: Date.add(Date.utc_today(), -1),
          project_id: project.id
        })

      {:ok, _index_live, html} = live(conn, ~p"/")

      # Check that both activity logs are displayed (markdown renders in <p> tags)
      assert html =~ "Today"
      assert html =~ "work"
      assert html =~ "Yesterday"

      # Check that date headers are displayed
      assert html =~ "Today"
      assert html =~ "Yesterday"
    end

    test "displays user information for each activity", %{conn: conn, scope: scope, user: user} do
      project = project_fixture(scope)

      _activity_log =
        activity_log_fixture(scope, %{
          notes: "Testing activity",
          project_id: project.id
        })

      {:ok, _index_live, html} = live(conn, ~p"/")

      # Check that user email is displayed
      username = user.email |> String.split("@") |> List.first()
      assert html =~ username
      assert html =~ "Testing activity"
    end

    test "displays task and project links", %{conn: conn, scope: scope} do
      project = project_fixture(scope)
      task = task_fixture(scope, %{project_id: project.id})

      _activity_log =
        activity_log_fixture(scope, %{
          notes: "Work on feature",
          task_id: task.id,
          project_id: project.id
        })

      {:ok, _index_live, html} = live(conn, ~p"/")

      # Check that project and task names are displayed
      assert html =~ project.name
      assert html =~ task.title

      # Check that links exist
      assert html =~ ~p"/tasks/#{task}"
      assert html =~ ~p"/projects/#{project}"
    end

    test "displays duration information", %{conn: conn, scope: scope} do
      project = project_fixture(scope)

      _activity_log =
        activity_log_fixture(scope, %{
          notes: "Timed work",
          duration_in_hours: 2,
          duration_in_minutes: 30,
          project_id: project.id
        })

      {:ok, _index_live, html} = live(conn, ~p"/")

      # Check that duration is displayed
      assert html =~ "2h 30m"
    end

    test "displays billable badge for billable activities", %{conn: conn, scope: scope} do
      project = project_fixture(scope)

      _activity_log =
        activity_log_fixture(scope, %{
          notes: "Billable work",
          billable: true,
          project_id: project.id
        })

      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Billable"
    end

    test "provides link to create new activity log", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Log Time"
      assert html =~ ~p"/activity_logs/new"
    end

    test "provides edit links for each activity", %{conn: conn, scope: scope} do
      project = project_fixture(scope)

      activity_log =
        activity_log_fixture(scope, %{
          notes: "Editable work",
          project_id: project.id
        })

      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ ~p"/activity_logs/#{activity_log}/edit"
    end

    test "updates in real-time when new activity is created", %{conn: conn, scope: scope} do
      project = project_fixture(scope)

      {:ok, index_live, html} = live(conn, ~p"/")

      # Initially empty
      assert html =~ "No activity yet"

      # Create a new activity log (this will trigger PubSub broadcast)
      Calmdo.ActivityLogs.create_activity_log(scope, %{
        notes: "Real-time activity",
        date: Date.utc_today(),
        duration_in_hours: 1,
        project_id: project.id
      })

      # The LiveView should receive the broadcast and update
      html = render(index_live)
      assert html =~ "Real-time activity"
    end
  end
end
