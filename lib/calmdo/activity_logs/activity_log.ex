defmodule Calmdo.ActivityLogs.ActivityLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activity_logs" do
    field :date, :date
    field :duration_in_hours, :integer
    field :duration_in_minutes, :integer
    field :notes, :string
    field :billable, :boolean
    belongs_to :task, Calmdo.Tasks.Task
    belongs_to :project, Calmdo.Projects.Project
    belongs_to :logged_by, Calmdo.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity_log, attrs, user_scope) do
    activity_log
    |> cast(attrs, [
      :date,
      :duration_in_hours,
      :duration_in_minutes,
      :notes,
      :billable,
      :task_id,
      :project_id
    ])
    |> validate_required([:date, :notes])
    |> validate_project_or_task_present()
    |> validate_duration_present()
    |> put_change(:logged_by_id, user_scope.user.id)
  end

  defp validate_project_or_task_present(changeset) do
    project_id = get_field(changeset, :project_id)
    task_id = get_field(changeset, :task_id)

    if is_nil(project_id) and is_nil(task_id) do
      changeset
      |> add_error(:project_id, "select a project or task")
      |> add_error(:task_id, "select a project or task")
    else
      changeset
    end
  end

  defp validate_duration_present(changeset) do
    hours = get_field(changeset, :duration_in_hours) || 0
    minutes = get_field(changeset, :duration_in_minutes) || 0

    if hours > 0 or minutes > 0 do
      changeset
    else
      changeset
      |> add_error(:duration_in_hours, "enter duration in hours or minutes")
      |> add_error(:duration_in_minutes, "enter duration in hours or minutes")
    end
  end
end
