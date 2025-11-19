defmodule CalmdoWeb.ProjectLiveTest do
  use CalmdoWeb.ConnCase

  import Calmdo.TasksFixtures

  @create_attrs %{name: "some name", completed: true}
  @update_attrs %{name: "some updated name", completed: false}
  @invalid_attrs %{name: nil, completed: false}

  setup :register_and_log_in_user

  defp create_project(%{scope: scope}) do
    project = project_fixture(scope)

    %{project: project}
  end

  describe "Index" do
    setup [:create_project]

    test "lists all projects", %{conn: conn, project: project} do
      conn
      |> visit(~p"/projects")
      |> assert_text("Listing Projects")
      |> assert_text(project.name)
    end

    test "saves new project", %{conn: conn} do
      conn
      |> visit(~p"/projects")
      |> click_link("New Project")
      |> assert_path(~p"/projects/new")
      |> assert_text("New Project")
      |> fill_in("Name", with: @invalid_attrs.name)
      |> assert_text("can't be blank")
      |> fill_in("Name", with: @create_attrs.name)
      |> submit()
      |> assert_path(~p"/projects")
      |> assert_text("Project created successfully")
      |> assert_text("some name")
    end

    test "updates project in listing", %{conn: conn, project: project} do
      conn
      |> visit(~p"/projects")
      |> click_link("#projects-#{project.id} a", "Edit")
      |> assert_path(~p"/projects/#{project}/edit")
      |> assert_text("Edit Project")
      |> fill_in("Name", with: @invalid_attrs.name)
      |> assert_text("can't be blank")
      |> fill_in("Name", with: @update_attrs.name)
      |> submit()
      |> assert_path(~p"/projects")
      |> assert_text("Project updated successfully")
      |> assert_text("some updated name")
    end

    test "deletes project in listing", %{conn: conn, project: project} do
      conn
      |> visit(~p"/projects")
      |> click_link("#projects-#{project.id} a", "Delete")
      |> refute_has("#projects-#{project.id}")
    end
  end

  describe "Show" do
    setup [:create_project]

    test "displays project", %{conn: conn, project: project} do
      conn
      |> visit(~p"/projects/#{project}")
      |> assert_text(project.name)
      |> assert_text("Project overview")
    end

    test "updates project and returns to show", %{conn: conn, project: project} do
      conn
      |> visit(~p"/projects/#{project}")
      |> click_link("a", "Edit")
      |> assert_path(~p"/projects/#{project}/edit", query_params: %{return_to: "show"})
      |> assert_text("Edit Project")
      |> fill_in("Name", with: @invalid_attrs.name)
      |> assert_text("can't be blank")
      |> fill_in("Name", with: @update_attrs.name)
      |> submit()
      |> assert_path(~p"/projects/#{project}")
      |> assert_text("Project updated successfully")
      |> assert_text("some updated name")
    end
  end
end
