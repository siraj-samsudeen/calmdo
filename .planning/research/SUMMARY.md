# Project Research Summary

**Project:** CalmDo — calm project management web app
**Domain:** Small-team project management (2-5 people) with GTD inbox, time tracking, and team knowledge base
**Researched:** 2026-04-03
**Confidence:** HIGH

## Executive Summary

CalmDo is a small-team project management SPA targeting the gap between personal GTD tools (Things 3, Todoist) and team collaboration tools (Linear, Basecamp). The recommended approach is a Convex-backed React SPA: Convex provides real-time reactivity, type-safe backend functions, and authentication out of the box, eliminating the need for a separate REST API, WebSocket layer, or auth service. The stack (React 19 + Vite + TanStack Router + Tailwind v4 + shadcn/ui) is fully chosen and version-pinned — the research confirms all components are compatible and the integration patterns are well-documented.

The product's differentiators — GTD inbox with triage flow, Today/Focus list with daily reset, and activity log integrated with time tracking — are genuinely unique in the small-team PM space. Research confirms no competitor cleanly combines these three features. The deliberate anti-features (no priorities, no custom statuses, no Gantt, no AI) are well-justified: they mirror Linear's successful opinionated philosophy applied to a smaller team context. The "calm" positioning is coherent and defensible.

The two highest-risk areas are (1) auth correctness — @convex-dev/auth is in beta with a pinned @auth/core version and non-obvious invite-only patterns that must be nailed in Phase 1 before anything else is built, and (2) GTD inbox UX — technically simple but psychologically critical. An inbox that accumulates without easy triage destroys the product's core value proposition. Both risks are addressable with the right approach from the start, not retrofittable.

## Key Findings

### Recommended Stack

The stack is pre-decided and fully version-pinned. Convex 1.34.1 is the backbone — it replaces a traditional REST API, WebSocket server, and database by providing reactive queries (auto-push on data change), type-safe mutations, and scheduled jobs in one system. No TanStack Query, no Zustand, no Redux — Convex `useQuery` handles all server state reactively. TanStack Router (not TanStack Start — no SSR needed) provides file-based, type-safe client routing with auth guards via `beforeLoad`.

The single most important version constraint: `@auth/core` must be pinned to exactly `0.37.0`. Installing a newer version causes runtime errors because `@convex-dev/auth@0.0.91` has a hard peer dependency on `^0.37.0`. Similarly, `@dnd-kit/react` is at pre-1.0 (0.3.x) — stable `@dnd-kit/core@6.3.1` + `@dnd-kit/sortable@10.0.0` should be the fallback if the new API proves unstable during implementation.

**Core technologies:**
- **Convex 1.34.1**: Backend + real-time database + auth — eliminates separate API server and WebSocket layer
- **React 19 + Vite 8**: UI framework + dev server — fast HMR, native ESM
- **TanStack Router 1.168.10**: Type-safe file-based routing with auth guards — no flash of protected content
- **Tailwind v4 + shadcn/ui**: CSS-first utility styling + accessible component primitives — no tailwind.config.js, use `@theme` in CSS
- **@convex-dev/auth 0.0.91**: Auth framework — Password provider + invite-only `createOrUpdateUser` callback
- **@dnd-kit/react 0.3.2**: Drag-and-drop — new consolidated API (pre-1.0, have fallback ready)
- **Vitest + feather-testing-convex**: Testing — in-memory Convex backend wired into React provider tree; no network needed for tests
- **Zod 4 + react-hook-form + @hookform/resolvers**: Forms + validation — one Zod schema validates both client forms and Convex function args

### Expected Features

Research surveyed the competitive landscape (Todoist, Linear, Basecamp, Things 3, Sunsama, Toggl, Notion) and verified which features are table stakes vs. differentiators for small teams. Full details in `FEATURES.md`.

**Must have (table stakes):**
- Task creation with title + description (markdown)
- Kanban board (To Do / In Progress / Done) with drag-and-drop between columns
- Task assignment (single assignee) and due dates
- Sub-tasks (one level) and checklists on tasks
- Flat chronological comments/discussion on tasks
- Project organization (shared/personal toggle)
- Full-text search across tasks, comments, projects, resources
- Dashboard/home with glanceable status (inbox count, today's tasks, recent activity)
- Invite-only email/password auth
- Real-time updates (free with Convex — not even an engineering task)

**Should have (CalmDo differentiators):**
- **GTD Inbox** with focused card-based triage flow — unique in team PM space
- **Today/Focus list** with daily reset and due-today auto-population — Sunsama charges $20/month for this alone
- **Activity Log** as personal work journal (separate from comments) — no competitor makes this distinction
- **Integrated time tracking** via activity log entries (timer + manual) — most PM tools require a separate Toggl/Harvest subscription

**Defer to v2+:**
- Notifications (push/email) — real-time updates handle in-app; out-of-app notifications are a product unto themselves
- Recurring tasks — edge cases (timezone, skip behavior, early completion) make this far more complex than it appears
- Mobile app — responsive web first, native later
- Reporting/analytics — simple dashboard is enough for 2-5 people
- AI features — premature; "calm" philosophy is about human intention

**Deliberate anti-features (do not build):**
- Task priorities, custom statuses, Gantt charts, task dependencies, automations, multiple views, custom fields, file uploads, OAuth/SSO

### Architecture Approach

The architecture is a single-layer SPA with Convex as the only backend. All data flows through `useQuery`/`useMutation` over a persistent WebSocket — no REST, no GraphQL, no separate API gateway. The critical pattern is **thin Public API + Model Layer**: Convex public functions (`convex/tasks.ts`) validate args and check auth, then delegate to plain TypeScript helpers in `convex/model/tasks.ts`. This keeps public functions under 10 lines, enables code reuse, and makes business logic testable in isolation. Every query uses `.withIndex()` — never `.filter()` — to prevent full table scans. The schema is defined up front (required for @convex-dev/auth) with indexes for every query pattern. Full schema, file structure, and data flow diagrams in `ARCHITECTURE.md`.

**Major components:**
1. **TanStack Router** — file-based route tree with `_authenticated.tsx` pathless layout route providing auth guard via `beforeLoad`; all protected routes inherit automatically
2. **Convex Public API Layer** (`convex/*.ts`) — thin wrappers: arg validation, `ensureAuthenticated()`, delegate to model layer
3. **Convex Model Layer** (`convex/model/*.ts`) — business logic as plain TypeScript functions; testable without Convex infra
4. **Convex Schema** (`convex/schema.ts`) — single file defining all tables with indexes; Convex generates TypeScript types automatically
5. **shadcn/ui Components** (`src/components/`) — reusable domain-specific UI (task-card, kanban-board, timer, checklist, activity-log)
6. **@convex-dev/auth** — Password provider + invite-only `createOrUpdateUser` callback checks `invites` table before allowing signup
7. **Cron Jobs** (`convex/crons.ts`) — daily focus list reset (clears `isFocused` flag on tasks where `focusDate` is not today)

### Critical Pitfalls

Seven critical pitfalls identified with prevention strategies. Full details in `PITFALLS.md`.

1. **Missing auth on public Convex functions** — every exported function is a public API endpoint. Build `authenticatedQuery`/`authenticatedMutation` wrapper functions in Phase 1 and use them everywhere. Never trust client-provided `userId` arguments.

2. **Query waterfalls from naive normalization** — a task detail page with 6+ independent `useQuery` calls cascades through loading states. Compose related data in single query functions using `Promise.all` internally: one `getTaskWithDetails` query returns task + subtasks + checklist items together.

3. **Client-side timer state** — storing timer in `useState`/`useRef` loses state on tab close, creates duplicates across tabs, and breaks on page refresh. Timer state belongs in Convex: store `startedAt` timestamp server-side; display is just `Date.now() - startedAt` computed on client.

4. **GTD inbox becoming a graveyard** — capture is easy, triage is hard. Design triage as card-based focused flow (one item at a time, three actions: move to project / trash / skip) before building the capture mechanism.

5. **Optimistic update state corruption** — mutating arrays/objects in place inside `withOptimisticUpdate` callbacks corrupts Convex's query cache. Always use spread: `[...items, newItem]` never `items.push(newItem)`.

6. **OCC conflicts on aggregate counters** — computing inbox count or task count by scanning the tasks table inside a query creates a large read set that conflicts with concurrent mutations. Denormalize counters into a `userStats` or `teamStats` table; plan this in Phase 1 schema even if the dashboard ships in Phase 4.

7. **@convex-dev/auth session confusion** — beta library with non-obvious account linking behavior. Mitigate by using exactly one auth method (email/password), implementing the invite flow with email verification, and testing the full auth lifecycle (signup, logout, login, password reset, session expiry) before building any features.

## Implications for Roadmap

Research from all four files converges on a clear 6-phase build order driven by the dependency graph in `ARCHITECTURE.md` and the pitfall prevention timeline in `PITFALLS.md`. The order is non-negotiable: schema and auth must come first because everything compiles against the schema and every function requires auth. Dashboard must come last because it aggregates data from every other feature.

### Phase 1: Foundation — Schema, Auth, App Shell

**Rationale:** Convex generates TypeScript types from schema, so the schema must exist before any function can be written. @convex-dev/auth requires `authTables` spread into the schema. Auth must be fully working before any protected feature is built — testing auth last means retrofitting it everywhere. The `_authenticated` layout route and `authenticatedQuery`/`authenticatedMutation` wrappers established here are reused by every subsequent phase.

**Delivers:** A working login/logout, invite-only signup via admin-created invite, auth-guarded route tree, empty app shell with navigation sidebar, all database tables defined with correct indexes.

**Addresses:** Invite-only auth (table stakes), real-time updates (free from Convex setup)

**Avoids:** Missing access control pitfall (wrappers built here), auth session confusion (single method, verified flow), TanStack Router auth flash (`beforeLoad` guard), OCC counter conflicts (stats table defined in schema now even if populated later)

**Research flags:** Auth setup needs careful attention — @convex-dev/auth is beta. Test full auth lifecycle before proceeding. No deeper research needed: official docs are thorough.

### Phase 2: Core Task Loop — Projects, Tasks, Kanban

**Rationale:** Tasks are the foundational entity everything else references (sub-tasks, comments, activity log, time entries, inbox triage targets). The kanban board is the primary interface users will live in. Getting task creation, kanban drag-and-drop, and the basic project structure right establishes the interaction patterns (optimistic updates, query composition) reused throughout the app.

**Delivers:** Project CRUD (shared/personal toggle), task CRUD with To Do / In Progress / Done statuses, kanban board with drag-and-drop, task assignment, due dates, position-based ordering.

**Addresses:** Kanban board (table stakes), task creation (table stakes), task assignment (table stakes), due dates (table stakes), project organization (table stakes)

**Avoids:** Optimistic update corruption (establish immutable spread pattern here with `updateStatus`), query waterfall (compose task queries server-side from day one)

**Research flags:** @dnd-kit/react 0.3.x is pre-1.0. Evaluate stability during implementation. If API is too unstable, fall back to @dnd-kit/core@6.3.1 + @dnd-kit/sortable@10.0.0 (stable, well-documented, same kanban examples exist).

### Phase 3: Task Depth — Sub-tasks, Checklists, Comments, Activity Log

**Rationale:** The complete task model (sub-tasks + checklists + comments + activity log) should be built together before introducing GTD inbox or time tracking, because inbox triage produces tasks (and optionally links resources to them) and time tracking attaches to tasks via activity log entries. Building the full task object model here prevents schema changes later.

**Delivers:** Sub-tasks (one level, same capabilities as tasks), checklists on tasks and sub-tasks, flat chronological comments, activity log (personal work journal entries with optional time field).

**Addresses:** Sub-tasks (table stakes), checklists (table stakes), comments/discussion (table stakes), activity log (differentiator)

**Avoids:** Query waterfall — `getTaskWithDetails` query must compose all of these in one call; no 6+ independent `useQuery` calls per task detail page.

**Research flags:** Standard patterns, no research needed. The `parentTable` discriminator pattern for checklists/comments/activity log (works across both tasks and subTasks) is well-established and documented in `ARCHITECTURE.md`.

### Phase 4: GTD + Focus — Inbox, Today/Focus List, Triage Flow

**Rationale:** GTD inbox and Today/Focus list are CalmDo's primary differentiators. They depend only on tasks (inbox triage creates tasks; focus list stars tasks). Building them after the complete task model ensures triage flows correctly. The inbox graveyard pitfall means triage UX design must precede capture implementation — design and build the triage flow first, then add quick capture.

**Delivers:** GTD inbox (private per user, quick capture via single text field), card-based triage flow (one item at a time: move to project / trash / skip), inbox count badge on dashboard, Today/Focus list (star tasks to focus, daily reset cron, due-today auto-population), focus list page.

**Addresses:** GTD inbox (differentiator), Today/Focus list (differentiator)

**Avoids:** GTD inbox graveyard — triage UX is the hard part. Design the three-action triage card before the capture input. "Skip" is non-destructive (item moves to bottom, not deleted).

**Research flags:** The UX for triage flow is not a technical problem — it is a product design problem. Consider a brief UX prototype or wireframe review before implementation. The card-based triage pattern (one item at a time) is borrowed from spaced repetition apps (Anki) and email apps (Spark mail triage) — not a novel pattern but needs deliberate execution.

### Phase 5: Time Tracking + Learning Resources

**Rationale:** Time tracking builds directly on the activity log (timer stop creates an activity log entry). Learning resources are standalone (URL + summary + optional task link) and add team knowledge base value without depending on GTD or focus features. Both are differentiators that complete CalmDo's unique value proposition.

**Delivers:** Start/stop timer (server-side state machine in Convex — `startedAt` timestamp, not client `setInterval`), manual time entry, time rolled up to task level, orphaned timer detection cron (auto-stop timers running > 12 hours), learning resources (URL + summary + optional tags + optional task link), resource search.

**Addresses:** Integrated time tracking (differentiator), learning resources/team knowledge base (differentiator)

**Avoids:** Client-side timer state pitfall — timer state must live in Convex. One active timer per user enforced by mutation guard.

**Research flags:** Timer implementation needs careful design as a server-side state machine. The `by_user_running` index on `timeEntries` (where `endTime` is undefined = running timer) is defined in the schema — verify this index query pattern works correctly in Convex before building the UI.

### Phase 6: Dashboard, Search, Admin

**Rationale:** Dashboard requires every other feature to exist because it aggregates inbox count, active tasks, focus items, and recent activity. Search benefits from having content to index. Admin (user management + invite UI) can use a seeded first admin for all previous phases and only needs its UI now.

**Delivers:** Dashboard (inbox count, today's focus items, recent activity feed, active task count), full-text search across tasks, projects, comments, learning resources, admin panel (invite creation, user list, role management).

**Addresses:** Dashboard/home page (table stakes), search (table stakes), invite-only auth admin UI (completes Phase 1's backend-only invite system)

**Avoids:** OCC conflicts on aggregate counters — the `userStats`/`teamStats` denormalization planned in Phase 1 schema pays off here. Dashboard reads from pre-computed counters, not full table scans.

**Research flags:** Convex full-text search is built-in but has limitations (no fuzzy matching, no stemming). Research the Convex search API capabilities and limitations before implementing. If Convex search is insufficient, evaluate Orama (client-side) or Typesense (external service). Standard pattern for everything else in this phase.

### Phase Ordering Rationale

- **Schema and auth before everything:** Convex type generation requires schema. Auth wrappers required by every subsequent mutation.
- **Tasks before inbox:** Inbox triage creates tasks. Can't triage to a non-existent task model.
- **Complete task model before GTD:** Inbox items triage to tasks with sub-tasks and checklists optionally linked. Building GTD before the full task model means retrofitting.
- **Activity log before time tracking:** Timer stop writes an activity log entry. Coupling is intentional.
- **Dashboard last:** Genuinely depends on all other features for meaningful content and correct counter values.
- **Focus reset cron in Phase 4, counter denormalization planned in Phase 1:** Cron jobs are cheap to add; counter schema decisions are expensive to retrofit.

### Research Flags

Phases needing deeper research or careful implementation:

- **Phase 1 (Auth):** @convex-dev/auth is beta. Invite-only pattern uses `createOrUpdateUser` callback — verify behavior with password reset flow and session expiry before proceeding to Phase 2. No additional external research needed; docs are thorough.
- **Phase 2 (Kanban/DnD):** @dnd-kit/react 0.3.x is pre-1.0. Evaluate stability on first use. Decision point: if API is too volatile, swap to stable @dnd-kit/core@6.3.1 — this is a Phase 2 decision, not a Phase 1 concern.
- **Phase 6 (Search):** Convex built-in search limitations need verification before committing to implementation approach. Run `/gsd:research-phase` on Convex search capabilities.

Phases with standard, well-documented patterns (skip research-phase):

- **Phase 3 (Task Depth):** Standard Convex patterns. `parentTable` discriminator well-documented in architecture research.
- **Phase 4 (GTD/Focus):** Technical patterns standard; UX design is the risk. Product design review, not technical research.
- **Phase 5 (Time Tracking):** Server-side timer state pattern is clear from pitfalls research. Implementation is straightforward if the schema is correct.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All versions verified via npm registry on 2026-04-03. Compatibility matrix fully documented. One medium-confidence item: @dnd-kit/react 0.3.x pre-1.0 stability. |
| Features | HIGH | Competitive landscape thoroughly surveyed. Anti-features are well-reasoned. Feature dependencies clearly mapped. |
| Architecture | HIGH | Patterns sourced from official Convex docs and Convex team blog (stack.convex.dev). Invite-only pattern: MEDIUM (inferred from callback docs, not explicitly documented as a pattern). |
| Pitfalls | HIGH | Seven critical pitfalls all sourced from official docs or documented community experience. OCC and timer pitfalls are particularly well-evidenced. |

**Overall confidence:** HIGH

### Gaps to Address

- **@dnd-kit/react 0.3.x stability:** No production usage evidence found yet. Decision to use vs. fall back to stable API should be made in Phase 2 after a 30-minute spike. The fallback (@dnd-kit/core + @dnd-kit/sortable) is battle-tested.
- **Zod 4 + convex-helpers compatibility:** Zod 4 is a major version jump. The STACK.md notes this needs verification. Run `npm install zod@4 convex-helpers` and check for peer dep warnings before Phase 1 schema work.
- **Convex search limitations:** Full-text search capabilities, token limits, and fuzzy matching support need verification before Phase 6 search implementation. Add `/gsd:research-phase` flag for Phase 6.
- **Invite-only auth pattern:** The `createOrUpdateUser` callback pattern for invite enforcement is inferred from Convex Auth docs rather than explicitly shown as a complete example. Build a working proof-of-concept in Phase 1 before treating this as solved.

## Sources

### Primary (HIGH confidence)
- [Convex Docs](https://docs.convex.dev/) — schema design, best practices, optimistic updates, auth, cron jobs, indexes
- [Convex Stack Blog](https://stack.convex.dev/) — authorization patterns, OCC, query performance, model layer pattern
- [Convex Auth Docs](https://labs.convex.dev/auth/) — Password provider setup, createOrUpdateUser callback, security, FAQ
- [TanStack Router Docs](https://tanstack.com/router/latest/docs/) — file-based routing, authenticated routes, beforeLoad
- [Tailwind v4 Docs](https://tailwindcss.com/blog/tailwindcss-v4) — Vite plugin, CSS-based config, @theme directive
- [shadcn/ui Docs](https://ui.shadcn.com/docs/) — installation, Form component, react-hook-form integration
- npm registry — all version numbers verified 2026-04-03

### Secondary (MEDIUM confidence)
- [dnd-kit Kanban Example (GitHub)](https://github.com/Georgegriff/react-dnd-kit-tailwind-shadcn-ui) — dnd-kit + shadcn/ui kanban patterns
- [Opinionated Convex Guidelines (community gist)](https://gist.github.com/srizvi/966e583693271d874bf65c2a95466339) — project structure, function organization
- [Why PM tools fail small teams](https://complex.so/insights/why-most-project-management-tools-fail-small-teams-(and-what-to-use-instead)) — anti-feature rationale

### Tertiary (LOW confidence / needs validation)
- @dnd-kit/react 0.3.x — pre-1.0, limited production usage documented. Needs Phase 2 spike.
- Convex search for full-text across multiple tables — capabilities not fully tested; needs Phase 6 research.

---
*Research completed: 2026-04-03*
*Ready for roadmap: yes*
