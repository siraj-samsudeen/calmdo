defmodule CalmdoWeb.UserRecordLogFromProjectsPageTest do
  use CalmdoWeb.ConnCase

  import Calmdo.ProjectsFixtures
  import Calmdo.TasksFixtures

  setup :register_and_log_in_user

  test "user is redirected back to project page after log is recorded for a specific task from project page",
       %{
         conn: conn,
         scope: scope
       } do
    project = project_fixture(scope)
    task_fixture(scope, %{project_id: project.id})

    conn
    |> visit(~p"/projects/#{project}")
    |> click_link("Log Time")
    |> create_new_log(hours: 1, notes: "some notes")
    |> assert_text("Activity log created successfully")
    |> assert_path(~p"/projects/#{project}")
  end
end
