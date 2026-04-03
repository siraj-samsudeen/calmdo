# Pitfalls Research

**Domain:** Small-team project management with GTD inbox, time tracking, and team knowledge base
**Stack:** Convex + React 19 + TanStack Router + shadcn/ui + @convex-dev/auth + feather-testing-convex
**Researched:** 2026-04-03
**Confidence:** HIGH (majority sourced from official Convex docs, TanStack docs, community best practices)

## Critical Pitfalls

### Pitfall 1: Convex Schema Over-Normalization Causing Query Waterfalls

**What goes wrong:**
Developers coming from SQL backgrounds normalize everything into separate tables (tasks, subtasks, checklists, comments, activity_logs, users). Each Convex `useQuery` call is a separate subscription. A task detail page that loads task + subtasks + checklist items + comments + activity log entries + user avatars creates 6+ parallel queries, each returning `undefined` independently. The UI cascades through loading states, flickers, and feels sluggish despite Convex being real-time.

**Why it happens:**
Convex is "document-relational" -- it supports references via `Id<'table'>` but every `db.get()` or `db.query()` in a query function counts toward bandwidth. Developers apply SQL normalization habits to a document database without considering query composition costs.

**How to avoid:**
- Start normalized (separate tables for tasks, subtasks, checklists, comments, activity entries) -- this is correct for Convex
- But compose related data in **single query functions** that return a hydrated object (e.g., `getTaskWithDetails` that fetches task + subtasks + checklist items in one query function, returning a denormalized response)
- Use `Promise.all` inside query functions to parallelize related lookups
- Only denormalize into the schema itself (storing redundant data) for computed aggregates like inbox count or active task count -- use the Convex aggregate component or manual denormalization with mutations that update counters
- Never use `.filter()` on large tables -- always use `.withIndex()`

**Warning signs:**
- Task detail page shows multiple skeleton states loading at different times
- Dashboard takes 500ms+ to render despite small dataset
- Component tree has 5+ independent `useQuery` calls for one "page"

**Phase to address:**
Phase 1 (Schema + Core Data Layer). Get the schema right before building UI. Define query functions that return composed data from the start.

---

### Pitfall 2: Running Timers That Die When the Browser Closes

**What goes wrong:**
Time tracking with a start/stop timer is implemented client-side with `setInterval` or `Date.now()` diffs. User starts a timer, closes the laptop lid, switches tabs, or navigates away. Timer stops counting. Worse: user has two tabs open and starts a timer in each, creating duplicate time entries. The timer shows "00:00:00" on page reload because state was in React state, not persisted.

**Why it happens:**
Browsers throttle or suspend JavaScript in background tabs. `setInterval` is unreliable in unfocused tabs. Client-side timers lose state on page reload. Developers treat the timer as a UI concern when it is fundamentally a **server-side state machine**.

**How to avoid:**
- Store timer state server-side in Convex: `{ taskId, userId, startedAt: number | null, status: "running" | "stopped" }`
- The **display** is derived: `elapsed = Date.now() - startedAt` (calculated on the client from server timestamps)
- Stop the timer by writing `stoppedAt` to the server, computing duration as `stoppedAt - startedAt`
- On page load, check for a running timer via `useQuery` -- if `startedAt` is set and `status === "running"`, resume the display
- Use Convex's real-time sync: all tabs see the same timer state automatically
- Add a Convex cron job to detect orphaned timers (running > 12 hours without activity) and auto-stop them
- Enforce one active timer per user via a mutation guard: before starting a new timer, stop any existing running timer

**Warning signs:**
- Timer state stored in `useState` or `useRef`
- `setInterval` used for timer tick
- No "resume timer" logic on page load
- Users reporting lost time entries

**Phase to address:**
Phase 3 (Time Tracking). Design the timer as a server-side state machine from day one. Never store timer state in React.

---

### Pitfall 3: GTD Inbox That Becomes a Graveyard

**What goes wrong:**
The inbox accumulates items faster than users triage them. Without friction-reducing design, items pile up (20, 50, 100+), and the inbox becomes anxiety-inducing rather than calming. Users stop using capture because the inbox feels overwhelming, defeating the entire GTD philosophy. The app becomes "another thing to manage" instead of reducing cognitive load.

**Why it happens:**
- Capture is easy (low friction to add) but triage is hard (each item requires a decision: which project? delete? defer?)
- Triage UI requires too many clicks: select item -> choose project -> choose status -> confirm
- No visual feedback loop showing progress ("you triaged 5 of 8 items")
- No distinction between quick-triage items and items needing thought
- Inbox shows all items equally, creating decision paralysis

**How to avoid:**
- Design triage as a **focused flow**: show one item at a time (card-based triage), not a list. Each item gets: "Move to project [X]" / "Trash" / "Skip for now". Three actions max.
- Add inbox count to dashboard as a gentle nudge, not an alarm
- Auto-suggest project assignment based on text content or recent projects
- Add a "quick add to project" shortcut that bypasses inbox entirely (for when users know where it goes)
- Frame "Skip" as provisional, not permanent -- skipped items fade to bottom, not disappear
- Consider a "batch triage" mode: select multiple items -> assign to same project
- Cap inbox display at 10-15 items per triage session to reduce overwhelm

**Warning signs:**
- Average inbox item age > 7 days
- Users with 30+ items in inbox
- Low triage completion rate (users open inbox but don't process items)
- Users stop using inbox capture altogether

**Phase to address:**
Phase 2 (GTD Inbox + Triage). Design the triage UX before building the capture mechanism. The hard part is processing, not capturing.

---

### Pitfall 4: Optimistic Updates That Corrupt Client State

**What goes wrong:**
Developer uses `Array.push()` or object mutation inside an optimistic update callback. Convex's internal state is corrupted because the optimistic update mutated a shared reference. Symptoms: items appear/disappear randomly, lists show duplicate entries, UI state becomes permanently wrong until page refresh.

**Why it happens:**
Convex optimistic updates receive the current query cache by reference. Mutating this reference (`existingItems.push(newItem)`) corrupts the cache. JavaScript developers are accustomed to mutating arrays and objects in place.

**How to avoid:**
- **Always create new objects** in optimistic update callbacks: `[...existingItems, newItem]` not `existingItems.push(newItem)`
- Use spread operators for objects: `{ ...existingTask, status: "done" }` not `existingTask.status = "done"`
- Add a lint rule or code review checklist item: "No mutations in optimistic update callbacks"
- Accept that optimistic update timestamps and IDs will mismatch server values -- design UI to handle the brief flicker when real data arrives
- Only use optimistic updates for actions where perceived latency matters (task status changes, checkbox toggles) -- skip them for less latency-sensitive operations (comments, activity log entries)

**Warning signs:**
- `Array.prototype.push`, `splice`, `sort` or direct property assignment inside optimistic update functions
- Intermittent UI glitches that resolve on page refresh
- Duplicate items appearing briefly in lists

**Phase to address:**
Phase 2 (Task Management UI). Establish optimistic update patterns in the first interactive feature and reuse the pattern everywhere.

---

### Pitfall 5: Missing Access Control on Public Convex Functions

**What goes wrong:**
Every `query`, `mutation`, and `action` in Convex is a public API endpoint callable by anyone. Without auth checks, a malicious user (or automated script) can read all tasks, modify other users' data, delete projects, or escalate privileges. Unlike traditional REST APIs where routes are explicitly exposed, Convex functions are automatically exposed via the `api` object.

**Why it happens:**
Convex's developer experience is so smooth that it feels like "internal code" -- developers forget that every public function is an attack surface. The small team context ("it's just 5 of us") creates a false sense of security. Auth checks feel like boilerplate.

**How to avoid:**
- Create a `convex/lib/auth.ts` helper that wraps `ctx.auth.getUserIdentity()` and throws if unauthenticated
- Build custom function wrappers: `authenticatedQuery`, `authenticatedMutation` that enforce auth before the handler runs
- For team-scoped data: every query/mutation must verify the requesting user belongs to the team/project
- Use `internal` prefix for functions that should only be called server-side (crons, scheduled functions)
- Never trust client-provided arguments for authorization decisions (user ID, email, role) -- always derive from `ctx.auth`
- Audit: grep for `export const` in `convex/` files and verify each public function has an auth check

**Warning signs:**
- Query/mutation functions that don't call `ctx.auth.getUserIdentity()` in the first few lines
- Functions using client-provided `userId` argument to determine what data to return
- Mix of `api.*` and `internal.*` references passed to `ctx.scheduler`

**Phase to address:**
Phase 1 (Auth + Core Setup). Establish auth wrapper pattern before writing any business logic. Every subsequent function uses the wrapper.

---

### Pitfall 6: OCC Conflicts on Shared Counters and Aggregates

**What goes wrong:**
Dashboard shows "Inbox: 12 | Active: 8 | Done Today: 3". These counters are computed by querying all tasks and counting in the query function. As team members simultaneously create tasks, move tasks between statuses, and triage inbox items, mutations that read the same rows conflict via Convex's Optimistic Concurrency Control. The system retries, throughput drops, and users see "Too many retries" errors during active collaboration.

**Why it happens:**
Convex uses serializable transactions. Two mutations that read and write overlapping data sets cannot execute in parallel. A dashboard counter query that scans all tasks creates a massive read set that conflicts with any task mutation.

**How to avoid:**
- **Denormalize counters**: maintain `inboxCount`, `activeTaskCount`, `doneTaskCount` in a separate `teamStats` table. Increment/decrement in the same mutation that creates/moves tasks.
- Use the **hot/cold table pattern**: separate frequently-updated fields (status, assignee) from rarely-read fields (description, creation metadata) if conflict analysis shows the need
- For the dashboard, query the pre-computed stats table, not the tasks table
- Use **precise index ranges**: `db.query("tasks").withIndex("by_status", q => q.eq("status", "inbox")).collect()` is better than scanning all tasks and filtering
- Consider the Convex `aggregate` component for maintaining counts reactively

**Warning signs:**
- Dashboard query function uses `.collect()` on entire tasks table
- Multiple team members see "mutation failed, retrying" logs simultaneously
- Mutations that update task status also trigger dashboard re-renders with full table scans

**Phase to address:**
Phase 4 (Dashboard + Analytics). But plan the stats denormalization pattern in Phase 1 schema design, even if the dashboard comes later.

---

### Pitfall 7: @convex-dev/auth Session and Account Linking Confusion

**What goes wrong:**
User signs up with email/password (untrusted method -- no email verification). Later, admin invites them or they try to link a different auth method. Because the original account is "untrusted," Convex Auth's account linking logic creates a second user document for the same email, or a trusted method silently links to the unverified account without confirmation. Result: orphaned data, split identities, or security vulnerabilities.

**Why it happens:**
@convex-dev/auth is in beta/early preview. Email+password without email verification is classified as "untrusted." The account linking behavior between trusted and untrusted methods is documented but non-obvious. Small teams skip email verification because "it's just us."

**How to avoid:**
- Implement email verification even for small teams -- the invite flow should include a verification step
- Use **only one authentication method** (email+password) to avoid the trusted/untrusted mixing problem entirely. CalmDo's design already specifies this.
- Store both `sessionId` and `userId` on user-created documents -- sessions expire and get replaced, so documents tied only to sessions lose their association
- Understand that Convex Auth stores tokens in `localStorage` by default -- all tabs share the same session, which is correct for this app
- Monitor the @convex-dev/auth GitHub repo for breaking changes (beta status means the API may change)

**Warning signs:**
- Multiple user documents with the same email in the `users` table
- Auth-related errors in console after session timeout
- Users unable to log in after password reset

**Phase to address:**
Phase 1 (Auth Setup). Choose one auth method, implement verification, and test the full flow (signup, login, logout, password reset, session expiry) before building features.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Skip indexes, use `.filter()` everywhere | Faster initial development | Queries slow down at 1000+ docs, bandwidth costs increase, potential OCC conflicts | Never -- define indexes from the start, they cost nothing until the table is large |
| Store all UI state in React instead of URL | Simpler component code | Breaks back button, sharing links, bookmarks; filter/sort state lost on refresh | Only for truly transient state (dropdown open/closed, tooltip visible) |
| Generic `updateTask` mutation with spread args | One mutation handles all updates | Attackers can modify any field; hard to add field-level validation; no audit trail | Never -- use granular mutations (`moveTaskToProject`, `changeTaskStatus`, `assignTask`) |
| Skip return validators on Convex functions | Less boilerplate | Type safety is one-directional (args only); runtime errors when return shape changes | Only during rapid prototyping; add validators before marking phase complete |
| Use `Date.now()` in Convex queries | Simple date comparisons | Query cache invalidation on every call; stale results for time-dependent logic | Never in queries -- pass rounded timestamps as arguments, or use scheduled functions to set flags |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| TanStack Router + Convex Auth | Checking auth in React components with `useConvexAuth()`, causing flash of unauthenticated content before redirect | Use TanStack Router's `beforeLoad` in a pathless `_authenticated` layout route to redirect before rendering. Pass auth state via router context. |
| shadcn/ui Form + Convex mutations | Calling `useMutation` directly in form `onSubmit`, losing error handling and loading state | Create a `useAction`-style wrapper or use `useMutation` with `.then()/.catch()`. Handle mutation errors in UI (toast/inline), not just console. |
| Convex `useQuery` + React Suspense | Assuming `useQuery` works with `<Suspense>` boundaries for loading states | Convex `useQuery` returns `undefined` while loading, it does not throw promises. Handle loading explicitly with conditional rendering or use `useQueryWithStatus` from convex-helpers. |
| TanStack Router file-based routing + Convex | Misnamed route files causing 404s or wrong route matching; not using pathless layout routes for shared layouts | Follow TanStack Router's naming conventions exactly. Use `_layout` prefix for pathless routes. Run the route generator and verify the tree. |
| feather-testing-convex + auth-dependent functions | Testing authenticated functions without setting up auth context in tests | feather-testing-convex wires convex-test's in-memory backend into React. For auth-dependent functions, mock `ctx.auth.getUserIdentity()` at the convex-test level, not the React level. |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Loading all tasks with `.collect()` on unindexed table | Slow dashboard, high Convex bandwidth usage | Use indexed queries with `.withIndex()`, paginate large collections, denormalize counts | 500+ tasks (realistic for a team using the app daily for 6+ months) |
| Subscribing to queries that change frequently (presence, typing indicators) | Excessive re-renders, UI jank, wasted bandwidth | Store frequently-changing data in separate tables from stable data (hot/cold pattern); use separate Convex documents for presence vs. task data | 3+ concurrent users actively editing |
| `useQuery` for every small piece of data | Component re-renders for unrelated data changes, visual flicker | Compose related data into single query functions; use `useStableQuery` from convex-helpers to avoid intermediate `undefined` flicker on param changes | Any data-dense page (task detail with subtasks, checklists, comments) |
| Rendering long task lists without virtualization | Scrolling lag, high memory usage, slow initial paint | Use `@tanstack/react-virtual` for lists > 50 items; paginate at the Convex query level with `.paginate()` | 100+ tasks in a single view (kanban column or task list) |
| Loading full user objects for every avatar/mention display | N+1 query pattern, slow renders | Denormalize `userName` and `avatarUrl` onto task/comment documents, or batch-load users in the query function with `Promise.all` | Any page showing 10+ user references (activity feed, comments) |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| No auth check on `query` functions ("it's just reading data") | Unauthenticated users can read all tasks, comments, and activity logs | Every public query must verify `ctx.auth.getUserIdentity()` is not null. Use `authenticatedQuery` wrapper. |
| Using client-provided `userId` in arguments to filter data | User A can pass User B's ID to see their personal inbox or private projects | Always derive `userId` from `ctx.auth.getUserIdentity()` on the server. Never trust client arguments for identity. |
| Storing passwords or secrets in Convex documents | Plaintext credential exposure via any query that returns the document | @convex-dev/auth handles password hashing internally. Never store raw secrets in your own tables. Use Convex environment variables for API keys. |
| Invite-only signup without rate limiting | Attacker brute-forces invite codes or spams signup endpoint | Use Convex's built-in rate limiting (or implement with a counter table + scheduled cleanup). Invalidate invite tokens after use. |
| Public `action` functions that call external APIs | Attacker can trigger expensive external API calls (email sending, etc.) at scale | Make API-calling actions `internal` only. Expose a public mutation that validates + queues, then a cron/scheduled action that processes. |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No empty states -- blank pages when no tasks/projects exist | New users see a blank app and don't know what to do | Add contextual empty states with a single primary action: "Create your first project", "Capture your first thought" |
| Inbox capture requires choosing a category/project upfront | Friction kills capture velocity; users stop using inbox | Inbox capture = text only. One field, one button. Project assignment happens during triage, not capture. |
| Activity log and comments in the same UI section | Users confuse personal work journal with team discussion; activity entries get "replied to" | Visually separate: activity log = chronological personal entries with optional time; comments = threaded discussion. Different tabs or sections, not interleaved. |
| "Today" focus list resets without warning | User comes back after lunch, their focus list is empty because it auto-reset at midnight | Show "Yesterday's focus" as a collapsed section for 24 hours. Auto-reset at a configurable time (default 4am, not midnight). Warn before reset with a toast. |
| Kanban board with drag-and-drop as the only way to change status | Mobile users can't drag; keyboard users can't change status; batch operations impossible | Always provide a dropdown/menu alternative to drag-and-drop. Support keyboard shortcuts (Cmd+1/2/3 for status). Allow multi-select + batch status change. |

## "Looks Done But Isn't" Checklist

- [ ] **Auth flow:** Test signup -> logout -> login -> password reset -> session expiry -> re-login. Often missing: redirect after login goes to root instead of intended page.
- [ ] **Real-time sync:** Open two browser tabs, create a task in one. Does it appear in the other within 1 second? Often missing: new items don't trigger re-render because the query subscription isn't set up correctly.
- [ ] **Timer persistence:** Start a timer, close the tab, open a new tab. Is the timer still running? Often missing: timer state is client-only.
- [ ] **Empty states:** Delete all tasks, all projects, all inbox items. Does every page have a meaningful empty state? Often missing: blank white pages.
- [ ] **Error states:** Disconnect wifi, try to create a task. Does the UI show an error? Does it retry? Often missing: silent failures with no user feedback.
- [ ] **Loading states:** Throttle network to slow 3G. Does every page show a loading indicator? Are there layout shifts when data loads? Often missing: content jump when `useQuery` transitions from `undefined` to data.
- [ ] **Access control:** Log out, hit a Convex function directly via the dashboard or API. Does it reject? Often missing: queries that return data without checking auth.
- [ ] **Sub-task completeness:** Complete all sub-tasks of a task. Does the parent task's progress indicator update? Often missing: denormalized progress counts not updated.
- [ ] **Triage completeness:** Triage an inbox item to a project. Does the inbox count on the dashboard update immediately? Often missing: counter denormalization not wired up.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Schema over-normalization (query waterfalls) | LOW | Refactor query functions to compose data server-side. Schema doesn't change -- only query function implementations. |
| Client-side timer state | MEDIUM | Migrate to server-side timer state. Need to add timer table, mutation guards, and orphan detection cron. Existing time entries may be lost. |
| GTD inbox graveyard | MEDIUM | Redesign triage UX. Add batch operations and one-at-a-time card triage mode. No data migration needed, but significant UI rework. |
| Corrupted client state from optimistic updates | LOW | Fix the mutation pattern (use spread instead of push). Client state self-heals on page refresh. No server data corruption. |
| Missing access control | HIGH | Audit every public function. Add auth checks. Potentially need to investigate if unauthorized access already occurred. Best fixed immediately. |
| OCC conflicts on shared counters | MEDIUM | Add denormalized stats table. Write a one-time migration script to compute initial values. Update all relevant mutations to maintain counters. |
| Auth account linking issues | HIGH | Manual database cleanup of duplicate user documents. Merge user data. Potentially losing some user associations. |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Schema over-normalization | Phase 1: Schema Design | Query functions return composed data; no component has > 2 independent `useQuery` calls for one view |
| Client-side timer state | Phase 3: Time Tracking | Timer survives page refresh; only one timer active per user; orphan detection cron exists |
| GTD inbox graveyard | Phase 2: GTD Inbox | Triage flow is < 3 taps per item; inbox count visible on dashboard; skip is non-destructive |
| Optimistic update corruption | Phase 2: Task Management | Code review checklist includes "no mutations in optimistic updates"; immutable patterns in all update callbacks |
| Missing access control | Phase 1: Auth Setup | `authenticatedQuery`/`authenticatedMutation` wrappers exist; no public function lacks auth check |
| OCC conflicts on counters | Phase 1: Schema Design (plan) + Phase 4: Dashboard (implement) | Stats table defined in schema; mutations increment/decrement atomically |
| Auth session confusion | Phase 1: Auth Setup | Single auth method configured; session persistence tested across tabs; password reset flow works end-to-end |
| `.filter()` on large tables | Phase 1: Schema Design | Every query uses `.withIndex()`; no `.filter()` calls in query functions; lint rule or review checklist |
| `Date.now()` in queries | Phase 1: Core Setup | No `Date.now()` calls inside query functions; scheduled functions used for time-dependent logic |
| TanStack Router auth flash | Phase 1: Auth + Routing | `beforeLoad` auth guard on `_authenticated` layout route; no flash of login page for authenticated users |

## Sources

- [Convex Best Practices (official docs)](https://docs.convex.dev/understanding/best-practices/)
- [Convex Other Recommendations](https://docs.convex.dev/understanding/best-practices/other-recommendations)
- [Convex OCC and Atomicity](https://docs.convex.dev/database/advanced/occ)
- [Convex Optimistic Updates](https://docs.convex.dev/client/react/optimistic-updates)
- [Convex Indexes and Query Performance](https://docs.convex.dev/database/reading-data/indexes/indexes-and-query-perf)
- [Optimize Transaction Throughput (Convex blog)](https://stack.convex.dev/high-throughput-mutations-via-precise-queries)
- [Convex Auth FAQ](https://labs.convex.dev/auth/faq)
- [Convex Auth Security](https://labs.convex.dev/auth/security)
- [Convex Authorization Best Practices](https://stack.convex.dev/authorization)
- [Convex Sessions as Middleware](https://stack.convex.dev/sessions-wrappers-as-middleware)
- [Convex Overreacting (useStableQuery)](https://stack.convex.dev/help-my-app-is-overreacting)
- [Testing React Components with Convex](https://stack.convex.dev/testing-react-components-with-convex)
- [convex-test (GitHub)](https://github.com/get-convex/convex-test)
- [Opinionated Convex Guidelines (community)](https://gist.github.com/srizvi/966e583693271d874bf65c2a95466339)
- [TanStack Router Protected Routes](https://tanstack.com/router/v1/docs/framework/react/how-to/setup-authentication)
- [TanStack Router File-Based Routing](https://tanstack.com/router/latest/docs/routing/file-based-routing)
- [GTD Inbox Hidden Dangers (Medium)](https://tfthacker.medium.com/the-hidden-dangers-of-the-gtd-inbox-and-how-to-overcome-them-b66295c79dca)
- [Inbox Zero Brittleness (Andy Matuschak)](https://notes.andymatuschak.org/z2Pg1CbUyvjV4jEoqmr8Xua)
- [shadcn/ui Best Practices 2026 (Medium)](https://medium.com/write-a-catalyst/shadcn-ui-best-practices-for-2026-444efd204f44)
- [Convex Auth Passwords Config](https://labs.convex.dev/auth/config/passwords)

---
*Pitfalls research for: CalmDo -- small-team PM with GTD inbox, time tracking, knowledge base*
*Researched: 2026-04-03*
