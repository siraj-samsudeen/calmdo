# Requirements: CalmDo

**Defined:** 2026-04-03
**Core Value:** Every team member can capture thoughts instantly, triage them into projects, focus on today's work, and share what they've learned — without ceremony or overhead.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Authentication & Access

- [ ] **AUTH-01**: First admin account is created during deployment setup
- [ ] **AUTH-02**: Admin can invite users by email; users can only sign up via an invite link
- [ ] **AUTH-03**: User can log in with email and password
- [ ] **AUTH-04**: User can reset their password via email link
- [ ] **AUTH-05**: User can log out from any page
- [ ] **AUTH-06**: Admin can view all team members and deactivate accounts

### Navigation

- [ ] **NAV-01**: App has persistent navigation allowing access to Dashboard, Inbox, Today/Focus, Projects list, and Learning Resources from any page

### Projects

- [ ] **PROJ-01**: User can create a project with name and description (shared with all team members by default)
- [ ] **PROJ-02**: User can view all shared projects and their own personal projects
- [ ] **PROJ-03**: User can toggle a project to personal (visible only to creator)
- [ ] **PROJ-04**: User can archive a project

### Tasks

- [ ] **TASK-01**: User can create a task with title and markdown description within a project
- [ ] **TASK-02**: User can view tasks on a kanban board with columns: To Do, In Progress, Done
- [ ] **TASK-03**: User can drag-and-drop tasks between kanban columns to change status
- [ ] **TASK-04**: User can assign a task to a single team member (optional, unassigned by default)
- [ ] **TASK-05**: User can set an optional due date on a task
- [ ] **TASK-06**: User can reorder tasks within a kanban column via drag-and-drop

### Sub-tasks

- [ ] **SUBT-01**: User can create sub-tasks within a task (one level deep, same capabilities as parent tasks: status, assignee, due date)
- [ ] **SUBT-02**: User can view and reorder sub-tasks as a list within the parent task

### Checklists

- [ ] **CHKL-01**: User can add a checklist to a task or sub-task
- [ ] **CHKL-02**: User can manage checklist items (add, check, uncheck, reorder, delete) with completion progress shown

### Comments

- [ ] **CMNT-01**: User can add comments to tasks and sub-tasks
- [ ] **CMNT-02**: User can @mention team members in comments

### Activity Log

- [ ] **ALOG-01**: User can add an activity log entry to a task with text and optional time duration
- [ ] **ALOG-02**: Activity log is visually separate from comments (different tab or section)
- [ ] **ALOG-03**: Stopping a running timer automatically creates an activity log entry

### Time Tracking

- [ ] **TIME-01**: User can start and stop a timer on a task (only one active timer at a time — starting a new one auto-stops the previous)
- [ ] **TIME-02**: User can manually add a time entry with duration and description
- [ ] **TIME-03**: Time entries roll up to show total time per task and per project
- [ ] **TIME-04**: User can mark a time entry as billable
- [ ] **TIME-05**: User can set a monthly time budget per project (e.g., 8 hours)
- [ ] **TIME-06**: Dashboard shows alert when billable time is below 80% or above 120% of a project's monthly budget (thresholds configurable)
- [ ] **TIME-07**: User can generate and export a monthly billable time report (CSV) for a project, showing date, task, description, and hours

### GTD Inbox

- [ ] **INBX-01**: User can quickly capture a thought or task idea in their personal inbox
- [ ] **INBX-02**: User can edit an inbox item's title and add a description before triaging
- [ ] **INBX-03**: User can triage inbox items: move to a project (becomes a task) or discard

### Today / Focus

- [ ] **TDAY-01**: User can star any task to add it to their Today/Focus list
- [ ] **TDAY-02**: Today list resets daily per user's local timezone (stars are cleared, tasks return to their projects)
- [ ] **TDAY-03**: Tasks with today's due date automatically appear in the Today list

### Learning Resources

- [ ] **LRSC-01**: User can create a learning resource with a URL and summary
- [ ] **LRSC-02**: Learning resources can exist standalone or be linked to a specific task
- [ ] **LRSC-03**: Learning resources are shared with the entire team
- [ ] **LRSC-04**: User can assign tags to resources for categorization (e.g., AI, PM, React)
- [ ] **LRSC-05**: User can star/favorite individual resources
- [ ] **LRSC-06**: When a user clicks a resource's URL, the visit count increments; resources with higher visit counts appear higher in the resource list
- [ ] **LRSC-07**: User can browse all learning resources in a searchable, filterable list (by tags, favorites, recency)

### Dashboard

- [ ] **DASH-01**: Dashboard shows the current user's inbox item count
- [ ] **DASH-02**: Dashboard shows today's focus/starred tasks
- [ ] **DASH-03**: Dashboard shows the 20 most recent team actions (task creation, status changes, comments, activity log entries) across all accessible projects
- [ ] **DASH-04**: Dashboard shows billable time budget alerts (over/under threshold) for active projects

### Search

- [ ] **SRCH-01**: User can search full-text across task titles and descriptions, project names, comment bodies, and learning resource URLs, summaries, and tags

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Horizon Scanning

- **HRZN-01**: Tasks due within a configurable window (default 1 week) subtly appear at the bottom of the Today list
- **HRZN-02**: User can dismiss horizon items after reviewing them
- **HRZN-03**: Multi-day tasks surface early based on due date proximity

### Client Access

- **CLNT-01**: User can invite external clients to specific projects with limited (read-only) access
- **CLNT-02**: Client users see only the projects they've been invited to
- **CLNT-03**: Client role is distinct from team member role

### Notifications

- **NOTF-01**: User receives in-app notifications for @mentions
- **NOTF-02**: User receives email notifications for task assignments
- **NOTF-03**: User can configure notification preferences

### Other

- **RCUR-01**: User can set a task to recur on a schedule
- **MOBI-01**: Native mobile app (iOS/Android) or progressive web app

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Task priorities (P1/P2/P3) | Position in list implies priority; avoids priority inflation |
| Custom task statuses per project | Fixed kanban (To Do / In Progress / Done) is sufficient for 2-5 people |
| Gantt charts / timeline views | Wrong tool for small teams |
| Task dependencies (blocks/blocked-by) | Small teams communicate directly; @mention in comments suffices |
| Automations / workflow rules | Enterprise tooling; 2-5 person teams don't need bots |
| Multiple views (calendar, table, timeline) | One kanban board + Today list, done well |
| Custom fields on tasks | Built-in fields cover all needs; extras go in description |
| File attachments / uploads | Link to Google Drive/Dropbox in comments or description |
| OAuth/SSO login | Email/password via @convex-dev/auth is sufficient |
| AI features | Ship core product first; evaluate AI features post-launch |
| Analytics / reporting dashboards | Simple dashboard is enough; enterprise analytics are bloat |
| Unlimited sub-task nesting | One level + checklists covers all cases |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 | Pending |
| AUTH-02 | Phase 1 | Pending |
| AUTH-03 | Phase 1 | Pending |
| AUTH-04 | Phase 6 | Pending |
| AUTH-05 | Phase 1 | Pending |
| AUTH-06 | Phase 6 | Pending |
| NAV-01 | Phase 1 | Pending |
| PROJ-01 | Phase 1 | Pending |
| PROJ-02 | Phase 1 | Pending |
| PROJ-03 | Phase 1 | Pending |
| PROJ-04 | Phase 1 | Pending |
| TASK-01 | Phase 1 | Pending |
| TASK-02 | Phase 2 | Pending |
| TASK-03 | Phase 2 | Pending |
| TASK-04 | Phase 2 | Pending |
| TASK-05 | Phase 2 | Pending |
| TASK-06 | Phase 2 | Pending |
| SUBT-01 | Phase 3 | Pending |
| SUBT-02 | Phase 3 | Pending |
| CHKL-01 | Phase 3 | Pending |
| CHKL-02 | Phase 3 | Pending |
| CMNT-01 | Phase 3 | Pending |
| CMNT-02 | Phase 3 | Pending |
| ALOG-01 | Phase 2 | Pending |
| ALOG-02 | Phase 2 | Pending |
| ALOG-03 | Phase 5 | Pending |
| TIME-01 | Phase 5 | Pending |
| TIME-02 | Phase 2 | Pending |
| TIME-03 | Phase 5 | Pending |
| TIME-04 | Phase 5 | Pending |
| TIME-05 | Phase 5 | Pending |
| TIME-06 | Phase 5 | Pending |
| TIME-07 | Phase 5 | Pending |
| INBX-01 | Phase 4 | Pending |
| INBX-02 | Phase 4 | Pending |
| INBX-03 | Phase 4 | Pending |
| TDAY-01 | Phase 4 | Pending |
| TDAY-02 | Phase 4 | Pending |
| TDAY-03 | Phase 4 | Pending |
| LRSC-01 | Phase 5 | Pending |
| LRSC-02 | Phase 5 | Pending |
| LRSC-03 | Phase 5 | Pending |
| LRSC-04 | Phase 5 | Pending |
| LRSC-05 | Phase 5 | Pending |
| LRSC-06 | Phase 5 | Pending |
| LRSC-07 | Phase 5 | Pending |
| DASH-01 | Phase 6 | Pending |
| DASH-02 | Phase 6 | Pending |
| DASH-03 | Phase 6 | Pending |
| DASH-04 | Phase 6 | Pending |
| SRCH-01 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 51 total
- Mapped to phases: 51
- Unmapped: 0

---
*Requirements defined: 2026-04-03*
*Last updated: 2025-07-14 after roadmap v1.0 rewrite*
