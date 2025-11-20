defmodule CalmdoWeb.ProjectsE2eTest do
  use CalmdoWeb.ConnCase
  import Calmdo.ProjectsFixtures

  setup :register_and_log_in_user

  describe "project e2e" do
    test "project CRUD", %{conn: conn} do
      conn
      |> visit(~p"/projects")
      |> click_link("New Project")
      |> fill_in("Name", with: "Test Project 1")
      |> submit()
      |> assert_text("Test Project 1")

      # visit the show page
      |> click_link("Show")
      |> assert_text("Test Project 1")
      # back to project lists page
      |> click_link("Back")

      # edit the project, assuming a single project
      |> click_link("Edit")
      |> fill_in("Name", with: "Test Project 1 updated")
      |> submit()
      |> assert_text("Test Project 1 updated")

      # delete the project, assuming a single project
      |> click_link("Delete")
      |> refute_text("Test Project 1 updated")
    end

    # separate test to check more complex features not covered in CRUD
    test "show project", %{conn: conn, scope: scope} do
      project = project_fixture(scope, name: "Product Launch")

      conn
      |> visit(~p"/projects/#{project}")
      |> assert_text("Product Launch")
    end
  end
end
