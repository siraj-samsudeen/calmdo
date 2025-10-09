defmodule Calmdo.Tasks.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :completed, :boolean, default: false
    belongs_to :owner, Calmdo.Accounts.User
    has_many :tasks, Calmdo.Tasks.Task
    has_many :activity_logs, Calmdo.ActivityLogs.ActivityLog

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs, user_scope) do
    project
    |> cast(attrs, [:name, :completed])
    |> validate_required([:name, :completed])
    |> put_change(:owner_id, user_scope.user.id)
  end
end
