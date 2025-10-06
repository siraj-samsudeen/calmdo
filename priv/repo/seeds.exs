# Script for populating the database with development fixtures.
#
#     mix run priv/repo/seeds.exs

alias Calmdo.{ActivityLogs, Repo, Tasks}
alias Calmdo.Accounts.{Scope, User}

seed_user_id = 1

user = Repo.get!(User, seed_user_id)

scope = Scope.for_user(user)

existing_projects = Tasks.list_projects(scope)

projects =
  if existing_projects == [] do
    Enum.map([
      %{name: "Strategy & Planning", completed: false},
      %{name: "Product Delivery", completed: false},
      %{name: "Team Rituals", completed: true}
    ], fn attrs ->
      {:ok, project} = Tasks.create_project(scope, attrs)
      project
    end)
  else
    existing_projects
  end

existing_tasks = Tasks.list_tasks(scope)

if existing_tasks == [] do
  today = Date.utc_today()

  [
    %{title: "Outline Calmdo roadmap", notes: "Shape the Q2 milestones.", status: :started, priority: :high, due_date: Date.add(today, 3)},
    %{title: "Draft onboarding checklist", notes: "Gather best practices for new teammates.", status: :work_in_progress, priority: :medium, due_date: Date.add(today, 7)},
    %{title: "Polish marketing site", notes: "Review copy and interactions before launch.", status: :started, priority: :medium, due_date: Date.add(today, 14)},
    %{title: "Sprint retrospective", notes: "Capture wins, challenges, and next steps.", status: :completed, priority: :low, due_date: today},
    %{title: "Inbox zero", notes: "Sweep through customer feedback.", status: :work_in_progress, priority: :high, due_date: Date.add(today, 1)}
  ]
  |> Enum.each(fn attrs ->
    {:ok, _task} = Tasks.create_task(scope, attrs)
  end)
end

existing_logs = ActivityLogs.list_activity_logs(scope)

if existing_logs == [] do
  [
    %{duration_in_hours: 2, notes: "Whiteboarded the Calmdo information architecture."},
    %{duration_in_hours: 1, notes: "Refined sprint goals with the product squad."},
    %{duration_in_hours: 3, notes: "Prepared a customer update deck."}
  ]
  |> Enum.each(fn attrs ->
    {:ok, _log} = ActivityLogs.create_activity_log(scope, attrs)
  end)
end

IO.puts("Seeded Calmdo demo data for user ##{seed_user_id} (#{user.email}).")
