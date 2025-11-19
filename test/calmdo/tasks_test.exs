defmodule Calmdo.TasksTest do
  use Calmdo.DataCase

  alias Calmdo.Tasks

  describe "tasks" do
    alias Calmdo.Tasks.Task

    import Calmdo.AccountsFixtures, only: [user_scope_fixture: 0]
    import Calmdo.TasksFixtures

    @invalid_attrs %{title: nil}

    test "list_tasks/1 returns all tasks (shared)" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)
      other_task = task_fixture(other_scope)

      assert Enum.sort(Enum.map(Tasks.list_tasks(scope), & &1.id)) ==
               Enum.sort([task.id, other_task.id])

      assert Enum.sort(Enum.map(Tasks.list_tasks(other_scope), & &1.id)) ==
               Enum.sort([task.id, other_task.id])
    end

    test "get_task!/2 returns the task with given id (shared)" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      other_scope = user_scope_fixture()
      assert Tasks.get_task!(scope, task.id) == task
      assert Tasks.get_task!(other_scope, task.id) == task
    end

    test "create_task/2 with valid data creates a task" do
      valid_attrs = %{
        priority: :low,
        status: :started,
        title: "some title",
        notes: "some notes",
        due_date: ~D[2025-09-21]
      }

      scope = user_scope_fixture()

      assert {:ok, %Task{} = task} = Tasks.create_task(scope, valid_attrs)
      assert task.priority == :low
      assert task.status == :started
      assert task.title == "some title"
      assert task.notes == "some notes"
      assert task.due_date == ~D[2025-09-21]
      assert task.created_by_id == scope.user.id
    end

    test "create_task/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(scope, @invalid_attrs)
    end

    test "update_task/3 with valid data updates the task" do
      scope = user_scope_fixture()
      task = task_fixture(scope)

      update_attrs = %{
        priority: :medium,
        status: :work_in_progress,
        title: "some updated title",
        notes: "some updated notes",
        due_date: ~D[2025-09-22]
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(scope, task, update_attrs)
      assert task.priority == :medium
      assert task.status == :work_in_progress
      assert task.title == "some updated title"
      assert task.notes == "some updated notes"
      assert task.due_date == ~D[2025-09-22]
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

    test "change_task/2 returns a task changeset" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert %Ecto.Changeset{} = Tasks.change_task(scope, task)
    end
  end

  describe "projects" do
    alias Calmdo.Tasks.Project

    import Calmdo.AccountsFixtures, only: [user_scope_fixture: 0]
    import Calmdo.TasksFixtures

    @invalid_attrs %{name: nil, completed: nil}

    test "list_projects/1 returns all projects (shared)" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)
      other_project = project_fixture(other_scope)
      ids = Enum.map(Tasks.list_projects(scope), & &1.id) |> Enum.sort()
      assert ids == Enum.sort([project.id, other_project.id])

      ids2 = Enum.map(Tasks.list_projects(other_scope), & &1.id) |> Enum.sort()
      assert ids2 == Enum.sort([project.id, other_project.id])
    end

    test "get_project!/2 returns the project with given id (shared)" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      other_scope = user_scope_fixture()
      assert Tasks.get_project!(scope, project.id) == project
      assert Tasks.get_project!(other_scope, project.id) == project
    end

    test "create_project/2 with valid data creates a project" do
      valid_attrs = %{name: "some name", completed: true}
      scope = user_scope_fixture()

      assert {:ok, %Project{} = project} = Tasks.create_project(scope, valid_attrs)
      assert project.name == "some name"
      assert project.completed == true
      assert project.owner_id == scope.user.id
    end

    test "create_project/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.create_project(scope, @invalid_attrs)
    end

    test "update_project/3 with valid data updates the project" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      update_attrs = %{name: "some updated name", completed: false}

      assert {:ok, %Project{} = project} = Tasks.update_project(scope, project, update_attrs)
      assert project.name == "some updated name"
      assert project.completed == false
    end

    test "update_project/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)

      assert_raise MatchError, fn ->
        Tasks.update_project(other_scope, project, %{})
      end
    end

    test "update_project/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Tasks.update_project(scope, project, @invalid_attrs)
      assert project == Tasks.get_project!(scope, project.id)
    end

    test "delete_project/2 deletes the project" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert {:ok, %Project{}} = Tasks.delete_project(scope, project)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_project!(scope, project.id) end
    end

    test "delete_project/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)
      assert_raise MatchError, fn -> Tasks.delete_project(other_scope, project) end
    end

    test "change_project/2 returns a project changeset" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert %Ecto.Changeset{} = Tasks.change_project(scope, project)
    end
  end
end
