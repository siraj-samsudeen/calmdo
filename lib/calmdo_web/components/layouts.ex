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
    <div class="drawer lg:drawer-open min-h-screen bg-[#2f343f] text-slate-100">
      <input id="layout-drawer" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content flex min-h-screen flex-col">
        <header class="sticky top-0 z-20 h-16 border-b border-[#1d4ed8]/60 bg-[#2563eb] text-white shadow-xl">
          <div class="mx-auto flex w-full max-w-6xl items-center gap-4 px-4 sm:px-6 lg:px-10">
            <div class="flex-none lg:hidden">
              <label
                for="layout-drawer"
                class="btn btn-ghost btn-square text-white"
                aria-label="Toggle sidebar"
              >
                <.icon name="hero-bars-3" class="size-5" />
              </label>
            </div>
            <div class="flex-1">
              <a
                href={~p"/"}
                class="btn btn-ghost text-lg font-semibold normal-case text-white hover:bg-white/10"
              >
                Calmdo
              </a>
            </div>
            <div class="flex items-center gap-3 pr-1">
              <div class="rounded-full border border-white/40 bg-white/80 px-3 py-1 shadow-sm">
                <.theme_toggle />
              </div>
              <%= if @current_scope && @current_scope.user do %>
                <div class="dropdown dropdown-end">
                  <label tabindex="0" class="btn btn-ghost btn-circle avatar placeholder text-white">
                    <div class="w-10 rounded-full bg-white text-[#2563eb]">
                      <span>{user_initial(@current_scope.user)}</span>
                    </div>
                  </label>
                  <ul
                    tabindex="0"
                    class="menu dropdown-content mt-3 w-56 rounded-box bg-white/95 p-2 text-slate-800 shadow-2xl"
                  >
                    <li class="menu-title">{display_user_email(@current_scope.user)}</li>
                    <li>
                      <.link href={~p"/users/settings"}>Settings</.link>
                    </li>
                    <li>
                      <.link href={~p"/users/log-out"} method="delete">Log out</.link>
                    </li>
                  </ul>
                </div>
              <% else %>
                <div class="flex items-center gap-2">
                  <.link
                    href={~p"/users/log-in"}
                    class="btn btn-sm border border-white/30 bg-white/20 text-white hover:bg-white/30"
                  >
                    Log in
                  </.link>
                  <.link
                    href={~p"/users/register"}
                    class="btn btn-sm border border-white bg-white text-[#2563eb] hover:bg-white/90"
                  >
                    Sign up
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
        </header>

        <main class="flex flex-1 flex-col bg-[#2f343f]">
          <div class="flex-1 py-10 lg:py-14">
            <div class="mx-auto w-full max-w-6xl space-y-8 px-4 sm:px-6 lg:px-10">
              <div class="rounded-3xl border border-white/8 bg-white/98 p-10 text-slate-900 shadow-2xl shadow-black/40">
                {render_slot(@inner_block)}
              </div>
            </div>
          </div>
        </main>
      </div>
      <div class="drawer-side">
        <label for="layout-drawer" class="drawer-overlay"></label>
        <aside class="flex h-full w-72 flex-col border-r border-[#18202f] bg-gradient-to-b from-[#1f2a3a] via-[#253141] to-[#303d4e] px-4 py-10 text-white">
          <nav class="flex flex-1 flex-col gap-8">
            <section class="space-y-3">
              <h2 class="px-3 text-xs font-semibold uppercase tracking-wide text-white/60">
                Projects
              </h2>
              <ul class="space-y-2">
                <li>
                  <.link
                    href={~p"/projects"}
                    class="btn btn-ghost btn-block justify-start rounded-xl border border-white/10 bg-white/5 text-white hover:border-white/20 hover:bg-white/15"
                  >
                    All Projects
                  </.link>
                </li>
                <li>
                  <.link
                    href={~p"/projects"}
                    class="btn btn-ghost btn-block justify-start rounded-xl border border-white/10 bg-white/5 text-white hover:border-white/20 hover:bg-white/15"
                  >
                    My Projects
                  </.link>
                </li>
                <li :for={project <- @projects}>
                  <.link
                    href={~p"/projects/#{project}"}
                    class="btn btn-ghost btn-block justify-start truncate rounded-xl border border-transparent text-white hover:border-white/20 hover:bg-white/10"
                  >
                    {project.name}
                  </.link>
                </li>
              </ul>
            </section>

            <section class="space-y-3">
              <h2 class="px-3 text-xs font-semibold uppercase tracking-wide text-white/60">Tasks</h2>
              <ul class="space-y-2">
                <li>
                  <.link
                    href={~p"/tasks"}
                    class="btn btn-ghost btn-block justify-start rounded-xl border border-white/10 bg-white/5 text-white hover:border-white/20 hover:bg-white/15"
                  >
                    All Tasks
                  </.link>
                </li>
                <li>
                  <.link
                    href={~p"/tasks"}
                    class="btn btn-ghost btn-block justify-start rounded-xl border border-white/10 bg-white/5 text-white hover:border-white/20 hover:bg-white/15"
                  >
                    My Tasks
                  </.link>
                </li>
              </ul>
            </section>

            <section class="space-y-3">
              <h2 class="px-3 text-xs font-semibold uppercase tracking-wide text-white/60">Logs</h2>
              <ul class="space-y-2">
                <li>
                  <.link
                    href={~p"/activity_logs"}
                    class="btn btn-ghost btn-block justify-start rounded-xl border border-white/10 bg-white/5 text-white hover:border-white/20 hover:bg-white/15"
                  >
                    All Logs
                  </.link>
                </li>
                <li>
                  <.link
                    href={~p"/activity_logs"}
                    class="btn btn-ghost btn-block justify-start rounded-xl border border-white/10 bg-white/5 text-white hover:border-white/20 hover:bg-white/15"
                  >
                    My Logs
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
