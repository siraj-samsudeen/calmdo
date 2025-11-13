defmodule CalmdoWeb.UserReadsLogNotesInMarkdownTest do
  use CalmdoWeb.ConnCase

  import Calmdo.ActivityLogsFixtures

  setup :register_and_log_in_user

  test "renders markdown notes as HTML links in both list and detail pages", %{
    conn: conn,
    scope: scope
  } do
    markdown = "[Click here](https://example.com)"

    activity_log = activity_log_fixture(scope, %{notes: markdown})

    conn
    |> visit(~p"/activity_logs")
    |> assert_has("a[href='https://example.com']", text: "Click here")
    |> visit(~p"/activity_logs/#{activity_log}")
    |> assert_has("a[href='https://example.com']", text: "Click here")
  end
end
