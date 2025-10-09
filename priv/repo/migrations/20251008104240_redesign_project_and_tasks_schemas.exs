defmodule Calmdo.Repo.Migrations.RedesignProjectAndTasksSchemas do
  use Ecto.Migration

  def change do
    rename table(:projects), :user_id, to: :owner_id

    # we want to rename user_id to created_by_id as created_by_id is NULL for records in prod
    # hence we drop the existing column then do the renaming
    alter table(:tasks) do
      remove :created_by_id
    end

    rename table(:tasks), :user_id, to: :created_by_id
    rename index(:tasks, [:user_id], name: "tasks_user_id_index"), to: "tasks_created_by_id_index"

    rename table(:activity_logs), :user_id, to: :logged_by_id

    rename index(:activity_logs, [:user_id], name: "activity_logs_user_id_index"),
      to: "activity_logs_logged_by_id_index"

    alter table(:activity_logs) do
      add :date, :date
      add :duration_in_minutes, :integer, default: 0, null: false
      add :billable, :boolean, default: false, null: false
    end
  end
end
