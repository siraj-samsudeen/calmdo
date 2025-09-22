defmodule Calmdo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :notes, :text
      add :status, :string
      add :priority, :string
      add :due_date, :date
      add :assignee_id, references(:users, on_delete: :nothing)
      add :created_by_id, references(:users, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:user_id])

    create index(:tasks, [:assignee_id])
    create index(:tasks, [:created_by_id])
  end
end
