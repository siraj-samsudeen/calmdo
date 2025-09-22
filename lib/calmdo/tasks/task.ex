defmodule Calmdo.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :notes, :string
    field :status, Ecto.Enum, values: [:started, :work_in_progress, :completed]
    field :priority, Ecto.Enum, values: [:low, :medium, :high]
    field :due_date, :date
    field :assignee_id, :id
    field :created_by_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs, user_scope) do
    task
    |> cast(attrs, [:title, :notes, :status, :priority, :due_date])
    |> validate_required([:title, :notes, :status, :priority, :due_date])
    |> put_change(:user_id, user_scope.user.id)
  end
end
