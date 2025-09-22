# Calmdo — Requirements

A lightweight, real-time task manager for teams and clients, focused on **logging time**, **writing updates (notes)**, and **keeping work calm**.

---

## 1) Product Scope

- **Audience:** internal team + invited clients
- **Brand/Domain:** Calmdo (primary domain currently: `calmdo.app`)
- **Auth:** Phoenix built-in (`phx.gen.auth`) with **manual invites** (no self-signup)
- **Real-time:** Phoenix LiveView (broadcast updates)
- **Notifications:** **None** in v1 (no Slack/email)
- **Reports:** **In-app views only** (no export in v1)

---

## 2) Roles & Access

- **Roles (single role per user):** `admin`, `team`, `client`
- **Admins:** full access; manage statuses and invites
- **Team:** create/edit tasks they own or are allowed to see
- **Clients:** view tasks on their projects; (creation/edit only if enabled later)

---

## 3) Core Concepts (Data Model)

> Notes on schema fields: omit Ecto defaults (`id`, `inserted_at`, `updated_at`).

### 3.1 Users
- **Fields:** `name`, `email (unique)`, `hashed_password`, `role (admin|team|client)`
- **Invitations:** manual by admins

### 3.2 Clients (optional)
- **Purpose:** optionally attach projects to a client
- **Fields:** `name`, `contact` (single short contact field)

### 3.3 Projects
- **Association:** **optional** `client_id`
- **Fields:** `name`, `description`
- **Status:** `status_id` (lookup table)
- **Notes:** multiple markdown notes allowed (see Notes entity)
- **Due dates:** **not stored** at project level (by decision)
- **Tags:** **no tags** on projects

### 3.4 Statuses (Lookup; Global)
- **Used by:** projects, tasks, subtasks
- **Fields:** `name` (e.g., “Todo”, “In Progress”, “Done”)
- **Admin-managed:** admins can add globally

### 3.5 Tasks
- **Associations:** `project_id`, `status_id`, `assignee_id (User)`, `created_by_id (User)`
- **Fields:** `title`, `priority (enum: low|medium|high)`, `due_date`
- **Validation (Iteration 1):** Only `title` is mandatory; other task fields may be left empty or null.
- **Notes:** multiple markdown notes (authored, editable)
- **Tags:** **global tags on tasks only**
- **Checklists:** checklist items belong to tasks (not subtasks)
- **Subtasks:** tasks may have child subtasks (see 3.6)

### 3.6 Subtasks
- **Association:** `parent_task_id` (belongs to exactly one parent task)
- **Schema:** **mirrors tasks** for predictability:
  - fields: `title`, `status_id`, `assignee_id`, `created_by_id`, `priority`, `due_date`
- **Notes:** allowed (same as tasks)
- **Tags / Checklists:** **no tags**, **no checklist** on subtasks

### 3.7 Checklist Items (Task-only)
- **Association:** `task_id`
- **Fields:** `text`, `completed (bool)`, `completed_by_id (User)`, `completed_at (datetime)`

### 3.8 Notes (Markdown)
- **Polymorphic association:** belongs to **task** or **project**
- **Fields:** `body (markdown)`, `created_by_id (User)`, `updated_by_id (User)`
- **Editing:** **editable**; track updater and time

### 3.9 Time Logs
- **Association:** **either** `task_id` **or** `project_id` (exactly one must be set)
- **Fields:** `duration` (e.g., minutes), `date`, `note`, `created_by_id`, `updated_by_id`
- **Editing:** **editable**
- **Parent vs Subtasks:** **lenient model**
  - Parent tasks **may** have their own time logs even if subtasks exist
  - Reporting should **not double-count**; show parent and children totals distinctly

### 3.10 Tags (Global)
- **Scope:** usable across all projects
- **Applied to:** **tasks** only
- **Join table:** `task_id` ↔ `tag_id`

---

## 4) Behavioral Rules & Constraints

- **Single assignee per task/subtask.** Multi-person work handled via **subtasks**.
- **Parent task status roll-up (advisory rule):**
  - `Done` when **all** subtasks are `Done`
  - `In Progress` if **any** subtask started but not all done
  - `Todo` if no subtask has started
- **Time logs XOR link:** enforce via validation that **exactly one of** `task_id` or `project_id` is present
- **Checklist integrity:** if `completed = true`, require `completed_by_id` and `completed_at`
- **Deletes:** **hard delete only** (no soft delete/archive)
- **Views:**
  - Project-wise task view (manage tasks within a project)
  - Global task view (all tasks; basic filtering later if needed)

---

## 5) Out-of-Scope (Iteration-1)

- No Slack/email notifications
- No CSV/PDF export of reports
- No task dependencies (A before B)
- No full-text search or complex filtering (can come later)

---

## 6) Iteration Plan (ship minimal, then expand)

### Iteration 1 (MVP to deploy)
- Project scaffolding with **Igniter → Phoenix LiveView**
- Auth with **phx.gen.auth** (manual invites)
- **Statuses** (lookup) with seed values: Todo / In Progress / Done
- **Tasks** (CRUD) with:
  - `title`, `priority (low|medium|high)`, `due_date`
  - `status_id`, `assignee_id`, `created_by_id`
- **LiveView** pages for managing tasks
- **Deploy** (Fly/Gigalixir/your infra) and smoke test

### Iteration 2 (Core model completion)
- **Projects** (optional `client_id`), status, and project-level notes
- **Subtasks** (mirror tasks; parent_task relationship)
- **Notes** (markdown) for tasks
- **Checklist items** on tasks (with `completed_by`/`completed_at`)
- **Time logs** (task- or project-level; lenient parent handling)
- **Tags** (global) + task↔tag join

### Iteration 3 (Polish & reporting)
- In-app reports (totals per **project** and per **user**; parent vs subtask breakdowns)
- Optional simple filters (by project/status/assignee)
- UX refinements for real-time updates

---

## 7) Generator-First Setup (Iteration-1 Checklist)

> Use Phoenix/Igniter generators wherever available; avoid hand-coding until necessary.

- [ ] **Create app**  
  ```bash
  mix igniter.new calmdo --phx.new --live
  cd calmdo
  mix ecto.create
