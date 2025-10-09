defmodule CalmdoWeb.ActivityLogLiveTest do
  use CalmdoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Calmdo.ActivityLogsFixtures
  import Calmdo.TasksFixtures

  @create_attrs %{duration_in_hours: 42, notes: "some notes", date: "2025-01-01"}
  @update_attrs %{duration_in_hours: 43, notes: "some updated notes"}
  @invalid_attrs %{duration_in_hours: nil, notes: nil}

  setup :register_and_log_in_user

  defp create_activity_log(%{scope: scope}) do
    activity_log = activity_log_fixture(scope)

    %{activity_log: activity_log}
  end

  describe "Index" do
    setup [:create_activity_log]

    test "lists all activity_logs", %{conn: conn, activity_log: activity_log} do
      {:ok, _index_live, html} = live(conn, ~p"/activity_logs")

      assert html =~ "Listing Activity logs"
      assert html =~ activity_log.notes
    end

    test "saves new activity_log", %{conn: conn, scope: scope} do
      project = project_fixture(scope)
      create_attrs = Map.put(@create_attrs, :project_id, project.id)

      {:ok, index_live, _html} = live(conn, ~p"/activity_logs")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Activity log")
               |> render_click()
               |> follow_redirect(conn, ~p"/activity_logs/new")

      assert render(form_live) =~ "New Activity log"

      assert form_live
             |> form("#activity_log-form", activity_log: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#activity_log-form", activity_log: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/activity_logs")

      html = render(index_live)
      assert html =~ "Activity log created successfully"
      assert html =~ "some notes"
    end

    test "updates activity_log in listing", %{conn: conn, activity_log: activity_log} do
      {:ok, index_live, _html} = live(conn, ~p"/activity_logs")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#activity_logs-#{activity_log.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/activity_logs/#{activity_log}/edit")

      assert render(form_live) =~ "Edit Activity log"

      assert form_live
             |> form("#activity_log-form", activity_log: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#activity_log-form", activity_log: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/activity_logs")

      html = render(index_live)
      assert html =~ "Activity log updated successfully"
      assert html =~ "some updated notes"
    end

    test "deletes activity_log in listing", %{conn: conn, activity_log: activity_log} do
      {:ok, index_live, _html} = live(conn, ~p"/activity_logs")

      assert index_live
             |> element("#activity_logs-#{activity_log.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#activity_logs-#{activity_log.id}")
    end
  end

  describe "Show" do
    setup [:create_activity_log]

    test "displays activity_log", %{conn: conn, activity_log: activity_log} do
      {:ok, _show_live, html} = live(conn, ~p"/activity_logs/#{activity_log}")

      assert html =~ "Show Activity log"
      assert html =~ activity_log.notes
    end

    test "updates activity_log and returns to show", %{conn: conn, activity_log: activity_log} do
      {:ok, show_live, _html} = live(conn, ~p"/activity_logs/#{activity_log}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/activity_logs/#{activity_log}/edit?return_to=show")

      assert render(form_live) =~ "Edit Activity log"

      assert form_live
             |> form("#activity_log-form", activity_log: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#activity_log-form", activity_log: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/activity_logs/#{activity_log}")

      html = render(show_live)
      assert html =~ "Activity log updated successfully"
      assert html =~ "some updated notes"
    end
  end
end
