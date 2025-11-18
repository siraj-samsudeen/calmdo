# Calmdo Project - Phoenix LiveView Guidelines

**IMPORTANT**: For Phoenix LiveView questions, always check the phoenix-liveview-reviewer agent in AGENTS.md or consult official Phoenix LiveView documentation at https://hexdocs.pm/phoenix_live_view

## Verified Routes (~p sigil)
- The `~p` sigil automatically handles Phoenix.Param protocol for structs in both path and query parameters
- Example: `~p"/tasks?assigned_id=#{@current_scope.user}"` automatically calls `Phoenix.Param.to_param(user)` which returns the ID
- Ecto schemas automatically implement Phoenix.Param, returning `to_string(schema.id)`
- No need to manually extract .id when using ~p sigil with Ecto structs

## Link Navigation Types
- `<.link href={path}>` - Traditional browser navigation, FULL page reload (NOT LiveView navigation)
- `<.link patch={path}>` - Live patch within same LiveView (only handle_params/3 runs, no mount/3)
- `<.link navigate={path}>` - Live navigation to different LiveView (both mount/3 and handle_params/3 run)
- Use `patch` for filters/params within same page, `navigate` for different pages, avoid `href` in LiveView apps

## LiveView Lifecycle
- `mount/3` - Setup session state ONCE (current user, subscriptions, dropdown data). Do NOT read URL params here.
- `handle_params/3` - React to URL changes EVERY time (filters, search, pagination). Always read URL params here.
- Rule: URL params belong in handle_params/3, not mount/3

## Phoenix Architecture (Fat Contexts, Thin LiveViews)
- **LiveViews**: Handle user interaction, assign data, minimal logic. Just pass raw params to Contexts.
- **Contexts**: Handle all data access, query building, type conversion, business logic, validation.
- Type conversion (string → integer, atom, etc.) belongs in Context, not LiveView - single source of truth.
- Make filters composable: `list_tasks(scope, task_id: 1, project_id: 2)` should filter by BOTH, not one or the other.
- Don't use `cond` in LiveView to pick which filter - pass all filters to Context and let it handle query building.
- Pattern: LiveView calls `Context.list_things(scope, params)`, Context parses and builds query.

## Query Composition Pattern (Hybrid Approach)
Use a hybrid approach for building Ecto queries - combining concise helpers with explicit naming:

### Use `maybe_where` for simple filters:
```elixir
def list_tasks(%Scope{} = _scope, params) when is_map(params) do
  Task
  |> with_task_preloads()
  |> maybe_where(:status, params["status"])
  |> maybe_where(:assignee_id, params["assignee_id"])
  |> order_by_recent()
  |> Repo.all()
end
```

### Use named functions for:
- **Preloads**: `with_preloads()`, `with_task_preloads()` - Makes associations explicit
- **Ordering**: `order_by_recent()` - Clear intent, single source of truth
- **Complex logic**: `filter_by_project_or_task_project()` - Business logic that deserves a name
- **Joins**: `join_tasks()` - Use named bindings with `as: :binding_name`

### Benefits:
- ✅ Concise for simple filters (no nil-handling boilerplate)
- ✅ Explicit for complex logic (self-documenting)
- ✅ Reads like English from top to bottom
- ✅ Easy to add/remove filters without creating new functions

### Example with complex logic:
```elixir
def list_activity_logs_for_project(%Scope{} = _scope, project_id) do
  ActivityLog
  |> with_preloads()
  |> join_tasks()  # Named function for join
  |> filter_by_project_or_task_project(project_id)  # Named function for complex WHERE
  |> order_by_recent()
  |> Repo.all()
end

defp join_tasks(query) do
  from al in query,
    left_join: t in assoc(al, :task),
    as: :task  # Named binding for clarity
end

defp filter_by_project_or_task_project(query, project_id) do
  from [al, task: t] in query,  # Reference named binding
    where: al.project_id == ^project_id or t.project_id == ^project_id
end
```

## Project Context
- Small team app where users can see all data (no user-level data isolation)
- Uses Scope pattern for context passing
- Focus on team collaboration, not strict data boundaries
