if Mix.env() != :test do
  # Script for populating the database with development fixtures.
  #
  #     mix run priv/repo/seeds.exs

  alias Calmdo.{ActivityLogs, Accounts, Repo, Tasks}
  alias Calmdo.Accounts.{Scope, User}

  seed_email = "mailsiraj@gmail.com"

  user =
    Repo.get_by(User, email: seed_email) ||
      case Accounts.register_user(%{email: seed_email}) do
        {:ok, created_user} ->
          created_user

        {:error, changeset} ->
          raise "Failed to create seed user: #{inspect(changeset.errors)}"
      end

  scope = Scope.for_user(user)
  seed_user_id = user.id

  projects =
    case Tasks.list_projects(scope) do
      [] ->
        [
          %{name: "Product Discovery", completed: false},
          %{name: "Engineering Enablement", completed: false}
        ]
        |> Enum.map(fn attrs ->
          {:ok, project} = Tasks.create_project(scope, attrs)
          project
        end)

      existing ->
        existing
    end

  project_by_name = Map.new(projects, &{&1.name, &1})

  existing_tasks = Tasks.list_tasks(scope)

  if existing_tasks == [] do
    today = Date.utc_today()

    [
      %{
        project: "Product Discovery",
        title: "Shape Q2 roadmap",
        notes: "Facilitate product strategy workshop with stakeholders.",
        status: :started,
        priority: :high,
        due_date: Date.add(today, 5),
        assignee: :self
      },
      %{
        project: "Product Discovery",
        title: "Validate onboarding hypotheses",
        notes: "Pair with design to run quick usability tests.",
        status: :work_in_progress,
        priority: :medium,
        due_date: Date.add(today, 10)
      },
      %{
        project: "Engineering Enablement",
        title: "Automate release pipeline",
        notes: "Stand up CI/CD templates and documentation.",
        status: :work_in_progress,
        priority: :medium,
        due_date: Date.add(today, 14),
        assignee: :self
      },
      %{
        project: "Engineering Enablement",
        title: "Refine observability backlog",
        status: :started,
        priority: :low
      },
      %{
        project: "Engineering Enablement",
        title: "Archive deprecated microservice",
        notes: "Confirm traffic is zero, then remove operational hooks.",
        status: :completed,
        priority: :low,
        due_date: Date.add(today, -2)
      }
    ]
    |> Enum.each(fn attrs ->
      project = Map.fetch!(project_by_name, attrs.project)

      assignee_id =
        case Map.get(attrs, :assignee) do
          :self -> seed_user_id
          _ -> nil
        end

      payload =
        attrs
        |> Map.drop([:project, :assignee])
        |> Map.put(:project_id, project.id)

      payload =
        case assignee_id do
          nil -> payload
          value -> Map.put(payload, :assignee_id, value)
        end

      {:ok, _task} = Tasks.create_task(scope, payload)
    end)
  end

  existing_logs = ActivityLogs.list_activity_logs(scope)

  if existing_logs == [] do
    today = Date.utc_today()
    tasks_by_title = Map.new(Tasks.list_tasks(scope), &{&1.title, &1})

    [
      %{
        project: "Product Discovery",
        date: today,
        duration_in_hours: 2,
        duration_in_minutes: 30,
        notes: "Partnered with CS to capture voice-of-customer themes.",
        billable: false
      },
      %{
        task: "Automate release pipeline",
        date: Date.add(today, -1),
        duration_in_hours: 1,
        duration_in_minutes: 0,
        notes: "Paired with DevOps to verify deployment gates.",
        billable: true
      },
      %{
        task: "Refine observability backlog",
        date: Date.add(today, -2),
        duration_in_hours: 0,
        duration_in_minutes: 45,
        notes: "Prioritized log noise cleanup with platform squad.",
        billable: false
      }
    ]
    |> Enum.each(fn attrs ->
      payload =
        case {Map.get(attrs, :project), Map.get(attrs, :task)} do
          {project_name, nil} when is_binary(project_name) ->
            project = Map.fetch!(project_by_name, project_name)

            attrs
            |> Map.drop([:project, :task])
            |> Map.put(:project_id, project.id)

          {_, task_title} when is_binary(task_title) ->
            %{id: task_id, project_id: project_id} = Map.fetch!(tasks_by_title, task_title)

            attrs
            |> Map.drop([:project, :task])
            |> Map.merge(%{task_id: task_id, project_id: project_id})
        end

      {:ok, _log} = ActivityLogs.create_activity_log(scope, payload)
    end)
  end

  IO.puts("Seeded Calmdo demo data for user ##{seed_user_id} (#{user.email}).")
end
