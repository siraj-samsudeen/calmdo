defmodule Calmdo.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Calmdo.Repo

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
end
