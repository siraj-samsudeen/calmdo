# Phase 1: Foundation & Deploy - Context

**Gathered:** 2025-07-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 1 delivers the thinnest usable slice of CalmDo: a team member can sign up via an admin-created invite link, log in with email/password, navigate the app shell, create projects (shared/personal), and create tasks within projects displayed as a simple list. The app is deployed and live on Vercel with working auth and real-time data via Convex.

**In scope:** AUTH-01, AUTH-02, AUTH-03, AUTH-05, NAV-01, PROJ-01, PROJ-02, PROJ-03, PROJ-04, TASK-01
**Not in scope:** Kanban (Phase 2), sub-tasks/checklists/comments (Phase 3), inbox/today (Phase 4), timers (Phase 5), dashboard/search (Phase 6)

</domain>

<decisions>
## Implementation Decisions

### Invite & Auth Flow
- **D-01:** Admin bootstrapping via **seed script** — run a CLI command (`npx convex run auth:createAdmin`) after deploy to create the first admin with email/password. No special-case signup logic.
- **D-02:** Invite links are **manual link sharing** — admin generates an invite link in the UI, copies it, shares via Slack/email/etc. No email service required in Phase 1.
- **D-03:** Invite tokens are **single-use**, tied to an email, expire after **7 days**. Admin sees a list of pending invites in the UI.
- **D-04:** Login page is a **centered card** — clean centered form with logo, email + password fields, sign-in button. Minimal, no distractions. Classic SaaS style.

### App Shell & Sidebar
- **D-05:** Sidebar is **fixed, always visible** (~220px wide). Never collapses. Simple and always-accessible.
- **D-06:** Sidebar layout: **top:** logo + app name. **Middle:** nav items with icons (Dashboard, Inbox, Today/Focus, Projects, Learning Resources). **Bottom:** user avatar + name with dropdown menu (logout).
- **D-07:** Placeholder pages (Dashboard, Inbox, Today, Learning Resources) show **simple empty states** — relevant icon + short description of what's coming (e.g., "Capture your thoughts here — inbox coming soon").
- **D-08:** **Basic responsive** behavior — sidebar becomes a hamburger menu on mobile, content area adapts. Low effort with Tailwind.

### Project List & Detail
- **D-09:** Project list displays as **simple list/rows** — name, description, type badge. Compact and scannable.
- **D-10:** Shared vs personal projects separated by **tabs** — "Shared" tab and "Personal" tab.
- **D-11:** Archiving is **soft archive** — archived projects disappear from main list, accessible via an "Archived" tab/filter, can be restored. No confirmation dialog.
- **D-12:** New project creation via **modal dialog** — "+" button opens modal with name (required), description (optional), and shared/personal toggle. Shared is default.

### Task List Within Projects
- **D-13:** Task list uses **info-rich rows** — title + first line of description + status badge (To Do / In Progress / Done) per row.
- **D-14:** Clicking a task opens a **slide-out side panel** on the right. Task list stays visible on the left for context.
- **D-15:** Markdown description renders as **read-only markdown** by default. Click "Edit" button to switch to a plain textarea for editing. No rich editor in Phase 1.
- **D-16:** New task creation via **inline "+ Add task" input** at the bottom of the list. Type title, press Enter for fast capture. Edit details in side panel after.

### Claude's Discretion
- **D-03** (invite token details): Claude chose single-use tokens per email with 7-day expiry as the right fit for a 2-5 person team.
- **D-06** (sidebar layout): Claude chose standard SaaS sidebar — logo top, nav middle, user dropdown bottom.
- **D-07** (placeholder pages): Claude chose simple empty states with icon + short "coming soon" description.
- **D-12** (project creation): Claude chose modal over inline form — cleaner, doesn't clutter the list.
- **D-15** (markdown editing): Claude chose read-only render + edit button → textarea. Simplest approach, no editor library needed.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project & Requirements
- `.planning/PROJECT.md` — Core value, constraints, key decisions, team context
- `.planning/REQUIREMENTS.md` — All requirement IDs with acceptance criteria; Phase 1 reqs: AUTH-01, AUTH-02, AUTH-03, AUTH-05, NAV-01, PROJ-01 through PROJ-04, TASK-01
- `.planning/ROADMAP.md` — Phase 1 success criteria and dependency chain

### Stack & Architecture
- `research/STACK.md` (embedded in CLAUDE.md) — Full technology stack with versions, compatibility matrix, Convex patterns, and "What NOT to Use" guidance
- Critical: @auth/core must be pinned to 0.37.0
- Critical: Use @tailwindcss/vite (v4), NOT tailwind.config.js
- Critical: TanStack Router plugin must be listed BEFORE @vitejs/plugin-react in vite config

### Auth Reference
- Convex Auth Setup: https://labs.convex.dev/auth/setup
- Convex Auth Passwords: https://labs.convex.dev/auth/config/passwords
- Password provider imported from `@convex-dev/auth/providers/Password`, uses `flow` field for sign-up vs sign-in

No external specs beyond the above — requirements fully captured in decisions.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Greenfield project** — no existing code. Phase 1 creates the foundation that all subsequent phases build on.

### Established Patterns
- None yet. Phase 1 establishes:
  - Convex schema with authTables
  - TanStack Router file-based routing structure
  - shadcn/ui component patterns
  - Auth provider wrapping
  - cn() utility (clsx + tailwind-merge)

### Integration Points
- Convex backend: schema.ts, functions in convex/ directory
- TanStack Router: file-based routes in src/routes/
- Auth: ConvexAuthProvider wrapping the app
- Vercel: deployment config, Convex production deployment

</code_context>

<specifics>
## Specific Ideas

- Login page should feel "calm" — minimal, centered, no visual noise
- The app name is "CalmDo" — sidebar should show this as branding
- Task list is explicitly pre-kanban: a simple list that will evolve into kanban in Phase 2
- Inline task creation ("+ Add task" → Enter) is important for fast capture, matching the GTD philosophy

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-foundation-deploy*
*Context gathered: 2025-07-14*
