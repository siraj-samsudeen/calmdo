defmodule Calmdo.ActivityLogs do
  @moduledoc """
  The ActivityLogs context.
  """

  import Ecto.Query, warn: false
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
  def subscribe_activity_logs(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Calmdo.PubSub, "user:#{key}:activity_logs")
  end

  defp broadcast_activity_log(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Calmdo.PubSub, "user:#{key}:activity_logs", message)
  end

  @doc """
  Returns the list of activity_logs.

  ## Examples

      iex> list_activity_logs(scope)
      [%ActivityLog{}, ...]

  """
  def list_activity_logs(%Scope{} = scope) do
    Repo.all_by(ActivityLog, user_id: scope.user.id)
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
  def get_activity_log!(%Scope{} = scope, id) do
    Repo.get_by!(ActivityLog, id: id, user_id: scope.user.id)
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
    true = activity_log.user_id == scope.user.id

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
    true = activity_log.user_id == scope.user.id

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
    true = activity_log.user_id == scope.user.id

    ActivityLog.changeset(activity_log, attrs, scope)
  end
end
