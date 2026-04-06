# Requirements Review: CalmDo

**Reviewed:** 2026-04-03
**Reviewer:** Claude (against 55 v1 requirements in REQUIREMENTS.md)
**Method:** Four-lens analysis — User Journey Completeness, Edge Cases, Testability, Pitfalls

---

## Lens 1: User Journey Completeness

Walking through every distinct user workflow to find gaps.

### Journey: First-Time Setup (GAPS FOUND)

Admin invites user (AUTH-01) → User receives invite → User signs up (AUTH-02) → User logs in (AUTH-03) → User sees dashboard (DASH-01)

**Gap 1: Who is the first admin?** AUTH-01 says "admin can invite users" but there's no requirement for how the first admin account is created. Convex deployment seeding? Manual database entry? This is a bootstrap problem.

> **Suggest adding:** `AUTH-06: The first user account is created during deployment setup and has admin privileges`

**Gap 2: No admin user management.** AUTH-01 covers inviting, but there's no way to view team members, deactivate accounts, or change roles. For a 2-5 person team this might be OK initially, but you'll need it when someone leaves.

> **Suggest adding:** `AUTH-07: Admin can view a list of all team members and deactivate accounts`

**Gap 3: No password reset.** AUTH-03 covers login, but what happens when someone forgets their password? @convex-dev/auth supports this, but it's not in the requirements.

> **Suggest adding:** `AUTH-08: User can reset their password via email link`

**Gap 4: No logout.** Implied but not stated.

> **Suggest adding:** `AUTH-09: User can log out from any page`

### Journey: Daily Workflow (COMPLETE)

Log in → Dashboard (inbox count, today's tasks, activity, billable alerts) → Triage inbox → Open project → Work on tasks → Start timer → Stop timer (auto-logs activity) → Comment to teammate → Star tasks for tomorrow → Save a useful article → Search for something

**No gaps.** Every step maps to a requirement.

### Journey: Triage Session (MINOR GAP)

Open inbox → See items → For each item: move to project or discard (INBX-03) → ...

**Gap 5: Can you edit an inbox item before triaging?** INBX-01 captures a "thought or task idea." INBX-03 moves it to a project. But can you refine the title, add a description, or set initial fields before moving? If you capture "fix that thing" at 2am, you might want to edit it to "fix the login redirect bug" before triaging.

> **Suggest adding:** `INBX-05: User can edit an inbox item's title and add a description before triaging`

### Journey: Learning Resource Discovery (GAP FOUND)

I find a useful article → I save it (LRSC-01) → ... → Later, I want to find it again → ...

**Gap 6: No resources list page.** LRSC-01 says create, LRSC-04 says tags, LRSC-05 says favorites. But there's no requirement for browsing or listing resources. Where do they live in the UI? How do I find them outside of search?

> **Suggest adding:** `LRSC-07: User can browse all learning resources in a searchable, filterable list (by tags, favorites, recency)`

### Journey: Navigation (GAP FOUND)

**Gap 7: No navigation requirement.** How does the user move between Dashboard, Inbox, Projects, Today/Focus, Learning Resources? A sidebar? Top nav? This is the skeleton of the app.

> **Suggest adding:** `NAV-01: App has persistent navigation allowing access to Dashboard, Inbox, Today/Focus, Projects list, and Learning Resources from any page`

### Journey: Time Report Generation (MINOR GAP)

User wants to share billable hours with client → TIME-07 says "generate a structured monthly billable time report" → ... then what?

**Gap 8: Report delivery.** Can the user export it? Copy it? Download as PDF/CSV? Email it? "Generate" is vague on the output format.

> **Suggest clarifying TIME-07 to:** `User can generate and export a monthly billable time report (PDF or CSV) for a project, showing date, task, description, and hours`

---

## Lens 2: Missing Edge Cases

These aren't missing requirements — they're scenarios that implementation must handle. Listing them now prevents surprises during planning.

### Critical (will cause bugs or confusion if not addressed)

| # | Scenario | Affected Reqs | Question to Resolve |
|---|----------|---------------|---------------------|
| E1 | **Concurrent timers** — User starts timer on Task B while Task A timer is running | TIME-01 | Auto-stop Task A? Error? Allow multiple? Recommendation: auto-stop A, create its activity log entry, then start B. |
| E2 | **Deleting a task with children** — Task has sub-tasks, checklists, comments, activity log entries, and linked learning resources | TASK-07, SUBT-*, CHKL-*, CMNT-*, ALOG-*, LRSC-02 | Cascade delete everything? Soft delete? Confirmation dialog? Recommendation: confirmation + cascade soft-delete. |
| E3 | **Archiving a project with active timers** — Project has tasks with running timers when archived | PROJ-06, TIME-01 | Stop all timers? Block archive until timers stop? Recommendation: auto-stop timers, create log entries, then archive. |
| E4 | **Today list timezone** — TDAY-02 says "resets daily" but team members may be in different timezones | TDAY-02, TDAY-03 | Reset per user's local timezone? Per team timezone? Recommendation: per user's browser timezone. |
| E5 | **Personal project toggle with assigned tasks** — User toggles shared project to personal after tasks have been assigned to other team members | PROJ-04, TASK-04 | Block toggle? Unassign others' tasks? Recommendation: block toggle and show "remove other assignees first." |

### Important (affects UX quality)

| # | Scenario | Affected Reqs | Question to Resolve |
|---|----------|---------------|---------------------|
| E6 | **Browser tab close with running timer** — User closes tab while timer is running | TIME-01, ALOG-04 | Timer state is server-side (startedAt timestamp in Convex), so timer keeps "running." When user returns, show elapsed time. But what if they never return? Max timer duration? |
| E7 | **Month boundary for billable budgets** — Budget is 8h/month. It's Jan 31. User logs 2h. Next day is Feb 1. Does the 2h count toward Jan or Feb? | TIME-05, TIME-06 | Based on the date of the time entry, not when the timer started. What if a timer spans midnight? |
| E8 | **Sub-task completion vs parent status** — All sub-tasks are Done but parent is In Progress | SUBT-02, TASK-02 | Auto-move parent to Done? Visual indicator? Do nothing? Recommendation: visual indicator only, no auto-status-change. |
| E9 | **Inbox item moved to personal project** — Item triaged from inbox (private) to a shared project (visible to team) | INBX-03, PROJ-03 | No issue — this is expected. But moving to someone else's personal project shouldn't be possible. |
| E10 | **@mention without notifications** — v1 has @mentions (CMNT-04) but no notifications. The mention is just formatted text. | CMNT-04 | Is it worth implementing @mentions without notifications? It provides context in the comment ("@Sarah can you review this") even without a ping. Recommendation: keep — it's useful as documentation even without notifications. |

### Minor (nice to handle, not blocking)

| # | Scenario | Affected Reqs | Question to Resolve |
|---|----------|---------------|---------------------|
| E11 | **Archived project in search results** — Search returns tasks from archived projects | SRCH-01, PROJ-06 | Include archived results? With a visual indicator? Recommendation: include with "archived" badge. |
| E12 | **Checklist reorder across tasks** — Copy/move checklist between tasks/sub-tasks | CHKL-03 | Not required. Reorder within a single checklist is sufficient for v1. |
| E13 | **Empty states** — Dashboard with 0 tasks, 0 inbox items, 0 resources | DASH-01-04 | UX concern, not a requirement. But plan for helpful empty states during implementation. |

---

## Lens 3: Testability

Every requirement should be unambiguously testable. Most of the 55 pass. Flagging the ones that need sharpening.

### Ambiguous (needs clearer acceptance criteria)

| Req | Current Wording | Problem | Suggested Clarification |
|-----|-----------------|---------|------------------------|
| **LRSC-06** | "Resource visit count is tracked for implicit ranking and surfacing popular resources" | What counts as a "visit"? Clicking the external URL? Viewing the resource detail page? Opening a preview? | Clarify: "When a user clicks a learning resource's URL to open it, the visit count increments. Resources with higher visit counts appear higher in the resource list." |
| **DASH-03** | "Dashboard shows recent team activity across projects" | What counts as "activity"? Task creation? Status changes? Comments? Time entries? All? How many recent items? | Clarify: "Dashboard shows the 20 most recent team actions (task creation, status changes, comments, activity log entries) across all accessible projects." |
| **TIME-07** | "User can generate a structured monthly billable time report for a project" | "Structured" is vague. What fields? What format? | Clarify: "Report includes: date, task name, description, duration, and total billable hours. Exportable as CSV." |
| **SRCH-01** | "User can search full-text across tasks, projects, comments, and learning resources" | What fields are searched? Task title only? Title + description? Comment body? | Clarify: "Search indexes task titles and descriptions, project names, comment bodies, and learning resource URLs, summaries, and tags." |

### Tricky to test but testable

| Req | Challenge | Strategy |
|-----|-----------|----------|
| **TASK-03** (drag-and-drop) | Can't drag-drop in integration tests | Test the underlying mutation (changeStatus) in integration. Test drag-drop UX in Playwright E2E. |
| **TDAY-02** (daily reset) | Depends on time/date | Use Convex cron + mock time in tests. Test the reset mutation directly. |
| **TIME-01** (start/stop timer) | Timer is real-time | Timer is server-side (startedAt timestamp). Test: start timer → verify startedAt set → stop timer → verify duration calculated → verify activity log entry created. |
| **ALOG-04** (timer auto-creates entry) | Integration between two systems | Test stop-timer mutation and verify activity log entry exists with correct duration. |

### Well-specified (no issues)

The remaining 47 requirements are clearly testable. Examples:
- AUTH-01: Seed admin → call invite mutation → verify invite record → sign up with invite → verify user created ✓
- PROJ-04: Create project → toggle to personal → query as other user → verify project not returned ✓
- CHKL-04: Create 5 checklist items → check 3 → verify progress shows "3/5" ✓

---

## Lens 4: Pitfalls

### Gold-Plating Risk (features that could become rabbit holes)

| Req | Risk | Severity | Recommendation |
|-----|------|----------|----------------|
| **LRSC-06** (visit tracking) | Requires intercepting external link clicks, tracking opens, building a ranking algorithm. Is this worth it when LRSC-05 (manual starring) already exists? | Low | Keep but simplify: increment count on click, sort by count. Don't build a ranking algorithm. Stars are the primary signal; visit count is secondary. |
| **TIME-07** (monthly report) | "Structured report" can become a design project. Report layout, export formats, date range selection, filtering, grouping by task/day/week. | Medium | Constrain scope: CSV export with columns [date, project, task, description, hours, billable]. No PDF, no charts, no custom date ranges in v1. |
| **DASH-03** (recent activity) | Activity feed aggregation is deceptively complex. Multiple entity types, different actions, permissions filtering, pagination. | Medium | Cap at 20 items, no pagination in v1. Track creation events only (task created, comment added, resource shared), not edits or status changes. |
| **CMNT-04** (@mentions) | Without notifications, @mentions require: autocomplete UI for member names, parsing/rendering @ syntax, but deliver no functional value (no ping). | Low | Keep — the autocomplete UX is useful even without notifications. But don't build mention parsing/rendering as a separate system. Use a simple pattern: `@name` rendered as bold text. |

### YAGNI Check

| Req | Used in first month? | Verdict |
|-----|---------------------|---------|
| LRSC-06 (visit tracking) | Maybe. If the team saves 50+ resources, ranking matters. With 10 resources, you can scan the list. | Keep — low cost, useful at scale |
| TIME-06 (budget alerts) | Yes, if you have billable clients from day 1. | Keep — core to the billing workflow |
| PROJ-06 (archive project) | Unlikely in month 1. But needed eventually. | Keep — low cost |
| TASK-08 (reorder within column) | Yes. Ordering tasks by priority (via position) is daily usage. | Keep |

### Potential Missing Requirements

Based on the full analysis, these are requirements I'd expect but didn't find:

| Suggested Req | Category | Why |
|---------------|----------|-----|
| **AUTH-06**: First admin bootstrap | Auth | Without this, the app can't be used at all |
| **AUTH-07**: Admin can view/deactivate team members | Auth | Team management is needed when someone leaves |
| **AUTH-08**: Password reset via email | Auth | Users WILL forget passwords |
| **AUTH-09**: User can log out | Auth | Implied but missing |
| **NAV-01**: Persistent app navigation | Navigation | Skeleton of the entire app |
| **INBX-05**: Edit inbox item before triage | Inbox | Quick captures need refinement |
| **LRSC-07**: Browse/filter resources list | Resources | No way to find resources without search |
| **TIME-07 clarification**: Export format | Time | "Structured report" is ambiguous |

---

## Summary

| Lens | Findings |
|------|----------|
| **User Journey** | 8 gaps found — most critical are admin bootstrap (AUTH-06), logout (AUTH-09), and app navigation (NAV-01) |
| **Edge Cases** | 13 scenarios documented — most critical are concurrent timers (E1), cascade delete (E2), and timezone handling (E4) |
| **Testability** | 4 requirements need sharper wording (LRSC-06, DASH-03, TIME-07, SRCH-01). 47 of 55 are clearly testable as-is. |
| **Pitfalls** | 4 gold-plating risks — TIME-07 (report scope) and DASH-03 (activity feed complexity) are the highest. No YAGNI removals recommended. |

### Recommended Actions

1. **Add 5-8 missing requirements** (AUTH-06 through AUTH-09, NAV-01, INBX-05, LRSC-07)
2. **Clarify 4 ambiguous requirements** (LRSC-06, DASH-03, TIME-07, SRCH-01)
3. **Document edge case decisions** (E1-E5 at minimum) — these become acceptance criteria during phase planning
4. **No requirements removed** — all 55 passed the YAGNI check

---
*Reviewed: 2026-04-03*
