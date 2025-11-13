defmodule CalmdoWeb.UserCreateLogFromProjectsPageTest do
  use CalmdoWeb.ConnCase

  import Calmdo.TasksFixtures

  setup :register_and_log_in_user

  test "user creates a new log without task from project page", %{conn: conn, scope: scope} do
    project = project_fixture(scope)

    conn
    |> visit(~p"/projects/#{project}")
    |> click_link("main a", "New Log")
    |> create_new_log(hours: 1, notes: "some notes")
    |> assert_text("Activity log created successfully")
    |> assert_path(~p"/projects/#{project}")
  end
end
