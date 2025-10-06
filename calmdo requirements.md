# Calmdo Product Requirements

## Vision
Build a lightweight yet powerful productivity system inspired by Linear, Monday.com, Nirvana HQ, OmniFocus, and core GTD practices. Linear contributes the blazing-fast issue tracking and keyboard-first workflows, Monday.com showcases approachable boards for business stakeholders, Nirvana HQ excels at context tagging (people, location, energy), and OmniFocus is praised for structured GTD hierarchies and review rituals. Calmdo should blend these strengths so teams capture work quickly, resume context fast, and progressively enable advanced workflows (projects, time logs, tags, checklists, recurring tasks) without clutter. We should be able to work with or without GTD - something as simple as todoist.com or as complex as OmniFocus, but more usable and polished. 

## Core Principles
- **Speed first**: quick capture and inline editing anywhere; minimal friction for recurring entries or issue logging.
- **Progressive complexity**: features like projects, time/activity logging, tags, checklists, subtasks, and recurring tasks must be optional and unobtrusive.
- **Personal focus**: default views filter to "My work" with ability to expand to all items or teammates when needed.
- **Contextual guidance**: screens should suggest likely next steps and surface relevant links/actions inline to reduce context switching. Provide subtle prompts based on product usage history to highlight underused features (e.g., “Log effort?”, “Add a recurring check-in?”).
- **Theme parity**: light and dark modes must share high-contrast, accessible styling.
- Ideally, everything should be configurable - statuses, tags, etc.
- Checklists should be resuable - I should be able to capture a set of sub-tasks under a task after they are done to make them reusable as a checklist or even a subtask template. The idea is improvise on the fly. 
- Logs should roll up across users. even people who are not primary assigned to a task should be able to log time on a task.
- we need a nice and simple way to handle tasks like learning tasks which are assigned to 2 or 3 members of my team - but let us not complicate for the most-used scenario - only one assignee for 95% of the tasks. 
- recurring tasks should have some intelligent design - if they are left without being ticket, the tick is done after a gap, it should transition to the correct next timeline intelligently. 
- Like Arc browser did, it should recycle tasks which are left stale and untouched for sometime into some special buckets as we all ignore the task managers when life gets too busy and then come back to find a mountain of old tasks to cleanup among which are a few important ones which is like finding needle in a haystack. 
- there should be a way to have REAL due dates for items like government filings, and AMC contracts due and separate them from due dates that we put just as a way to prioritise and can keep moving indefinitely. 

## Functional Requirements
### Tasks
- Lightweight quick-add form (Linear-style) that supports inline editing and bulk capture, inserting new tasks at the top of the current list/board.
- Tasks belong to an owner, optional assignee, optional project, and support GTD-style tagging inspired by Nirvana (location, people, energy, focus, next action).
- Subtasks and reusable checklists (OmniFocus-style) to break down work; recurring tasks for routines with snooze/skip controls. All are opt-in per workspace.
- Ability to log time/activity with optional duration and comments; logs should appear on task, project, and home views.
- Task views should surface status lanes (Queued, In Motion, Completed) with counts and filters by assignee, project, status, tags, and GTD contexts. Status can be configured per organisation or even per project. 
- Default filter shows "My Tasks" but allow switching to all tasks or another user.

### Projects
- Each project can belong to either an individual user or an organization; projects may be shared across organizations (e.g., client engagements).
- Support membership/permissions so both internal teams and client partners can collaborate on shared projects with scoped visibility.
- Display linked tasks within project views alongside the activity log (including time entries).
- Projects accessible via sidebar navigation with counts and quick filters.

### Tags (GTD Context & People)
- Users can create flexible tags representing GTD contexts (location, tool, energy), people/teams (@Client, @Designer), focus modes, and priority queues.
- Support both freeform names and curated tag bundles (e.g., Nirvana-style Areas, OmniFocus perspectives).
- Provide quick palette search/apply UX during capture/editing and bulk tagging when multiple tasks selected.
- Allow tag grouping or prefixes to differentiate contexts vs. people vs. workstreams; let workspaces toggle which tag categories they use.
- Filters must support combining tags and saving favorite tag sets for rapid retrieval (e.g., "@Office + @Finance").
- Tags remain optional and unobtrusive—hidden if unused, surfaced via suggestions when repeated patterns detected.

### Activity Logs
- Task and project-level logs capturing `occurred_at`, optional duration, optional comments.
- Logs aggregate into daily/weekly/monthly summaries and feed a home dashboard activity stream.
- Recurring tasks should auto-suggest logging slots when due.

### Home Dashboard & Guidance
- Home page should display actionable data: latest projects, recently edited tasks, activity feed, quick cues for next actions, active contexts (e.g., “Warehouse errands”, “Follow-ups”).
- Provide guidance links (e.g., "Log time", "Add next step", "Schedule review") contextual to current work history and GTD habits.
- Introduce a “Coach” panel that surfaces subtle tips or shortcuts based on feature usage (e.g., highlight checklists after repeated subtasks, suggest recurring tasks when similar items recur weekly).
- Offer optional dedicated guidance page summarizing product tips, recommended automations, and underused features detected from usage analytics.

### Sidebar & Navigation
- Sidebar sections for Projects, Task Status, and GTD contexts/tags, showing counts and filters (My Tasks, Team, per-user, per-context).
- Navigation icon/avatar should be compact and align with layout.

### Seeds & Sample Data
- Populate sample data with realistic sample users, projects, tasks, tags, checklists, and logs to showcase dashboards and reports (weekly/monthly/daily views).

## Non-Functional Requirements
- Maintain tenant/user scoping across contexts so users only see/edit their own data unless explicitly shared.
- Ensure accessibility (contrast, keyboard navigation) in both themes.
- Feature toggles should allow disabling projects, logging, or advanced tags for simpler deployments.