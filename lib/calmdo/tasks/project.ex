defmodule Calmdo.Tasks.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :completed, :boolean, default: false
    belongs_to :user, Calmdo.Accounts.User
    has_many :tasks, Calmdo.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs, user_scope) do
    project
    |> cast(attrs, [:name, :completed])
    |> validate_required([:name, :completed])
    |> put_change(:user_id, user_scope.user.id)
  end
end
