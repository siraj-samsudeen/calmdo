defmodule Calmdo.ActivityLogs.ActivityLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activity_logs" do
    field :duration_in_hours, :integer
    field :notes, :string
    belongs_to :task, Calmdo.Tasks.Task
    belongs_to :project, Calmdo.Tasks.Project
    belongs_to :user, Calmdo.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity_log, attrs, user_scope) do
    activity_log
    |> cast(attrs, [:duration_in_hours, :notes, :task_id, :project_id])
    |> validate_required([:duration_in_hours, :notes, :project_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end
