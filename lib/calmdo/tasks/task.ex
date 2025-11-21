defmodule Calmdo.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :notes, :string
    field :status, Ecto.Enum, values: [:started, :work_in_progress, :completed]
    field :priority, Ecto.Enum, values: [:low, :medium, :high]
    field :due_date, :date

    # Virtual field populated by database aggregation
    field :total_hours, :float, virtual: true

    belongs_to :created_by, Calmdo.Accounts.User
    belongs_to :assignee, Calmdo.Accounts.User
    belongs_to :project, Calmdo.Projects.Project

    has_many :activity_logs, Calmdo.ActivityLogs.ActivityLog

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs, user_scope) do
    task
    |> cast(attrs, [
      :title,
      :notes,
      :status,
      :priority,
      :due_date,
      :assignee_id,
      :project_id
    ])
    |> validate_required([:title])
    |> put_change(:created_by_id, user_scope.user.id)
  end
end
