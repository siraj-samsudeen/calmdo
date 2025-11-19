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
    ActivityLog
    |> with_preloads()
    |> order_by_recent()
    |> Repo.all()
  end

  def list_activity_logs(%Scope{} = _scope, params) when is_map(params) do
    ActivityLog
    |> with_preloads()
    |> maybe_where(:task_id, params["task_id"])
    |> maybe_where(:project_id, params["project_id"])
    |> maybe_where(:logged_by_id, params["logged_by_id"])
    |> order_by_recent()
    |> Repo.all()
  end

  @doc """
  Returns recent activity logs for the home page feed.
  Defaults to last 2 days (today and yesterday) to improve performance.
  """
  def list_recent_activity_logs(%Scope{} = _scope, days_back \\ 2) do
    cutoff_date = Date.utc_today() |> Date.add(-days_back)

    ActivityLog
    |> with_preloads()
    |> where([al], al.date >= ^cutoff_date)
    |> order_by_recent()
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
    ActivityLog
    |> with_preloads()
    |> join_tasks()
    |> filter_by_project_or_task_project(project_id)
    |> order_by_recent()
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
    ActivityLog.changeset(activity_log, attrs, scope)
  end

  # Query composition helpers
  defp with_preloads(query) do
    from q in query, preload: [:task, :project, :logged_by]
  end

  defp order_by_recent(query) do
    from q in query, order_by: [desc: q.updated_at]
  end

  defp join_tasks(query) do
    from al in query,
      left_join: t in assoc(al, :task),
      as: :task
  end

  defp filter_by_project_or_task_project(query, project_id) do
    from [al, task: t] in query,
      where: al.project_id == ^project_id or t.project_id == ^project_id
  end
end
