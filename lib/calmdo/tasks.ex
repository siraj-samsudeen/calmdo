defmodule Calmdo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  import Calmdo.EctoHelpers
  alias Calmdo.Repo

  alias Calmdo.Tasks.Task
  alias Calmdo.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any task changes.

  The broadcasted messages match the pattern:

    * {:created, %Task{}}
    * {:updated, %Task{}}
    * {:deleted, %Task{}}

  """
  def subscribe_tasks(%Scope{} = _scope) do
    Phoenix.PubSub.subscribe(Calmdo.PubSub, "tasks")
  end

  defp broadcast_task(%Scope{} = _scope, message) do
    Phoenix.PubSub.broadcast(Calmdo.PubSub, "tasks", message)
  end

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks(scope)
      [%Task{}, ...]

  """
  def list_tasks(%Scope{} = _scope) do
    Task
    |> with_task_index_preloads()
    |> with_total_hours()
    |> order_by_recent()
    |> Repo.all()
  end

  def list_tasks(%Scope{} = _scope, params) when is_map(params) do
    Task
    |> with_task_index_preloads()
    |> with_total_hours()
    |> maybe_where(:status, params["status"])
    |> maybe_where(:assignee_id, params["assignee_id"])
    |> order_by_recent()
    |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(scope, 123)
      %Task{}

      iex> get_task!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(%Scope{} = _scope, id) do
    Repo.get!(Task, id)
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(scope, %{field: value})
      {:ok, %Task{}}

      iex> create_task(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(%Scope{} = scope, attrs) do
    with {:ok, task = %Task{}} <-
           %Task{}
           |> Task.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_task(scope, {:created, task})
      {:ok, task}
    end
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(scope, task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(scope, task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Scope{} = scope, %Task{} = task, attrs) do
    true = task.created_by_id == scope.user.id

    with {:ok, task = %Task{}} <-
           task
           |> Task.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_task(scope, {:updated, task})
      {:ok, task}
    end
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(scope, task)
      {:ok, %Task{}}

      iex> delete_task(scope, task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Scope{} = scope, %Task{} = task) do
    true = task.created_by_id == scope.user.id

    with {:ok, task = %Task{}} <-
           Repo.delete(task) do
      broadcast_task(scope, {:deleted, task})
      {:ok, task}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(scope, task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Scope{} = scope, %Task{} = task, attrs \\ %{}) do
    true = task.created_by_id == scope.user.id

    Task.changeset(task, attrs, scope)
  end

  @doc """
  Bulk updates multiple tasks with the same field values.

  ## Examples

      iex> bulk_update_tasks(scope, [1, 2, 3], %{status: :completed})
      {:ok, 3}

      iex> bulk_update_tasks(scope, [], %{status: :completed})
      {:ok, 0}

  """
  def bulk_update_tasks(%Scope{} = scope, task_ids, attrs) when is_list(task_ids) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    # Build the update map with only the provided fields
    updates =
      attrs
      |> Map.put(:updated_at, now)

    # Perform the bulk update
    {count, _} =
      from(t in Task, where: t.id in ^task_ids)
      |> Repo.update_all(set: Map.to_list(updates))

    # Broadcast updates for each task
    Enum.each(task_ids, fn task_id ->
      # Fetch the updated task to broadcast
      task = get_task!(scope, task_id)
      broadcast_task(scope, {:updated, task})
    end)

    {:ok, count}
  rescue
    error ->
      {:error, error}
  end

  @doc """
  Bulk deletes multiple tasks.

  ## Examples

      iex> bulk_delete_tasks(scope, [1, 2, 3])
      {:ok, 3}

      iex> bulk_delete_tasks(scope, [])
      {:ok, 0}

  """
  def bulk_delete_tasks(%Scope{} = scope, task_ids) when is_list(task_ids) do
    # Fetch tasks before deleting for broadcasting
    tasks =
      from(t in Task, where: t.id in ^task_ids)
      |> Repo.all()

    # Delete associated activity logs first
    from(al in Calmdo.ActivityLogs.ActivityLog, where: al.task_id in ^task_ids)
    |> Repo.delete_all()

    # Perform the bulk delete
    {count, _} =
      from(t in Task, where: t.id in ^task_ids)
      |> Repo.delete_all()

    # Broadcast deletions for each task
    Enum.each(tasks, fn task ->
      broadcast_task(scope, {:deleted, task})
    end)

    {:ok, count}
  rescue
    error ->
      {:error, error}
  end

  # Query composition helpers
  defp with_task_index_preloads(query) do
    from q in query, preload: [:project, :assignee]
  end

  defp with_total_hours(query) do
    from t in query,
      left_join: al in assoc(t, :activity_logs),
      group_by: t.id,
      select_merge: %{
        total_hours:
          fragment(
            "CAST(COALESCE(SUM(COALESCE(?, 0) + COALESCE(?, 0) / 60.0), 0) AS float)",
            al.duration_in_hours,
            al.duration_in_minutes
          )
      }
  end

  defp order_by_recent(query) do
    from q in query, order_by: [desc: q.updated_at]
  end

  alias Calmdo.Tasks.Project
  alias Calmdo.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any project changes.

  The broadcasted messages match the pattern:

    * {:created, %Project{}}
    * {:updated, %Project{}}
    * {:deleted, %Project{}}

  """
  def subscribe_projects(%Scope{} = _scope) do
    Phoenix.PubSub.subscribe(Calmdo.PubSub, "projects")
  end

  defp broadcast_project(%Scope{} = _scope, message) do
    Phoenix.PubSub.broadcast(Calmdo.PubSub, "projects", message)
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects(scope)
      [%Project{}, ...]

  """
  def list_projects(%Scope{} = _scope) do
    from(p in Project, order_by: [desc: p.updated_at])
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(scope, 123)
      %Project{}

      iex> get_project!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(%Scope{} = _scope, id) do
    Repo.get!(Project, id)
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(scope, %{field: value})
      {:ok, %Project{}}

      iex> create_project(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(%Scope{} = scope, attrs) do
    with {:ok, project = %Project{}} <-
           %Project{}
           |> Project.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_project(scope, {:created, project})
      {:ok, project}
    end
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(scope, project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(scope, project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Scope{} = scope, %Project{} = project, attrs) do
    true = project.owner_id == scope.user.id

    with {:ok, project = %Project{}} <-
           project
           |> Project.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_project(scope, {:updated, project})
      {:ok, project}
    end
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(scope, project)
      {:ok, %Project{}}

      iex> delete_project(scope, project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Scope{} = scope, %Project{} = project) do
    true = project.owner_id == scope.user.id

    with {:ok, project = %Project{}} <-
           Repo.delete(project) do
      broadcast_project(scope, {:deleted, project})
      {:ok, project}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(scope, project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Scope{} = scope, %Project{} = project, attrs \\ %{}) do
    true = project.owner_id == scope.user.id

    Project.changeset(project, attrs, scope)
  end

  def list_tasks_for_project(%Scope{} = _scope, project_id) do
    Task
    |> with_task_index_preloads()
    |> with_total_hours()
    |> maybe_where(:project_id, project_id)
    |> order_by_recent()
    |> Repo.all()
  end
end
