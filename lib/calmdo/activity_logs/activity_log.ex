defmodule Calmdo.ActivityLogs.ActivityLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activity_logs" do
    field :duration_in_hours, :integer
    field :notes, :string
    field :task_id, :id
    field :project_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity_log, attrs, user_scope) do
    activity_log
    |> cast(attrs, [:duration_in_hours, :notes])
    |> validate_required([:duration_in_hours, :notes])
    |> put_change(:user_id, user_scope.user.id)
  end
end
