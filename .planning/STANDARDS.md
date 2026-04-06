# Project Standards: CalmDo

Standards that apply to all work in this project. Read by all team members and Claude sessions.

## Requirements Quality Filter

Before presenting requirements for review, every requirement must pass this filter:

### 1. Is this a real product decision?

A requirement is worth stating only if someone might reasonably build the system WITHOUT it. If every modern implementation does it by default, drop it.

**Drop:** "User session persists across browser refresh" (auth library default)
**Keep:** "Projects are shared by default" (could equally be private by default — this is a decision)

### 2. Is this WHAT or HOW?

Requirements describe user-facing behavior (WHAT). Implementation patterns, coding standards, and architectural decisions belong in CLAUDE.md or phase plans (HOW).

**Drop:** "All Convex functions use authenticated wrappers" (implementation pattern)
**Keep:** "Admin can invite users by email" (user-facing behavior)

### 3. Is this a duplicate?

Two requirements describing the same feature from different angles should be merged into one.

**Merge:** "Admin invites by email" + "User can only sign up via invite" → "Signup is invite-only — admin sends email invite, user signs up through invite link"

### 4. Is this vague?

Challenge fuzzy terms. "User can view projects they have access to" — access to WHAT? Push for specifics.

**Vague:** "User can view projects they have access to"
**Clear:** "User can view all shared projects and their own personal projects"

### 5. Is this obvious CRUD?

If a requirement exists for creating something, edit and delete are implied. Don't state them separately unless the behavior is non-obvious.

**Drop:** "User can edit task title" and "User can delete a task" (implied by task creation)
**Keep:** "User can archive a project" (archive ≠ delete — this is a design decision)

## Requirements Review: Four-Lens Analysis

After generating requirements and before asking for approval, run every requirement through four lenses:

### Lens 1: User Journey Completeness

Walk through every distinct user workflow end-to-end. For each step, verify a requirement exists. Look for:
- **Bootstrap gaps** — how does the first user get in?
- **Navigation gaps** — how does the user move between features?
- **Exit gaps** — can the user log out, undo, go back?

### Lens 2: Edge Cases

Document scenarios where requirements interact in non-obvious ways. Categorize by severity:
- **Critical** — will cause bugs (concurrent timers, cascade deletes, timezone handling)
- **Important** — affects UX quality (empty states, status inconsistencies)
- **Minor** — nice to handle, not blocking

These aren't missing requirements — they're implementation questions that phase plans must answer.

### Lens 3: Testability

Every requirement must have an unambiguous test. Flag requirements where:
- The acceptance criteria is unclear ("structured report" — structured how?)
- The trigger is undefined ("visit count is tracked" — what counts as a visit?)
- Multiple interpretations exist

### Lens 4: Pitfalls

Scan for:
- **Gold-plating risk** — features that could become rabbit holes (report generation, activity feeds)
- **YAGNI** — features that won't be used in the first month
- **Implicit requirements** — things everyone expects but nobody stated (responsive design, loading states, error handling)

---
*Established: 2026-04-03*
*Updated: 2026-04-06*
