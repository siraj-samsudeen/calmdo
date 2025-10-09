defmodule Calmdo.ActivityLogsTest do
  use Calmdo.DataCase

  alias Calmdo.ActivityLogs

  describe "activity_logs" do
    alias Calmdo.ActivityLogs.ActivityLog

    import Calmdo.AccountsFixtures, only: [user_scope_fixture: 0]
    import Calmdo.ActivityLogsFixtures
    import Calmdo.TasksFixtures, only: [project_fixture: 1]

    @invalid_attrs %{date: nil, duration_in_hours: nil, duration_in_minutes: nil, notes: nil}

    test "list_activity_logs/1 returns all scoped activity_logs" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)
      other_activity_log = activity_log_fixture(other_scope)
      assert ActivityLogs.list_activity_logs(scope) == [activity_log]
      assert ActivityLogs.list_activity_logs(other_scope) == [other_activity_log]
    end

    test "get_activity_log!/2 returns the activity_log with given id" do
      scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)
      other_scope = user_scope_fixture()
      assert ActivityLogs.get_activity_log!(scope, activity_log.id) == activity_log

      assert_raise Ecto.NoResultsError, fn ->
        ActivityLogs.get_activity_log!(other_scope, activity_log.id)
      end
    end

    test "create_activity_log/2 with valid data creates a activity_log" do
      scope = user_scope_fixture()
      project = project_fixture(scope)

      valid_attrs = %{
        date: ~D[2025-09-21],
        duration_in_hours: 42,
        duration_in_minutes: 0,
        notes: "some notes",
        project_id: project.id
      }

      assert {:ok, %ActivityLog{} = activity_log} =
               ActivityLogs.create_activity_log(scope, valid_attrs)

      assert activity_log.duration_in_hours == 42
      assert activity_log.duration_in_minutes == 0
      assert activity_log.notes == "some notes"
      assert activity_log.project_id == project.id
      assert activity_log.logged_by_id == scope.user.id
    end

    test "create_activity_log/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = ActivityLogs.create_activity_log(scope, @invalid_attrs)
    end

    test "update_activity_log/3 with valid data updates the activity_log" do
      scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)
      update_attrs = %{duration_in_hours: 43, duration_in_minutes: 0, notes: "some updated notes"}

      assert {:ok, %ActivityLog{} = activity_log} =
               ActivityLogs.update_activity_log(scope, activity_log, update_attrs)

      assert activity_log.duration_in_hours == 43
      assert activity_log.notes == "some updated notes"
    end

    test "update_activity_log/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)

      assert_raise MatchError, fn ->
        ActivityLogs.update_activity_log(other_scope, activity_log, %{})
      end
    end

    test "update_activity_log/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               ActivityLogs.update_activity_log(scope, activity_log, @invalid_attrs)

      assert activity_log.notes == ActivityLogs.get_activity_log!(scope, activity_log.id).notes
    end

    test "delete_activity_log/2 deletes the activity_log" do
      scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)
      assert {:ok, %ActivityLog{}} = ActivityLogs.delete_activity_log(scope, activity_log)

      assert_raise Ecto.NoResultsError, fn ->
        ActivityLogs.get_activity_log!(scope, activity_log.id)
      end
    end

    test "delete_activity_log/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)

      assert_raise MatchError, fn ->
        ActivityLogs.delete_activity_log(other_scope, activity_log)
      end
    end

    test "change_activity_log/2 returns a activity_log changeset" do
      scope = user_scope_fixture()
      activity_log = activity_log_fixture(scope)
      assert %Ecto.Changeset{} = ActivityLogs.change_activity_log(scope, activity_log)
    end
  end
end
