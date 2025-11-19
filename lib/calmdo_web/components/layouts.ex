defmodule CalmdoWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use CalmdoWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :projects, :list,
    default: [],
    doc: "optional project entries to surface in the sidebar"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar sticky top-0 z-40 bg-primary border-b border-base-300 px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <label
          for="layout-drawer"
          class="btn btn-square btn-ghost text-primary-content hover:text-primary focus:text-primary lg:hidden"
          aria-label="Toggle menu"
        >
          <.icon name="hero-bars-3" />
        </label>
        <.link
          href={~p"/"}
          class="btn btn-ghost text-lg text-primary-content hover:text-primary focus:text-primary"
        >
          Calmdo
        </.link>
      </div>
      <div class="flex-none">
        <ul class="flex gap-4 items-center">
          <li><.theme_toggle /></li>
          <%= if @current_scope && @current_scope.user do %>
            <li>
              <div class="dropdown dropdown-end">
                <label tabindex="0" class="btn btn-ghost gap-2 group">
                  <div class="avatar avatar-placeholder">
                    <div class="size-8 rounded-full bg-base-300 text-base-content">
                      <span>{user_initial(@current_scope.user)}</span>
                    </div>
                  </div>
                  <span class="hidden sm:inline max-w-[220px] truncate text-primary-content group-hover:text-primary group-focus:text-primary">
                    {display_user_email(@current_scope.user)}
                  </span>
                </label>
                <ul
                  tabindex="0"
                  class="menu dropdown-content mt-3 w-56 rounded-box bg-base-200 p-2 shadow-lg"
                >
                  <li class="menu-title">{display_user_email(@current_scope.user)}</li>
                  <li><.link href={~p"/users/settings"}>Settings</.link></li>
                  <li><.link href={~p"/users/log-out"} method="delete">Log out</.link></li>
                </ul>
              </div>
            </li>
          <% else %>
            <li>
              <.link href={~p"/users/log-in"} class="btn btn-ghost btn-sm">
                Log in
              </.link>
            </li>
            <li>
              <.link href={~p"/users/register"} class="btn btn-primary btn-sm">
                Sign up
              </.link>
            </li>
          <% end %>
        </ul>
      </div>
    </header>

    <div class="drawer lg:drawer-open min-h-[calc(100vh-4rem)]">
      <input id="layout-drawer" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content flex">
        <main class="flex-1 bg-base-100">
          <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
            <div class="rounded-lg bg-base-100 p-6">
              {render_slot(@inner_block)}
            </div>
          </div>
        </main>
      </div>
      <div class="drawer-side h-[calc(100dvh-4rem)] top-16">
        <label for="layout-drawer" class="drawer-overlay"></label>

        <aside class="min-w-3xs h-full bg-base-200 border-r border-base-300 text-sm">
          <nav class="flex flex-1 flex-col gap-6">
            <ul class="menu bg-base-200 rounded-box w-full">
              <.sidebar_section
                :if={@current_scope}
                heading="Quick Links"
                links={[
                  %{label: "My Tasks", path: ~p"/tasks?assignee_id=#{@current_scope.user}"},
                  %{
                    label: "My Activity Logs",
                    path: ~p"/activity_logs?logged_by_id=#{@current_scope.user}"
                  }
                ]}
              />
              <.sidebar_section
                heading="Reference"
                links={[
                  %{label: "Projects", path: ~p"/projects"},
                  %{label: "Tasks", path: ~p"/tasks"},
                  %{label: "Activity Logs", path: ~p"/activity_logs"}
                ]}
              />
            </ul>
          </nav>
        </aside>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :heading, :string, required: true
  attr :links, :list, required: true

  def sidebar_section(assigns) do
    ~H"""
    <li>
      <h2 class="menu-title">{@heading}</h2>
      <ul>
        <li :for={link <- @links}>
          <.link
            navigate={link.path}
            class="btn btn-ghost btn-block justify-start"
          >
            {link.label}
          </.link>
        </li>
      </ul>
    </li>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  defp user_initial(%{email: email}) when is_binary(email) do
    email
    |> String.trim()
    |> String.first()
    |> case do
      nil -> "?"
      letter -> String.upcase(letter)
    end
  end

  defp user_initial(_), do: "?"

  defp display_user_email(%{email: email}) when is_binary(email), do: email
  defp display_user_email(_), do: "Account"
end
