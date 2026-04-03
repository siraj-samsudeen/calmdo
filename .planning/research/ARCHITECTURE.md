# Architecture Research

**Domain:** Small-team project management (GTD inbox + kanban + time tracking + knowledge base)
**Researched:** 2026-04-03
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     BROWSER (React 19 SPA)                       │
│                                                                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌───────────┐  │
│  │  TanStack   │  │  Feature   │  │  shadcn/ui │  │  Auth UI  │  │
│  │  Router     │  │  Pages     │  │  Components│  │  (forms)  │  │
│  └─────┬──────┘  └─────┬──────┘  └────────────┘  └─────┬─────┘  │
│        │               │                               │         │
│  ┌─────┴───────────────┴───────────────────────────────┴─────┐   │
│  │              ConvexReactClient (WebSocket)                  │   │
│  │   useQuery() ←── reactive subscriptions                     │   │
│  │   useMutation() ──→ mutations + optimistic updates          │   │
│  └─────────────────────────┬───────────────────────────────────┘   │
└────────────────────────────┼───────────────────────────────────────┘
                             │ WebSocket (persistent)
┌────────────────────────────┼───────────────────────────────────────┐
│                     CONVEX BACKEND                                  │
│                                                                     │
│  ┌─────────────────────────┴───────────────────────────────────┐   │
│  │              Public API Layer (thin wrappers)                │   │
│  │  convex/inbox.ts  convex/tasks.ts  convex/projects.ts  ...   │   │
│  └─────────────────────────┬───────────────────────────────────┘   │
│                             │                                       │
│  ┌─────────────────────────┴───────────────────────────────────┐   │
│  │              Model Layer (business logic)                    │   │
│  │  convex/model/inbox.ts  convex/model/tasks.ts  ...           │   │
│  │  convex/model/auth.ts   convex/model/time.ts                 │   │
│  └─────────────────────────┬───────────────────────────────────┘   │
│                             │                                       │
│  ┌─────────────────────────┴───────────────────────────────────┐   │
│  │              Database (Convex document store)                │   │
│  │  Tables: projects, tasks, subTasks, checklists, comments,    │   │
│  │          activityLog, timeEntries, inboxItems,               │   │
│  │          learningResources, users, authSessions, invites     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐                        │
│  │  @convex-dev/auth │  │  Cron Jobs       │                        │
│  │  (Password)       │  │  (focus reset)   │                        │
│  └──────────────────┘  └──────────────────┘                        │
└─────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Communicates With |
|-----------|----------------|-------------------|
| TanStack Router | Route tree, auth guards via `beforeLoad`, code splitting | ConvexReactClient (auth context), Feature Pages |
| Feature Pages | Page-level orchestration: compose queries, handle user actions | Convex queries/mutations, shadcn/ui components |
| shadcn/ui Components | Reusable UI primitives (buttons, dialogs, forms, data tables) | Feature Pages (props down, callbacks up) |
| Auth UI | Login/signup forms, session management UI | @convex-dev/auth client hooks |
| ConvexReactClient | WebSocket connection, reactive query subscriptions, mutation dispatch | Convex backend (WebSocket) |
| Public API Layer | Argument validation, auth checks, delegation to model | Model layer, database |
| Model Layer | Business logic, authorization helpers, data transformations | Database (ctx.db) |
| @convex-dev/auth | Password authentication, session management, user creation | Users/authSessions tables |
| Cron Jobs | Daily focus list reset, session cleanup | Database |

## Recommended Project Structure

```
calmdo/
├── convex/                          # Backend (Convex functions + schema)
│   ├── schema.ts                    # Single schema file (all tables)
│   ├── auth.ts                      # convexAuth() config + Password provider
│   ├── http.ts                      # HTTP endpoints (auth routes)
│   ├── crons.ts                     # Scheduled jobs (focus reset)
│   │
│   ├── model/                       # Business logic (plain TypeScript)
│   │   ├── auth.ts                  # Auth helpers: getUser, ensureAuthenticated
│   │   ├── projects.ts              # Project CRUD, visibility checks
│   │   ├── tasks.ts                 # Task CRUD, status transitions
│   │   ├── inbox.ts                 # Inbox capture, triage logic
│   │   ├── time.ts                  # Timer start/stop, manual entry logic
│   │   ├── activity.ts              # Activity log entry logic
│   │   └── resources.ts             # Learning resource CRUD
│   │
│   ├── projects.ts                  # Public API: project queries/mutations
│   ├── tasks.ts                     # Public API: task queries/mutations
│   ├── subTasks.ts                  # Public API: sub-task queries/mutations
│   ├── checklists.ts                # Public API: checklist queries/mutations
│   ├── comments.ts                  # Public API: comment queries/mutations
│   ├── activityLog.ts               # Public API: activity log queries/mutations
│   ├── timeEntries.ts               # Public API: time entry queries/mutations
│   ├── inbox.ts                     # Public API: inbox queries/mutations
│   ├── learningResources.ts         # Public API: learning resource queries/mutations
│   ├── users.ts                     # Public API: user management (admin)
│   ├── dashboard.ts                 # Public API: dashboard aggregate queries
│   └── _generated/                  # Auto-generated (do not edit)
│
├── src/                             # Frontend (React SPA)
│   ├── main.tsx                     # Entry: ConvexProvider + RouterProvider
│   ├── routeTree.gen.ts             # Auto-generated route tree
│   │
│   ├── routes/                      # TanStack Router file-based routes
│   │   ├── __root.tsx               # Root layout: ConvexProvider, auth context
│   │   ├── login.tsx                # /login (public)
│   │   │
│   │   ├── _authenticated.tsx       # Layout route: auth guard (beforeLoad)
│   │   ├── _authenticated/          # All protected routes
│   │   │   ├── index.tsx            # / → Dashboard
│   │   │   ├── inbox.tsx            # /inbox
│   │   │   ├── focus.tsx            # /focus (today's tasks)
│   │   │   ├── projects.tsx         # /projects (list)
│   │   │   ├── projects.$projectId.tsx  # /projects/:projectId
│   │   │   ├── tasks.$taskId.tsx    # /tasks/:taskId (detail/edit)
│   │   │   ├── resources.tsx        # /resources (knowledge base)
│   │   │   └── admin.tsx            # /admin (user management)
│   │   │
│   │   └── _authenticated/-components/  # Route-scoped shared components
│   │
│   ├── components/                  # Reusable UI components
│   │   ├── ui/                      # shadcn/ui primitives (button, input, etc.)
│   │   ├── task-card.tsx            # Task display card
│   │   ├── task-form.tsx            # Task create/edit form
│   │   ├── kanban-board.tsx         # Kanban column layout
│   │   ├── inbox-item.tsx           # Inbox item display
│   │   ├── timer.tsx                # Start/stop timer widget
│   │   ├── comment-thread.tsx       # Comment list + form
│   │   ├── activity-log.tsx         # Activity log timeline
│   │   ├── checklist.tsx            # Checklist with add/toggle/delete
│   │   └── resource-card.tsx        # Learning resource display
│   │
│   ├── lib/                         # Shared utilities
│   │   ├── utils.ts                 # cn() helper, date formatting
│   │   └── constants.ts             # Task statuses, roles
│   │
│   └── hooks/                       # Custom React hooks
│       ├── use-timer.ts             # Timer state management
│       └── use-focus-list.ts        # Focus list helpers
│
├── tests/                           # Test files
│   ├── convex/                      # Backend function tests (feather-testing-convex)
│   └── components/                  # Component integration tests
│
├── index.html
├── vite.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

### Structure Rationale

- **`convex/model/` separate from public API files:** Follows Convex best practice. Public API files (`convex/tasks.ts`) are thin wrappers with validators and auth checks. Business logic lives in `convex/model/tasks.ts` as plain TypeScript functions. This keeps public functions short, enables code reuse between queries/mutations, and maintains transactional guarantees without `ctx.runQuery` overhead.

- **`src/routes/_authenticated/` layout pattern:** TanStack Router convention. `_authenticated.tsx` contains a `beforeLoad` guard that checks auth status and redirects to `/login`. All routes inside `_authenticated/` inherit this guard automatically. The underscore prefix means the segment does not appear in the URL.

- **`src/components/` for reusable UI, route files for page composition:** Components are domain-specific but reusable across routes (e.g., `task-card.tsx` appears in inbox triage, project view, and focus list). Page-level composition stays in route files.

- **One public API file per domain entity:** Each Convex resource gets its own file (`convex/tasks.ts`, `convex/comments.ts`). This maps cleanly to Convex's API generation (`api.tasks.list`, `api.comments.create`), keeps files under 300 lines, and makes the API surface obvious.

- **Single `schema.ts`:** Convex requires all table definitions in one file. Keep it organized with comments grouping related tables.

## Architectural Patterns

### Pattern 1: Thin Public API + Model Layer

**What:** Public Convex functions validate args and check auth, then delegate to plain TypeScript helpers in `convex/model/`.
**When to use:** Every query and mutation.
**Trade-offs:** Slightly more files, but drastically better testability, reusability, and readability.

**Example:**
```typescript
// convex/tasks.ts (thin public API)
import { mutation } from "./_generated/server";
import { v } from "convex/values";
import { ensureAuthenticated } from "./model/auth";
import { createTask } from "./model/tasks";

export const create = mutation({
  args: {
    projectId: v.id("projects"),
    title: v.string(),
    description: v.optional(v.string()),
    assigneeId: v.optional(v.id("users")),
    dueDate: v.optional(v.number()),
  },
  returns: v.id("tasks"),
  handler: async (ctx, args) => {
    const user = await ensureAuthenticated(ctx);
    return await createTask(ctx, user, args);
  },
});

// convex/model/tasks.ts (business logic)
export async function createTask(
  ctx: MutationCtx,
  user: Doc<"users">,
  args: { projectId: Id<"projects">; title: string; ... }
): Promise<Id<"tasks">> {
  // Verify project access
  const project = await ctx.db.get(args.projectId);
  if (!project) throw new ConvexError("Project not found");
  if (project.isPersonal && project.ownerId !== user._id) {
    throw new ConvexError("Cannot add tasks to someone else's personal project");
  }
  return await ctx.db.insert("tasks", {
    projectId: args.projectId,
    title: args.title,
    status: "todo",
    createdBy: user._id,
    assigneeId: args.assigneeId,
    dueDate: args.dueDate,
  });
}
```

### Pattern 2: Auth Guard Layout Route

**What:** A TanStack Router layout route that checks authentication in `beforeLoad` and redirects unauthenticated users. All protected routes nest under this layout.
**When to use:** Every route except `/login`.
**Trade-offs:** Simple, centralized. One guard protects the entire app.

**Example:**
```typescript
// src/routes/_authenticated.tsx
import { createFileRoute, redirect, Outlet } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated")({
  beforeLoad: async ({ context }) => {
    // context.auth comes from Convex's useConvexAuth() in the root route
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: "/login" });
    }
  },
  component: () => {
    return (
      <AppShell>
        <Outlet />
      </AppShell>
    );
  },
});
```

### Pattern 3: Invite-Only Signup via Invites Table

**What:** Instead of open registration, admins create invite records. The `createOrUpdateUser` callback in Convex Auth checks for a valid invite before allowing signup. No invite = signup rejected.
**When to use:** For this project specifically -- invite-only is a core requirement.
**Trade-offs:** Requires admin UI for managing invites. Adds a table. But prevents unauthorized access entirely.

**Example:**
```typescript
// convex/auth.ts
import { Password } from "@convex-dev/auth/providers/Password";
import { convexAuth } from "@convex-dev/auth/server";

export const { auth, signIn, signOut, store } = convexAuth({
  providers: [Password],
  callbacks: {
    async createOrUpdateUser(ctx, { existingUserId, profile, provider }) {
      if (existingUserId) {
        // Existing user signing in -- allow
        return existingUserId;
      }
      // New signup -- check for invite
      const invite = await ctx.db
        .query("invites")
        .withIndex("by_email", (q) => q.eq("email", profile.email))
        .unique();
      if (!invite || invite.usedAt) {
        throw new Error("Signup requires an invitation");
      }
      // Create user and mark invite as used
      const userId = await ctx.db.insert("users", {
        email: profile.email,
        name: invite.name,
        role: invite.role ?? "member",
      });
      await ctx.db.patch(invite._id, { usedAt: Date.now(), userId });
      return userId;
    },
  },
});
```

### Pattern 4: Reactive Queries with Index-First Filtering

**What:** Always use `.withIndex()` instead of `.filter()` for database queries. Define indexes in `schema.ts` for every query pattern.
**When to use:** Every Convex query.
**Trade-offs:** Requires upfront index planning. But prevents full table scans and keeps queries fast as data grows.

**Example:**
```typescript
// Schema with indexes
tasks: defineTable({
  projectId: v.id("projects"),
  title: v.string(),
  status: v.union(v.literal("todo"), v.literal("inProgress"), v.literal("done")),
  assigneeId: v.optional(v.id("users")),
  dueDate: v.optional(v.number()),
  createdBy: v.id("users"),
  isFocused: v.optional(v.boolean()),
  focusDate: v.optional(v.string()), // "YYYY-MM-DD"
})
  .index("by_project", ["projectId"])
  .index("by_project_status", ["projectId", "status"])
  .index("by_assignee", ["assigneeId"])
  .index("by_focus", ["isFocused", "focusDate"])
  .index("by_due_date", ["dueDate"]),

// Query using index
export const listByProject = query({
  args: { projectId: v.id("projects"), status: v.optional(v.string()) },
  returns: v.array(taskValidator),
  handler: async (ctx, { projectId, status }) => {
    await ensureAuthenticated(ctx);
    let q = ctx.db.query("tasks").withIndex("by_project_status", (q) =>
      status
        ? q.eq("projectId", projectId).eq("status", status)
        : q.eq("projectId", projectId)
    );
    return await q.collect();
  },
});
```

### Pattern 5: Optimistic Updates for Responsive Interactions

**What:** Register local state updates on mutations so the UI responds instantly, before the server confirms.
**When to use:** High-frequency interactions: toggling checklist items, changing task status (drag-and-drop kanban), starting/stopping timers.
**Trade-offs:** Adds client-side code complexity. Worth it only for interactions where latency is noticeable.

**Example:**
```typescript
// Kanban status change with optimistic update
const updateStatus = useMutation(api.tasks.updateStatus).withOptimisticUpdate(
  (localStore, { taskId, status }) => {
    const tasks = localStore.getQuery(api.tasks.listByProject, {
      projectId: currentProjectId,
    });
    if (tasks !== undefined) {
      localStore.setQuery(
        api.tasks.listByProject,
        { projectId: currentProjectId },
        tasks.map((t) => (t._id === taskId ? { ...t, status } : t))
      );
    }
  }
);
```

## Data Flow

### Query Flow (Real-Time Reads)

```
React Component
    │
    ├── useQuery(api.tasks.listByProject, { projectId })
    │       │
    │       ▼
    │   ConvexReactClient (WebSocket subscription)
    │       │
    │       ▼
    │   Convex Backend: tasks.listByProject handler
    │       │
    │       ├── ensureAuthenticated(ctx)
    │       ├── ctx.db.query("tasks").withIndex(...)
    │       │
    │       ▼
    │   Result pushed to client via WebSocket
    │       │
    │       ▼
    └── Component re-renders with new data (automatic)

    [If any task in the result set changes, query re-runs
     and pushes new data automatically. No polling.]
```

### Mutation Flow (Writes)

```
User Action (e.g., drag task to "Done" column)
    │
    ├── 1. Optimistic update runs locally (instant UI feedback)
    │
    ├── 2. useMutation(api.tasks.updateStatus) sends to server
    │       │
    │       ▼
    │   Convex Backend (single transaction):
    │       ├── Validate args
    │       ├── ensureAuthenticated(ctx)
    │       ├── ctx.db.patch(taskId, { status: "done" })
    │       └── ctx.db.insert("activityLog", { ... })
    │
    ├── 3. Server confirms → optimistic update replaced with real data
    │
    └── 4. All clients subscribed to affected queries get updated data
```

### Key Data Flows

1. **Inbox Capture:** User types in inbox input, mutation creates `inboxItems` doc (personal, private). Dashboard badge updates reactively for that user only.

2. **Inbox Triage:** User selects inbox item, chooses project + converts to task. Mutation in single transaction: creates `tasks` doc, deletes/archives `inboxItems` doc. Project's task list updates for all team members reactively.

3. **Kanban Status Change:** User drags task card. Optimistic update moves card instantly. Mutation patches task status. All team members viewing the project see the card move in real-time.

4. **Time Tracking:** User clicks start timer. Mutation creates `timeEntries` doc with `startTime`, no `endTime`. User clicks stop. Mutation patches entry with `endTime` and `duration`. Linked `activityLog` entry created in same transaction.

5. **Focus List:** Daily cron job resets `isFocused` flag on all tasks where `focusDate` is not today. User stars a task -- mutation sets `isFocused: true, focusDate: today`. Focus page queries tasks with `by_focus` index.

6. **Visibility Check:** Every query for project-scoped data checks: is the project personal? If yes, is the current user the owner? If not, filter out. This happens in the model layer, not at the query level, so the logic is reused.

## Schema Design

### Core Tables

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // ── Auth (managed by @convex-dev/auth) ──────────────
  // users and authSessions tables are auto-created by convexAuth
  // We extend users with custom fields via createOrUpdateUser callback

  // ── Invites ─────────────────────────────────────────
  invites: defineTable({
    email: v.string(),
    name: v.string(),
    role: v.union(v.literal("admin"), v.literal("member")),
    invitedBy: v.id("users"),
    usedAt: v.optional(v.number()),
    userId: v.optional(v.id("users")),
  })
    .index("by_email", ["email"]),

  // ── Projects ────────────────────────────────────────
  projects: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    isPersonal: v.boolean(),        // true = only owner can see
    ownerId: v.id("users"),         // creator
    isArchived: v.boolean(),
  })
    .index("by_owner", ["ownerId"])
    .index("by_archived", ["isArchived"]),

  // ── Tasks ───────────────────────────────────────────
  tasks: defineTable({
    projectId: v.id("projects"),
    title: v.string(),
    description: v.optional(v.string()),
    status: v.union(
      v.literal("todo"),
      v.literal("inProgress"),
      v.literal("done")
    ),
    assigneeId: v.optional(v.id("users")),
    dueDate: v.optional(v.number()),
    createdBy: v.id("users"),
    position: v.number(),            // ordering within status column
    isFocused: v.boolean(),
    focusDate: v.optional(v.string()), // "YYYY-MM-DD" for daily reset
  })
    .index("by_project", ["projectId"])
    .index("by_project_status", ["projectId", "status"])
    .index("by_assignee", ["assigneeId"])
    .index("by_focus", ["isFocused", "focusDate"]),

  // ── Sub-Tasks (one level deep) ──────────────────────
  subTasks: defineTable({
    taskId: v.id("tasks"),
    title: v.string(),
    description: v.optional(v.string()),
    status: v.union(
      v.literal("todo"),
      v.literal("inProgress"),
      v.literal("done")
    ),
    assigneeId: v.optional(v.id("users")),
    dueDate: v.optional(v.number()),
    createdBy: v.id("users"),
    position: v.number(),
  })
    .index("by_task", ["taskId"]),

  // ── Checklists ──────────────────────────────────────
  checklists: defineTable({
    parentId: v.union(v.id("tasks"), v.id("subTasks")),
    parentTable: v.union(v.literal("tasks"), v.literal("subTasks")),
    title: v.string(),
    isChecked: v.boolean(),
    position: v.number(),
  })
    .index("by_parent", ["parentTable", "parentId"]),

  // ── Comments ────────────────────────────────────────
  comments: defineTable({
    parentId: v.union(v.id("tasks"), v.id("subTasks")),
    parentTable: v.union(v.literal("tasks"), v.literal("subTasks")),
    body: v.string(),
    authorId: v.id("users"),
  })
    .index("by_parent", ["parentTable", "parentId"]),

  // ── Activity Log ────────────────────────────────────
  activityLog: defineTable({
    taskId: v.union(v.id("tasks"), v.id("subTasks")),
    taskTable: v.union(v.literal("tasks"), v.literal("subTasks")),
    body: v.string(),
    authorId: v.id("users"),
    timeEntryId: v.optional(v.id("timeEntries")),
  })
    .index("by_task", ["taskTable", "taskId"]),

  // ── Time Entries ────────────────────────────────────
  timeEntries: defineTable({
    taskId: v.union(v.id("tasks"), v.id("subTasks")),
    taskTable: v.union(v.literal("tasks"), v.literal("subTasks")),
    userId: v.id("users"),
    startTime: v.number(),
    endTime: v.optional(v.number()),
    durationMs: v.optional(v.number()),   // computed on stop
    isManual: v.boolean(),                // true = manual entry, false = timer
  })
    .index("by_task", ["taskTable", "taskId"])
    .index("by_user", ["userId"])
    .index("by_user_running", ["userId", "endTime"]), // endTime undefined = running

  // ── Inbox Items ─────────────────────────────────────
  inboxItems: defineTable({
    title: v.string(),
    notes: v.optional(v.string()),
    ownerId: v.id("users"),           // always private to creator
    triagedAt: v.optional(v.number()),
    triagedToTaskId: v.optional(v.id("tasks")),
  })
    .index("by_owner", ["ownerId"])
    .index("by_owner_untriaged", ["ownerId", "triagedAt"]),

  // ── Learning Resources ──────────────────────────────
  learningResources: defineTable({
    url: v.string(),
    title: v.string(),
    summary: v.string(),
    taskId: v.optional(v.union(v.id("tasks"), v.id("subTasks"))),
    taskTable: v.optional(v.union(v.literal("tasks"), v.literal("subTasks"))),
    createdBy: v.id("users"),
    tags: v.optional(v.array(v.string())),
  })
    .index("by_task", ["taskTable", "taskId"])
    .index("by_creator", ["createdBy"]),
});
```

### Schema Design Decisions

| Decision | Rationale |
|----------|-----------|
| `parentTable` discriminator field | Convex unions of IDs (`v.union(v.id("tasks"), v.id("subTasks"))`) need a discriminator to know which table to query. Compound index `["parentTable", "parentId"]` enables efficient lookups. |
| `position: v.number()` for ordering | List position implies priority (per PROJECT.md). Float-based positioning (e.g., 1.0, 1.5, 2.0) allows insertions between items without rewriting all positions. |
| `isFocused` + `focusDate` on tasks | Enables daily reset via cron. Index on `["isFocused", "focusDate"]` makes the focus list query fast. |
| Separate `subTasks` table vs. self-referential | Self-referential `tasks` table with `parentTaskId` is simpler schema but makes queries ambiguous (is this a task or sub-task?). Separate table enforces one-level depth at the schema level. |
| `timeEntries` separate from `activityLog` | A time entry may or may not have an activity log entry. An activity log entry may or may not have a time entry. Keeping them separate with an optional link (`timeEntryId`) models the relationship correctly. |
| `inboxItems` always private | `ownerId` index + auth check. No `projectId` -- inbox items are pre-triage. Triage converts them to tasks. |

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 2-5 users (target) | Current architecture is ideal. All queries are indexed. Real-time subscriptions handle <100 concurrent sockets easily. No optimization needed. |
| 10-50 users | Add pagination to task lists and activity logs. Consider denormalized counts (task count per project, unread inbox count) to avoid counting queries. |
| 100+ users | Beyond Convex's sweet spot for this use case. Would need query result caching, selective real-time subscriptions (subscribe to active project only, not all), and potentially splitting the activity log into a separate concern. |

### Scaling Priorities

1. **First bottleneck -- large task lists:** When a project has 100+ tasks, `.collect()` on the task query becomes slow. Add pagination (`paginationOpts`) early. The kanban view inherently filters by status, which helps.

2. **Second bottleneck -- dashboard aggregate queries:** Counting inbox items, active tasks, and recent activity across all projects requires multiple queries. Denormalize counts into a `userStats` table updated by mutations.

## Anti-Patterns

### Anti-Pattern 1: Using `.filter()` Instead of `.withIndex()`

**What people do:** `ctx.db.query("tasks").filter(q => q.eq(q.field("projectId"), projectId))`
**Why it is wrong:** Full table scan. Reads every task document. Gets slower linearly with data growth.
**Do this instead:** Define an index in schema.ts and use `.withIndex("by_project", q => q.eq("projectId", projectId))`.

### Anti-Pattern 2: Fat Public API Functions

**What people do:** Put all business logic, auth checks, and data transformations directly in the `mutation()` or `query()` handler.
**Why it is wrong:** Untestable in isolation. Cannot share logic between a query and a mutation. Functions grow to 100+ lines.
**Do this instead:** Keep public functions under 10 lines. Delegate to `convex/model/` helpers.

### Anti-Pattern 3: `ctx.runQuery()` / `ctx.runMutation()` Between Convex Functions

**What people do:** Call `ctx.runQuery(api.tasks.list, { projectId })` from inside another mutation.
**Why it is wrong:** Adds function call overhead. Breaks the single-transaction guarantee (for `runQuery`). Creates API coupling.
**Do this instead:** Import and call the helper function directly: `import { listTasks } from "./model/tasks"`.

### Anti-Pattern 4: Storing Derived State in the Database

**What people do:** Store `taskCount` on the project document, `completionPercentage` on tasks, etc.
**Why it is wrong at small scale:** Creates synchronization bugs. Every mutation that changes tasks must also update the count. Miss one and the count drifts.
**Do this instead at small scale:** Compute derived values in queries. `tasks.filter(t => t.status === "done").length` is fast for <100 tasks. Only denormalize when you measure a performance problem.

### Anti-Pattern 5: Optimistic Updates Everywhere

**What people do:** Add `.withOptimisticUpdate()` to every mutation.
**Why it is wrong:** Adds complexity. Convex's real-time subscriptions already provide sub-second updates. Most mutations do not benefit noticeably from optimistic updates.
**Do this instead:** Only add optimistic updates for drag-and-drop (kanban), checkbox toggles, and timer start/stop -- interactions where even 200ms latency feels sluggish.

### Anti-Pattern 6: Self-Referential Task Hierarchy

**What people do:** Add `parentTaskId: v.optional(v.id("tasks"))` to allow unlimited nesting.
**Why it is wrong:** Recursive queries are expensive, UI complexity explodes, and the team decided one-level sub-tasks are sufficient.
**Do this instead:** Separate `tasks` and `subTasks` tables. Schema enforces the depth limit.

## Integration Points

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| React SPA <-> Convex Backend | WebSocket via ConvexReactClient | All data flows through `useQuery`/`useMutation`. No REST. No GraphQL. Single persistent connection. |
| Route Layer <-> Auth | `beforeLoad` reads auth context | Auth state from `useConvexAuth()` injected into router context at the root route. |
| Public API <-> Model Layer | Direct TypeScript function calls | No network boundary. Same transaction. `import { fn } from "./model/x"`. |
| Model Layer <-> Database | `ctx.db` methods | All reads/writes through Convex's transactional database API. |
| @convex-dev/auth <-> Users table | `createOrUpdateUser` callback | Custom callback enforces invite-only signup. Auth library manages sessions. |
| Cron <-> Database | Internal mutations | `crons.interval()` triggers internal mutations for daily focus reset. |

### Build Order (Dependency Graph)

Components must be built in this order based on dependencies:

```
Phase 1: Foundation
  ├── Schema (schema.ts) ─── everything depends on this
  ├── Auth (convex/auth.ts + invites table + login UI)
  └── App Shell (root route, layout, navigation)

Phase 2: Core Loop
  ├── Projects (CRUD + visibility) ─── tasks depend on projects
  ├── Tasks + Kanban ─── sub-tasks, comments, etc. depend on tasks
  └── Inbox (capture + triage to tasks) ─── triage creates tasks

Phase 3: Task Depth
  ├── Sub-Tasks ─── depends on tasks
  ├── Checklists ─── depends on tasks + sub-tasks
  ├── Comments ─── depends on tasks + sub-tasks
  └── Activity Log ─── depends on tasks + sub-tasks

Phase 4: Time + Focus
  ├── Time Entries + Timer ─── depends on tasks + activity log
  ├── Focus List ─── depends on tasks
  └── Focus Reset Cron ─── depends on focus list

Phase 5: Knowledge + Dashboard
  ├── Learning Resources ─── depends on tasks (optional link)
  └── Dashboard ─── depends on all above (aggregate queries)

Phase 6: Admin
  └── User Management + Invite UI ─── depends on auth + invites
```

**Why this order:**
- Schema first because Convex generates types from it. Without the schema, nothing compiles.
- Auth second because every other feature requires `ensureAuthenticated()`.
- Projects before tasks because tasks belong to projects.
- Inbox early because it is the GTD entry point and validates the core capture-triage loop.
- Sub-tasks/checklists/comments after tasks because they are children of tasks.
- Time tracking after activity log because time entries link to activity log entries.
- Dashboard last because it aggregates data from everything else.
- Admin last because the first user can be seeded via script; the UI is a convenience.

## Sources

- [Convex Best Practices](https://docs.convex.dev/understanding/best-practices/) -- Function organization, model layer pattern, index-first queries (HIGH confidence)
- [Convex Schema Relationships](https://stack.convex.dev/relationship-structures-let-s-talk-about-schemas) -- One-to-many, many-to-many patterns, index design (HIGH confidence)
- [Convex Authorization Patterns](https://stack.convex.dev/authorization) -- Role-based access, custom functions as middleware, row-level security (HIGH confidence)
- [Convex Auth Documentation](https://labs.convex.dev/auth) -- Password provider setup, createOrUpdateUser callback (HIGH confidence)
- [Convex Auth Advanced](https://labs.convex.dev/auth/advanced) -- Custom user creation, invite restriction pattern (MEDIUM confidence -- invite pattern inferred from callback docs)
- [Convex Optimistic Updates](https://docs.convex.dev/client/react/optimistic-updates) -- withOptimisticUpdate API, local store manipulation (HIGH confidence)
- [TanStack Router Authenticated Routes](https://tanstack.com/router/latest/docs/framework/react/guide/authenticated-routes) -- beforeLoad auth guards, redirect pattern (HIGH confidence)
- [TanStack Router File-Based Routing](https://tanstack.com/router/latest/docs/framework/react/routing/file-based-routing) -- Route file conventions, layout routes (HIGH confidence)
- [Convex Community Best Practices Gist](https://gist.github.com/srizvi/966e583693271d874bf65c2a95466339) -- Opinionated guidelines for schema, functions, project structure (MEDIUM confidence -- community source)

---
*Architecture research for: CalmDo -- small-team project management*
*Researched: 2026-04-03*
