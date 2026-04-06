# Roadmap: CalmDo

## Overview

CalmDo delivers a calm project management app for small teams in six vertical slices. Each phase ships a complete, usable feature that a user can interact with and verify. Auth, schema, and navigation are embedded in the first feature phase rather than isolated as infrastructure. The build order follows data dependencies: tasks exist before sub-tasks, tasks exist before inbox triage creates them, activity log exists before time tracking writes to it, and dashboard aggregates everything last.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Projects & Kanban** - User can log in, create projects, and manage tasks on a drag-and-drop kanban board
- [ ] **Phase 2: Task Depth** - User can break tasks into sub-tasks, add checklists, and discuss work via comments
- [ ] **Phase 3: GTD Inbox & Today Focus** - User can capture thoughts in a personal inbox, triage them into projects, and focus on today's work
- [ ] **Phase 4: Activity Log & Time Tracking** - User can journal work on tasks, track time with a timer, and manage billable hours with budgets
- [ ] **Phase 5: Learning Resources** - User can build a shared team knowledge base of URLs and learnings
- [ ] **Phase 6: Dashboard, Search & Admin** - User can see a unified dashboard, search across everything, and manage team members

## Phase Details

### Phase 1: Projects & Kanban
**Goal**: A team member can log in, see shared and personal projects, create tasks, and move them across a kanban board
**Depends on**: Nothing (first phase)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-05, NAV-01, PROJ-01, PROJ-02, PROJ-03, PROJ-04, TASK-01, TASK-02, TASK-03, TASK-04, TASK-05, TASK-06
**Success Criteria** (what must be TRUE):
  1. User can sign up via an admin-created invite link, log in with email/password, and log out from any page
  2. User can navigate between Dashboard (placeholder), Inbox (placeholder), Today (placeholder), Projects, and Learning Resources (placeholder) from a persistent sidebar
  3. User can create a project (shared by default), toggle it to personal, view all accessible projects, and archive a project
  4. User can create tasks within a project, view them on a kanban board (To Do / In Progress / Done), drag tasks between columns and reorder within columns
  5. User can assign a task to a team member and set an optional due date
**Plans**: TBD
**UI hint**: yes

### Phase 2: Task Depth
**Goal**: A user can decompose tasks into sub-tasks, track progress with checklists, and discuss work through comments
**Depends on**: Phase 1
**Requirements**: SUBT-01, SUBT-02, CHKL-01, CHKL-02, CMNT-01, CMNT-02
**Success Criteria** (what must be TRUE):
  1. User can create sub-tasks within a task (one level deep) with the same capabilities as parent tasks (status, assignee, due date) and reorder them
  2. User can add a checklist to any task or sub-task, manage items (add, check, uncheck, reorder, delete), and see completion progress
  3. User can add comments to tasks and sub-tasks, and @mention team members in comments
**Plans**: TBD
**UI hint**: yes

### Phase 3: GTD Inbox & Today Focus
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

### Phase 4: Activity Log & Time Tracking
**Goal**: A user can maintain a work journal on tasks, track time with start/stop timers and manual entries, and manage billable hours against project budgets
**Depends on**: Phase 2
**Requirements**: ALOG-01, ALOG-02, ALOG-03, TIME-01, TIME-02, TIME-03, TIME-04, TIME-05, TIME-06, TIME-07
**Success Criteria** (what must be TRUE):
  1. User can add activity log entries (text + optional time duration) to a task, visually separate from comments
  2. User can start/stop a timer on a task (one active timer at a time -- starting a new one auto-stops the previous) and stopping creates an activity log entry
  3. User can manually add time entries with duration and description, and mark entries as billable
  4. Time entries roll up to show total time per task and per project, with configurable monthly budgets per project
  5. User can generate and export a monthly billable time report (CSV) for a project
**Plans**: TBD
**UI hint**: yes

### Phase 5: Learning Resources
**Goal**: A user can curate and share a team knowledge base of URLs with summaries, tags, and usage tracking
**Depends on**: Phase 1
**Requirements**: LRSC-01, LRSC-02, LRSC-03, LRSC-04, LRSC-05, LRSC-06, LRSC-07
**Success Criteria** (what must be TRUE):
  1. User can create a learning resource with URL and summary, either standalone or linked to a specific task
  2. User can assign tags to resources and star/favorite them
  3. Clicking a resource URL increments its visit count, and higher-visited resources appear higher in the list
  4. User can browse all learning resources in a searchable, filterable list (by tags, favorites, recency)
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
| 1. Projects & Kanban | 0/0 | Not started | - |
| 2. Task Depth | 0/0 | Not started | - |
| 3. GTD Inbox & Today Focus | 0/0 | Not started | - |
| 4. Activity Log & Time Tracking | 0/0 | Not started | - |
| 5. Learning Resources | 0/0 | Not started | - |
| 6. Dashboard, Search & Admin | 0/0 | Not started | - |
