defmodule Calmdo.TestHelpers do
  import PhoenixTest

  def create_new_log(conn, hours: hours, notes: notes) do
    conn
    |> fill_in("Duration in hours", with: hours)
    |> fill_in("Notes", with: notes)
    |> click_button("Save Activity log")
  end

  def create_new_task(conn, name: name) do
    conn
    |> fill_in("Title", with: name)
    |> click_button("Save")
  end
end
