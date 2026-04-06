# CalmDo

## What This Is

A calm project management web app for small teams (2-5 people). Combines GTD-style inbox capture with shared/personal projects, time tracking, activity logging, and a team knowledge base. Built for teams moving from ad hoc notes and messages to structured but lightweight project management.

## Core Value

Every team member can capture thoughts instantly, triage them into projects, focus on today's work, and share what they've learned — without ceremony or overhead.

## Current Milestone: v1.0 CalmDo MVP

**Goal:** Ship a usable project management app that the team deploys and uses from day one — logging work and tracking tasks immediately.

**Target features:**
- Auth (login/invite), app shell, basic project + task creation, Vercel deployment
- Kanban board with DnD, task assignment, due dates, activity log with manual time entry
- Sub-tasks, checklists, comments with @mentions
- GTD inbox with card-based triage, Today/Focus list with daily reset
- Start/stop timer, time rollups, billable tracking, learning resources
- Dashboard, full-text search, admin panel

**Phase order priority:** Thinnest deployable slice first → layer depth. Activity log + manual time entry in Phase 2 (core workflow). Start/stop timer deferred to Phase 5.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] GTD inbox for quick task capture, with periodic triage to move items into projects
- [ ] Shared projects (default) with toggle to make a project personal
- [ ] Personal inbox items (private by default)
- [ ] Tasks with kanban workflow: To Do, In Progress, Done
- [ ] Optional due dates on tasks
- [ ] Optional single assignee on tasks (unassigned tasks can be picked up by anyone)
- [ ] One-level sub-tasks with same capabilities as parent tasks
- [ ] Checklists on both tasks and sub-tasks
- [ ] Comments (discussion thread) on tasks and sub-tasks
- [ ] Activity log (work journal) on tasks — separate from comments, entries have optional time
- [ ] Time logging: start/stop timer and manual entry, tied to activity log entries
- [ ] Today/Focus list: star tasks to focus on them today, resets daily, due-today tasks auto-appear
- [ ] Learning resources: URL + summary, standalone or linked to tasks, shared with team
- [ ] Dashboard landing page: inbox count, active tasks, recent activity
- [ ] Invite-only signup (admin creates accounts), email/password login
- [ ] 100% automated test coverage using feather-testing-convex MECE approach

### Out of Scope

- Task priorities — position in list implies priority
- Unlimited sub-task nesting — one level deep is sufficient
- OAuth/SSO login — email/password is sufficient for a small team
- Mobile app — web-first, mobile later
- Notifications — defer to v2
- Custom task statuses per project — fixed kanban (To Do / In Progress / Done)
- Real-time chat — not a communication tool

## Context

**Team:** Small team (2-5 people) with no formal project management tool. Currently using ad hoc notes, docs, and messages. Need lightweight structure without the heaviness of enterprise PM tools.

**GTD workflow:** The team follows a GTD-inspired approach — capture quickly, triage periodically, focus on what matters today. The inbox is the entry point; triage sessions process inbox items into projects or discard them.

**Knowledge sharing:** When team members do research, they find URLs and extract learnings. These need to be shared internally as a team knowledge base, searchable and optionally linked to the tasks that prompted the research.

**Activity vs comments:** Activity log entries are work journal entries ("what I did + optional time spent"). Comments are discussion threads. These are deliberately separate — activity is a personal log, comments are team conversation.

**Testing philosophy:** The project uses feather-testing-convex which wires convex-test's in-memory backend into React's provider tree. Components test against real Convex functions — no mocks for data, full coverage. MECE decomposition: one test per visual state, integration by default, mocks only for transient states.

## Constraints

- **Stack**: React 19 + Vite, TanStack Router, Convex (backend + real-time), shadcn/ui (Radix + Tailwind), @convex-dev/auth
- **Testing**: Vitest + feather-testing-convex + feather-testing-core (Phoenix Test-inspired DSL), Playwright for E2E, 100% coverage target
- **Team size**: Designed for 2-5 people — no complex role/permission systems needed
- **Auth model**: Invite-only signup, email/password login via @convex-dev/auth
- **State management**: Convex useQuery for all server state, React state for local UI only

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Convex over traditional backend | Real-time by default, no API layer to build, in-memory testing via convex-test | — Pending |
| TanStack Router over React Router | Type-safe routing, file-based route definitions | — Pending |
| TanStack Router over TanStack Start | Convex IS the backend — SSR/server functions add unnecessary complexity | — Pending |
| shadcn/ui over other UI libs | Best AI code generation support, Radix accessibility, full source control | — Pending |
| Convex useQuery over TanStack Query | Real-time reactivity is the core value for collaborative PM, simpler mental model | — Pending |
| No task priorities | Small team, list position implies priority — avoids priority inflation | — Pending |
| One-level sub-tasks + checklists | Checklists remove the need for deeper nesting, keeps data model simple | — Pending |
| Activity log separate from comments | Activity = personal work journal with optional time; comments = team discussion | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2025-07-14 after milestone v1.0 start*
