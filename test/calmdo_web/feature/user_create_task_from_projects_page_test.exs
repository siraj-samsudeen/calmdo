defmodule CalmdoWeb.UserCreateTaskFromProjectsPageTest do
  use CalmdoWeb.ConnCase

  import PhoenixTest
  import Calmdo.TasksFixtures

  setup :register_and_log_in_user

  test "user creates a new task from project page", %{conn: conn, scope: scope} do
    project = project_fixture(scope)

    conn
    |> visit(~p"/projects/#{project}")
    |> click_link("main a", "New Task")
    |> fill_in("Title", with: "some task")
    |> click_button("Save")
    |> assert_text("some task")
    |> assert_path(~p"/projects/#{project}")
  end
end
