# Feature Landscape

**Domain:** Small-team project management (2-5 people) with GTD inbox, time tracking, and team knowledge base
**Researched:** 2026-04-03
**Confidence:** HIGH (well-understood domain with mature competitive landscape)

## Table Stakes

Features users expect from any small-team PM tool. Missing any of these and the product feels incomplete or unfinished -- users will leave for Todoist, Linear, or Basecamp instead.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Task creation with title + description | Every PM tool has this. Users cannot function without it. | Low | Rich text description (markdown) is expected, not plain text |
| Kanban board (To Do / In Progress / Done) | Standard visual workflow. Todoist, Linear, Asana, Trello all have boards. | Medium | Drag-and-drop between columns is mandatory. Fixed statuses (not customizable) is fine for small teams -- Linear proved this. |
| Task assignment (single assignee) | Teams need to know who owns what. Every competitor has this. | Low | "Unassigned" as default is good -- small teams self-assign. |
| Due dates on tasks | Todoist, Asana, Linear all have due dates. Users need deadline awareness. | Low | Optional, not required per task. Date picker, no time-of-day needed for v1. |
| Sub-tasks (one level) | Asana has unlimited nesting, but most users only use 1 level. Linear uses sub-issues. Todoist has sub-tasks. | Medium | Same capabilities as parent (assignee, status, due date). One level is a deliberate design choice, not a limitation -- checklists handle further breakdown. |
| Checklists on tasks | Things 3 pioneered checklists-within-tasks. Trello, Asana, GitHub Issues all have them. | Low | Simple ordered list with checkboxes. No assignee/due date on checklist items -- that's what sub-tasks are for. |
| Comments/discussion on tasks | Every PM tool has task comments. Users expect to discuss work in context. | Medium | Threaded or flat is a design choice. Flat (chronological) is simpler and sufficient for small teams. @mentions are expected. |
| Search | Users must find tasks, projects, resources. Not finding things is a dealbreaker. | Medium | Full-text search across tasks, projects, comments, learning resources. Convex supports this well. |
| Project organization | Group related work. Every competitor has projects/workspaces. | Low | Shared by default with personal toggle. List of projects in sidebar. |
| Dashboard / home page | Users need a landing page showing what matters. Linear has "My Issues", Todoist has "Today", Basecamp has the home screen. | Medium | Inbox count, today's tasks, recent activity. Not a complex analytics dashboard -- a glanceable status page. |
| Invite-only auth (email/password) | Small teams need controlled access. OAuth/SSO is unnecessary overhead. | Low | Admin creates accounts. Simple and secure. @convex-dev/auth handles this. |
| Real-time updates | When a teammate changes a task, you see it instantly. Convex provides this by default. | Low (free with Convex) | This is table stakes in 2026. Basecamp, Linear, Notion all update in real-time. Convex gives this for free -- huge advantage. |

## Differentiators

Features that set CalmDo apart from competitors. Not expected, but create unique value. These are the reasons someone would choose CalmDo over Todoist + Toggl + Notion.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **GTD Inbox (capture + triage)** | No small-team PM tool does GTD-style inbox well. Things 3 has it but is personal-only. Todoist has an inbox but no triage workflow. CalmDo's inbox-to-project flow is unique in the team PM space. | Medium | Private by default (personal capture). Triage = move to project or discard. Quick capture must be frictionless (keyboard shortcut, minimal fields). The inbox count on the dashboard creates gentle pressure to triage. |
| **Today/Focus list** | Sunsama charges $20/month just for daily focus planning. Things 3 has "Today" but is personal-only. CalmDo integrates this into a team PM tool for free. Daily reset + due-today auto-appearing is the key differentiator. | Medium | Star tasks to focus. Resets daily (starred items return to their project). Due-today tasks auto-appear. This is the "calm" in CalmDo -- what matters today, nothing else. |
| **Activity Log (work journal with optional time)** | Separate from comments. No competitor cleanly separates "what I did" from "team discussion." Basecamp has check-ins but they're team-wide, not task-scoped. This is a personal work journal tied to tasks. | Medium | Each entry: timestamp + text + optional duration. Chronological, personal, not threaded. Shows up on the task but is conceptually different from comments. Feeds into time tracking. |
| **Integrated time tracking** | Most PM tools either don't have time tracking (Linear, Basecamp) or require a separate tool (Toggl, Harvest). CalmDo bakes it in via activity log entries. Timer + manual entry, no separate timesheet. | Medium | Start/stop timer creates an activity log entry. Manual entry for after-the-fact logging. Time rolls up to task/project level. No invoicing, no billing -- just "how long did this take?" |
| **Learning resources (team knowledge base)** | No PM tool combines task management with a curated link library. Notion has wikis but no task management baked in. Todoist/Linear have zero knowledge features. URL + summary, standalone or task-linked. | Medium | URL + summary + optional tags. Can be standalone (general team knowledge) or linked to a task (research for this specific work). Searchable. Team-shared by default. |
| **Activity log separate from comments** | Deliberate UX separation: "what I did" vs "what we're discussing." No competitor makes this distinction. This prevents work journals from being buried in discussion threads. | Low (design, not code) | Two tabs or sections on a task: "Discussion" (comments) and "Activity" (work log). The separation is the feature -- most tools mush these together. |

## Anti-Features

Features to deliberately NOT build. These are traps that create complexity without proportional value for a 2-5 person team. Each one is a conscious decision, not an omission.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Task priorities (P1/P2/P3/Critical/etc.)** | Priority inflation is inevitable. Small teams spend more time debating priority levels than doing work. Linear removed priorities from their core workflow. | Position in list implies priority. Drag tasks up = more important. The Today/Focus list handles "what matters right now." |
| **Custom task statuses per project** | Multiplies complexity. Each project becomes its own snowflake. Enterprise teams need this; 2-5 person teams do not. | Fixed kanban: To Do / In Progress / Done. Three statuses. Done. If a task needs more granularity, use checklists or sub-tasks. |
| **Gantt charts / timeline views** | Wrong tool for wrong team. Small teams don't plan 6 months ahead with task dependencies mapped on a timeline. Gantt charts are for construction projects and enterprise PMOs. | Kanban board + due dates. If you need to see what's coming, sort by due date. |
| **Task dependencies (blocks/blocked-by)** | Formal dependencies create a maintenance burden. In a 2-5 person team, you just talk to each other. Dependencies are a communication problem, not a tooling problem. | Comments on tasks. "Hey, I need X finished before I can start this." A @mention is faster than configuring a dependency graph. |
| **Automations / workflow rules** | "When status changes to Done, assign next task to..." This is enterprise tooling. Small teams don't need bots managing their 20-task backlog. Monday.com and ClickUp sell this; it's bloat for small teams. | Manual workflow. Move the card yourself. It takes 2 seconds. |
| **Multiple views (list, board, calendar, timeline, table)** | Each view is a maintenance and testing burden. Todoist has 4 views; none of them are great. Better to have one excellent board view than four mediocre views. | Kanban board as primary view. List view for Today/Focus. That's it. Two views, done well. |
| **Custom fields on tasks** | "Add a dropdown for department, a number field for story points, a date field for..." This is how Asana and Monday.com become unusable. Every custom field is a checkbox nobody fills in. | Built-in fields cover it: title, description, assignee, due date, status, checklist. If you need more metadata, put it in the description. |
| **File attachments / uploads** | Storage, CDN, virus scanning, preview rendering, quota management. Massive engineering cost for a feature that Google Drive / Dropbox already solves. | Paste links to files in comments or description. Learning resources handle URL sharing. |
| **Notifications system** | Push notifications, email digests, in-app notification bells, notification preferences per project... This is a product unto itself. | Defer to v2. Real-time updates (Convex) mean you see changes when you're in the app. For v1, "open the app and check" is sufficient for a 2-5 person team that sits in the same Slack. |
| **Recurring tasks** | Seems simple ("repeat every Monday") but edge cases are nightmarish: what happens when you complete early? When you skip? When the recurrence pattern changes? Time zones? | Not in v1. If a task recurs, create it again. A 2-5 person team has maybe 3 recurring tasks -- the overhead of manually creating them is lower than the engineering cost of recurring task logic. |
| **OAuth/SSO login** | Engineering overhead for SAML, OIDC, provider-specific quirks. Unnecessary for a 2-5 person team where the admin creates accounts manually. | Email/password via @convex-dev/auth. Simple, secure, sufficient. |
| **Mobile app** | Two platforms (iOS + Android), responsive design constraints, app store reviews, push notification infrastructure. Each is a major engineering investment. | Web-first. Responsive web design for mobile browsers. Native app is a v2+ concern. |
| **AI features (auto-categorize, smart suggestions, AI summaries)** | Trendy but premature. AI features require significant engineering, ongoing API costs, and often produce mediocre results that erode trust. The "calm" philosophy is about human intention, not algorithmic suggestion. | Ship the core product. If users ask for AI features after launch, evaluate then. Don't build AI because it's 2026 and everyone else is. |
| **Reporting / analytics dashboards** | Charts showing "tasks completed per week" and "average time to close" are enterprise metrics. A 5-person team knows who's doing what without a burndown chart. | Dashboard shows: inbox count, my active tasks, recent team activity. Glanceable status, not analytics. |
| **Unlimited sub-task nesting** | Asana allows infinite nesting. Users create 5-level-deep hierarchies that nobody can navigate. Complexity for complexity's sake. | One level of sub-tasks + checklists. If your task needs sub-sub-tasks, it's actually multiple tasks in a project. |

## Feature Dependencies

```
Auth (invite-only signup)
  └── Everything else (all features require auth)

Projects
  ├── Tasks (tasks belong to projects)
  │   ├── Sub-tasks (sub-tasks belong to tasks)
  │   │   └── Checklists on sub-tasks
  │   ├── Checklists on tasks
  │   ├── Comments/Discussion
  │   ├── Activity Log
  │   │   └── Time Tracking (timer + manual entry create activity log entries)
  │   └── Task ↔ Learning Resource links
  └── Kanban Board (visual representation of tasks in a project)

GTD Inbox (standalone, private per user)
  └── Triage workflow (move inbox item → task in project, or discard)

Today/Focus List (cross-cutting)
  ├── Requires: Tasks (to star them)
  └── Requires: Due dates (for auto-appearing due-today)

Learning Resources (standalone OR task-linked)
  └── Optional link to: Tasks

Dashboard
  ├── Requires: GTD Inbox (inbox count)
  ├── Requires: Tasks (active tasks list)
  ├── Requires: Activity Log (recent activity feed)
  └── Requires: Today/Focus (today's focus items)

Search (cross-cutting)
  └── Indexes: Tasks, Projects, Comments, Learning Resources
```

## MVP Recommendation

### Phase 1: Foundation (must ship first)
1. **Auth** -- invite-only signup, email/password login
2. **Projects** -- create, list, shared/personal toggle
3. **Tasks with kanban** -- To Do / In Progress / Done, drag-and-drop
4. **Sub-tasks** -- one level, same capabilities as tasks
5. **Checklists** -- on tasks and sub-tasks

**Rationale:** This is the minimum viable structure. Without projects and tasks, nothing else works. Sub-tasks and checklists round out the task model so it doesn't need to change later.

### Phase 2: Collaboration
6. **Comments/Discussion** -- flat chronological on tasks/sub-tasks
7. **Task assignment** -- single assignee
8. **Due dates** -- optional per task

**Rationale:** Makes it usable by a team, not just a solo user.

### Phase 3: Differentiators
9. **GTD Inbox** -- quick capture, triage to project or discard
10. **Today/Focus list** -- star tasks, daily reset, due-today auto-appears
11. **Activity Log** -- work journal entries with optional time on tasks

**Rationale:** These are CalmDo's unique value. Ship them once the foundation is solid.

### Phase 4: Knowledge + Time
12. **Time Tracking** -- timer + manual entry, tied to activity log
13. **Learning Resources** -- URL + summary, standalone or task-linked
14. **Dashboard** -- inbox count, today's tasks, recent activity

**Rationale:** Time tracking builds on activity log. Learning resources are standalone. Dashboard ties everything together -- ship it last because it needs everything else to exist.

### Phase 5: Polish
15. **Search** -- full-text across all entities

**Rationale:** Search is essential but benefits from having content to search. Ship after there's data in the system.

### Defer to v2
- **Notifications** -- real-time updates (Convex) handle the in-app case; push/email notifications are a v2 concern
- **Recurring tasks** -- edge cases make this far more complex than it appears
- **Mobile app** -- responsive web first, native later
- **Reporting** -- simple dashboard is enough; analytics are enterprise

## Sources

- [Things 3 GTD review](https://thesweetsetup.com/apps/best-personal-gtd-app-suite/) -- Things 3's GTD approach, checklists-within-tasks pattern
- [Linear conceptual model](https://linear.app/docs/conceptual-model) -- Linear's opinionated workflow, minimal status set
- [Linear for small teams](https://everhour.com/blog/linear-project-management/) -- Linear's approach to small team PM
- [Basecamp features](https://www.proofhub.com/articles/basecamp-project-management/) -- Basecamp's simplicity-first philosophy
- [Todoist team features](https://www.todoist.com/teamwork) -- Todoist's team collaboration approach
- [Notion wiki/knowledge base](https://www.notion.com/product/wikis) -- Notion's wiki and knowledge management
- [Sunsama daily planning](https://www.sunsama.com/daily-planning) -- Sunsama's Today/Focus approach at $20/month
- [Toggl time tracking practices](https://toggl.com/blog/time-tracking-best-practices) -- Time tracking UX patterns
- [GTD workflow (Todoist)](https://www.todoist.com/productivity-methods/getting-things-done) -- GTD capture/clarify/organize/reflect/engage
- [Why PM tools fail small teams](https://complex.so/insights/why-most-project-management-tools-fail-small-teams-(and-what-to-use-instead)) -- Anti-patterns in small-team PM
- [Small team PM best practices](https://complex.so/insights/small-team-project-management-best-practices) -- Simplicity over features
- [PM anti-patterns (Jade Rubick)](https://www.rubick.com/three-anti-patterns-for-project-management/) -- Over-engineering PM process
