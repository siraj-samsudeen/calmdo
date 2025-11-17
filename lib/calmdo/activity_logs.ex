defmodule Calmdo.ActivityLogs do
  @moduledoc """
  The ActivityLogs context.
  """

  import Ecto.Query, warn: false
  import Calmdo.EctoHelpers
  alias Calmdo.Repo

  alias Calmdo.ActivityLogs.ActivityLog
  alias Calmdo.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any activity_log changes.

  The broadcasted messages match the pattern:

    * {:created, %ActivityLog{}}
    * {:updated, %ActivityLog{}}
    * {:deleted, %ActivityLog{}}

  """
  def subscribe_activity_logs(%Scope{} = _scope) do
    Phoenix.PubSub.subscribe(Calmdo.PubSub, "activity_logs")
  end

  defp broadcast_activity_log(%Scope{} = _scope, message) do
    Phoenix.PubSub.broadcast(Calmdo.PubSub, "activity_logs", message)
  end

  @doc """
  Returns the list of activity_logs.

  ## Examples

      iex> list_activity_logs(scope)
      [%ActivityLog{}, ...]

  """
  def list_activity_logs(%Scope{} = _scope) do
    base_activity_log_query()
    |> Repo.all()
  end

  def list_activity_logs(%Scope{} = _scope, opts) when is_list(opts) do
    task_id = Keyword.get(opts, :task_id)
    project_id = Keyword.get(opts, :project_id)
    logged_by_id = Keyword.get(opts, :logged_by_id)

    base_activity_log_query()
    |> maybe_where(:task_id, task_id)
    |> maybe_where(:project_id, project_id)
    |> maybe_where(:logged_by_id, logged_by_id)
    |> Repo.all()
  end

  @doc """
  Gets a single activity_log.

  Raises `Ecto.NoResultsError` if the Activity log does not exist.

  ## Examples

      iex> get_activity_log!(scope, 123)
      %ActivityLog{}

      iex> get_activity_log!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_activity_log!(%Scope{} = _scope, id) do
    ActivityLog
    |> Repo.get!(id)
    |> Repo.preload([:task, :project])
  end

  def list_activity_logs_for_project(%Scope{} = _scope, project_id) do
    from(al in ActivityLog,
      left_join: t in assoc(al, :task),
      where: al.project_id == ^project_id or t.project_id == ^project_id,
      preload: [:project, :task]
    )
    |> Repo.all()
  end

  @doc """
  Creates a activity_log.

  ## Examples

      iex> create_activity_log(scope, %{field: value})
      {:ok, %ActivityLog{}}

      iex> create_activity_log(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity_log(%Scope{} = scope, attrs) do
    with {:ok, activity_log = %ActivityLog{}} <-
           %ActivityLog{}
           |> ActivityLog.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_activity_log(scope, {:created, activity_log})
      {:ok, activity_log}
    end
  end

  @doc """
  Updates a activity_log.

  ## Examples

      iex> update_activity_log(scope, activity_log, %{field: new_value})
      {:ok, %ActivityLog{}}

      iex> update_activity_log(scope, activity_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity_log(%Scope{} = scope, %ActivityLog{} = activity_log, attrs) do
    true = activity_log.logged_by_id == scope.user.id

    with {:ok, activity_log = %ActivityLog{}} <-
           activity_log
           |> ActivityLog.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_activity_log(scope, {:updated, activity_log})
      {:ok, activity_log}
    end
  end

  @doc """
  Deletes a activity_log.

  ## Examples

      iex> delete_activity_log(scope, activity_log)
      {:ok, %ActivityLog{}}

      iex> delete_activity_log(scope, activity_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity_log(%Scope{} = scope, %ActivityLog{} = activity_log) do
    true = activity_log.logged_by_id == scope.user.id

    with {:ok, activity_log = %ActivityLog{}} <-
           Repo.delete(activity_log) do
      broadcast_activity_log(scope, {:deleted, activity_log})
      {:ok, activity_log}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity_log changes.

  ## Examples

      iex> change_activity_log(scope, activity_log)
      %Ecto.Changeset{data: %ActivityLog{}}

  """
  def change_activity_log(%Scope{} = scope, %ActivityLog{} = activity_log, attrs \\ %{}) do
    true = activity_log.logged_by_id == scope.user.id

    ActivityLog.changeset(activity_log, attrs, scope)
  end

  defp base_activity_log_query do
    from al in ActivityLog,
      preload: [:task, :project]
  end
end
