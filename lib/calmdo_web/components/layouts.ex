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
    <header class="navbar sticky top-0 z-40 bg-primary text-primary-content shadow">
      <div class="flex items-center gap-3 px-4 sm:px-6 lg:px-8 w-full">
        <label
          for="layout-drawer"
          class="btn btn-square btn-ghost lg:hidden"
          aria-label="Toggle menu"
        >
          <.icon name="hero-bars-3" />
        </label>
        <.link href={~p"/"} class="text-lg font-semibold tracking-tight">
          Calmdo
        </.link>

        <div class="ml-auto flex items-center gap-3">
          <div class="hidden md:block"><.theme_toggle /></div>
          <%= if @current_scope && @current_scope.user do %>
            <div class="dropdown dropdown-end">
              <label tabindex="0" class="btn btn-ghost gap-2">
                <div class="avatar placeholder">
                  <div class="w-8 rounded-full bg-primary-content/20 text-primary-content">
                    <span>{user_initial(@current_scope.user)}</span>
                  </div>
                </div>
                <span class="hidden sm:inline max-w-[220px] truncate">
                  {display_user_email(@current_scope.user)}
                </span>
              </label>
              <ul
                tabindex="0"
                class="menu dropdown-content mt-3 w-56 rounded-box bg-base-100 text-base-content p-2 shadow"
              >
                <li class="menu-title">{display_user_email(@current_scope.user)}</li>
                <li><.link href={~p"/users/settings"}>Settings</.link></li>
                <li><.link href={~p"/users/log-out"} method="delete">Log out</.link></li>
              </ul>
            </div>
          <% else %>
            <div class="flex items-center gap-2">
              <.link href={~p"/users/log-in"} class="btn btn-sm btn-ghost text-primary-content">
                Log in
              </.link>
              <.link href={~p"/users/register"} class="btn btn-sm btn-secondary">
                Sign up
              </.link>
            </div>
          <% end %>
        </div>
      </div>
    </header>

    <div class="drawer lg:drawer-open min-h-[calc(100vh-4rem)] bg-base-200">
      <input id="layout-drawer" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content flex min-h-[calc(100vh-4rem)] flex-col">
        <main class="flex flex-1 flex-col bg-base-200">
          <div class="mx-auto flex w-full max-w-6xl flex-1 px-4 py-6 sm:px-6 lg:px-8">
            <div class="flex-1 space-y-6">
              <div class="rounded-lg border bg-base-100 p-6 shadow-sm">
                {render_slot(@inner_block)}
              </div>
            </div>
          </div>
        </main>
      </div>
      <div class="drawer-side">
        <label for="layout-drawer" class="drawer-overlay"></label>
        <aside class="flex h-full w-72 flex-col border-r bg-base-100 text-sm">
          <nav class="flex flex-1 flex-col gap-6 px-4 py-6">
            <section :if={@current_scope}>
              <h2 class="mb-2 px-2 text-xs font-semibold uppercase opacity-60">Quick Links</h2>
              <ul class="space-y-1">
                <li>
                  <.link
                    href={~p"/tasks?assigned_id=#{@current_scope.user}"}
                    class="btn btn-ghost btn-block justify-start"
                  >
                    My Tasks
                  </.link>
                </li>
                <li>
                  <.link
                    href={~p"/activity_logs?logged_by_id=#{@current_scope.user}"}
                    class="btn btn-ghost btn-block justify-start"
                  >
                    My Logs
                  </.link>
                </li>
              </ul>
            </section>

            <section>
              <h2 class="mb-2 px-2 text-xs font-semibold uppercase opacity-60">Reference</h2>
              <ul class="space-y-1">
                <li>
                  <.link href={~p"/projects"} class="btn btn-ghost btn-block justify-start">
                    Projects
                  </.link>
                </li>
                <li>
                  <.link href={~p"/tasks"} class="btn btn-ghost btn-block justify-start">
                    Tasks
                  </.link>
                </li>
                <li>
                  <.link href={~p"/activity_logs"} class="btn btn-ghost btn-block justify-start">
                    Activity Logs
                  </.link>
                </li>
              </ul>
            </section>
          </nav>
        </aside>
      </div>
    </div>

    <.flash_group flash={@flash} />
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
    <div class="relative flex h-8 w-32 items-center rounded-full border border-white/40 bg-white/15 backdrop-blur shadow-inner">
      <div class="absolute inset-y-1 left-1 w-1/3 rounded-full bg-white text-[#2563eb] shadow transition-all duration-200 ease-out [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3" />

      <button
        class="z-10 flex w-1/3 cursor-pointer items-center justify-center text-xs font-semibold text-[#2563eb]"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4" />
      </button>

      <button
        class="z-10 flex w-1/3 cursor-pointer items-center justify-center text-xs font-semibold text-[#2563eb]"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4" />
      </button>

      <button
        class="z-10 flex w-1/3 cursor-pointer items-center justify-center text-xs font-semibold text-[#2563eb]"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4" />
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
