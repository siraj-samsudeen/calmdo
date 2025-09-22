defmodule Calmdo.TasksTest do
  use Calmdo.DataCase

  alias Calmdo.Tasks

  describe "tasks" do
    alias Calmdo.Tasks.Task

    import Calmdo.AccountsFixtures, only: [user_scope_fixture: 0]
    import Calmdo.TasksFixtures

    @invalid_attrs %{priority: nil, status: nil, title: nil, notes: nil, due_date: nil}

    test "list_tasks/1 returns all scoped tasks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)
      other_task = task_fixture(other_scope)
      assert Tasks.list_tasks(scope) == [task]
      assert Tasks.list_tasks(other_scope) == [other_task]
    end

    test "get_task!/2 returns the task with given id" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      other_scope = user_scope_fixture()
      assert Tasks.get_task!(scope, task.id) == task
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(other_scope, task.id) end
    end

    test "create_task/2 with valid data creates a task" do
      valid_attrs = %{priority: :low, status: :started, title: "some title", notes: "some notes", due_date: ~D[2025-09-21]}
      scope = user_scope_fixture()

      assert {:ok, %Task{} = task} = Tasks.create_task(scope, valid_attrs)
      assert task.priority == :low
      assert task.status == :started
      assert task.title == "some title"
      assert task.notes == "some notes"
      assert task.due_date == ~D[2025-09-21]
      assert task.user_id == scope.user.id
    end

    test "create_task/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(scope, @invalid_attrs)
    end

    test "update_task/3 with valid data updates the task" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      update_attrs = %{priority: :medium, status: :work_in_progress, title: "some updated title", notes: "some updated notes", due_date: ~D[2025-09-22]}

      assert {:ok, %Task{} = task} = Tasks.update_task(scope, task, update_attrs)
      assert task.priority == :medium
      assert task.status == :work_in_progress
      assert task.title == "some updated title"
      assert task.notes == "some updated notes"
      assert task.due_date == ~D[2025-09-22]
    end

    test "update_task/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)

      assert_raise MatchError, fn ->
        Tasks.update_task(other_scope, task, %{})
      end
    end

    test "update_task/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(scope, task, @invalid_attrs)
      assert task == Tasks.get_task!(scope, task.id)
    end

    test "delete_task/2 deletes the task" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert {:ok, %Task{}} = Tasks.delete_task(scope, task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(scope, task.id) end
    end

    test "delete_task/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)
      assert_raise MatchError, fn -> Tasks.delete_task(other_scope, task) end
    end

    test "change_task/2 returns a task changeset" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert %Ecto.Changeset{} = Tasks.change_task(scope, task)
    end
  end
end
