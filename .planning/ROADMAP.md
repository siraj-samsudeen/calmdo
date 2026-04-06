# Roadmap: CalmDo

## Overview

CalmDo ships in six phases optimized for production-first development. Phase 1 delivers the thinnest usable slice — auth, projects, basic task creation, and Vercel deployment — so the team can start using the app immediately. Each subsequent phase layers depth onto the core workflow. Activity log and manual time entry ship in Phase 2 (the user's top priority after basic tasks), while the full timer and advanced time features come in Phase 5. Dashboard aggregation comes last because it depends on all other features.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation & Deploy** - User can log in, create projects and tasks, and the app is live on Vercel
- [ ] **Phase 2: Core Task Loop + Activity Log** - User can manage tasks on a kanban board and log what they did with optional time
- [ ] **Phase 3: Task Depth** - User can break tasks into sub-tasks, add checklists, and discuss work via comments
- [ ] **Phase 4: GTD Inbox & Today Focus** - User can capture thoughts in a personal inbox, triage them into projects, and focus on today's work
- [ ] **Phase 5: Timer & Learning Resources** - User can track time with start/stop timers, manage billable hours, and build a shared knowledge base
- [ ] **Phase 6: Dashboard, Search & Admin** - User can see a unified dashboard, search across everything, and manage team members

## Phase Details

### Phase 1: Foundation & Deploy
**Goal**: A team member can sign up via invite, log in, create projects and tasks (simple list), and the app is deployed and live on Vercel
**Depends on**: Nothing (first phase)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-05, NAV-01, PROJ-01, PROJ-02, PROJ-03, PROJ-04, TASK-01
**Success Criteria** (what must be TRUE):
  1. User can sign up via an admin-created invite link, log in with email/password, and log out from any page
  2. User can navigate between Dashboard (placeholder), Inbox (placeholder), Today (placeholder), Projects, and Learning Resources (placeholder) from a persistent sidebar
  3. User can create a project (shared by default), toggle it to personal, view all accessible projects, and archive a project
  4. User can create tasks with title and markdown description within a project, displayed as a simple list
  5. App is deployed to Vercel with working auth and real-time data via Convex
**Plans**: TBD
**UI hint**: yes

### Phase 2: Core Task Loop + Activity Log
**Goal**: A user can manage tasks on a kanban board with drag-and-drop and log work done on tasks with optional time entries
**Depends on**: Phase 1
**Requirements**: TASK-02, TASK-03, TASK-04, TASK-05, TASK-06, ALOG-01, ALOG-02, TIME-02
**Success Criteria** (what must be TRUE):
  1. User can view tasks on a kanban board with columns: To Do, In Progress, Done
  2. User can drag-and-drop tasks between kanban columns and reorder within columns
  3. User can assign a task to a single team member and set an optional due date
  4. User can add activity log entries to a task with text and optional time duration
  5. Activity log is visually separate from comments (tab or section), and user can manually add time entries with duration and description
**Plans**: TBD
**UI hint**: yes

### Phase 3: Task Depth
**Goal**: A user can decompose tasks into sub-tasks, track progress with checklists, and discuss work through comments
**Depends on**: Phase 2
**Requirements**: SUBT-01, SUBT-02, CHKL-01, CHKL-02, CMNT-01, CMNT-02
**Success Criteria** (what must be TRUE):
  1. User can create sub-tasks within a task (one level deep) with the same capabilities as parent tasks (status, assignee, due date) and reorder them
  2. User can add a checklist to any task or sub-task, manage items (add, check, uncheck, reorder, delete), and see completion progress
  3. User can add comments to tasks and sub-tasks, and @mention team members in comments
**Plans**: TBD
**UI hint**: yes

### Phase 4: GTD Inbox & Today Focus
**Goal**: A user can quickly capture thoughts into a private inbox, triage them into projects as tasks, and curate a daily focus list
**Depends on**: Phase 1
**Requirements**: INBX-01, INBX-02, INBX-03, TDAY-01, TDAY-02, TDAY-03
**Success Criteria** (what must be TRUE):
  1. User can quickly capture a thought in their personal inbox and edit its title/description before triaging
  2. User can triage inbox items one at a time: move to a project (becomes a task), or discard
  3. User can star any task to add it to their Today/Focus list, and the list resets daily (stars cleared per user's local timezone)
  4. Tasks with today's due date automatically appear in the user's Today list
**Plans**: TBD
**UI hint**: yes

### Phase 5: Timer & Learning Resources
**Goal**: A user can track time with start/stop timers, manage billable hours with project budgets, export reports, and build a shared team knowledge base
**Depends on**: Phase 2
**Requirements**: TIME-01, TIME-03, TIME-04, TIME-05, TIME-06, TIME-07, ALOG-03, LRSC-01, LRSC-02, LRSC-03, LRSC-04, LRSC-05, LRSC-06, LRSC-07
**Success Criteria** (what must be TRUE):
  1. User can start/stop a timer on a task (one active timer at a time — starting a new one auto-stops the previous) and stopping creates an activity log entry
  2. Time entries roll up to show total time per task and per project
  3. User can mark time entries as billable, set a monthly time budget per project, and see alerts when billable time is below 80% or above 120% of budget
  4. User can generate and export a monthly billable time report (CSV) for a project
  5. User can create learning resources (URL + summary), standalone or linked to tasks, shared with the team
  6. User can assign tags, star/favorite resources, and browse all resources in a searchable filterable list sorted by visit count
**Plans**: TBD
**UI hint**: yes

### Phase 6: Dashboard, Search & Admin
**Goal**: A user can see a unified overview of their work, search across the entire app, reset their password, and (as admin) manage team members
**Depends on**: Phase 4, Phase 5
**Requirements**: DASH-01, DASH-02, DASH-03, DASH-04, SRCH-01, AUTH-04, AUTH-06
**Success Criteria** (what must be TRUE):
  1. Dashboard shows current user's inbox count, today's focus/starred tasks, and the 20 most recent team actions across all accessible projects
  2. Dashboard shows billable time budget alerts (over/under threshold) for active projects
  3. User can search full-text across task titles/descriptions, project names, comment bodies, and learning resource URLs/summaries/tags
  4. User can reset their password via email link
  5. Admin can view all team members and deactivate accounts
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Deploy | 0/0 | Not started | - |
| 2. Core Task Loop + Activity Log | 0/0 | Not started | - |
| 3. Task Depth | 0/0 | Not started | - |
| 4. GTD Inbox & Today Focus | 0/0 | Not started | - |
| 5. Timer & Learning Resources | 0/0 | Not started | - |
| 6. Dashboard, Search & Admin | 0/0 | Not started | - |
