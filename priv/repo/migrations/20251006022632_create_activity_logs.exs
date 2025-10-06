defmodule Calmdo.Repo.Migrations.CreateActivityLogs do
  use Ecto.Migration

  def change do
    create table(:activity_logs) do
      add :duration_in_hours, :integer
      add :notes, :text
      add :task_id, references(:tasks, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:activity_logs, [:user_id])

    create index(:activity_logs, [:task_id])
    create index(:activity_logs, [:project_id])
  end
end
