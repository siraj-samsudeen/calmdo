# Feature: Requirements Review Step (Four-Lens Analysis + Quality Filter)

## Problem

The current requirements definition flow (Step 7 in `new-project.md`, Step 9 in `new-milestone.md`) generates requirements and immediately asks "Does this capture what you're building?" — a single confirmation gate.

In practice, this gate catches **scope issues** ("I wanted X, not Y") but misses **quality issues**:

- **Defaults stated as requirements** — "User session persists across browser refresh" (every auth library does this). Adds noise, inflates requirement count, wastes planning effort downstream.
- **Implementation details disguised as requirements** — "All Convex functions use authenticated wrappers" describes HOW to build, not WHAT the user gets. These belong in CLAUDE.md or phase plans.
- **Duplicates** — "Admin invites by email" + "User can only sign up via invite" are two sides of the same feature. Two requirements → two plan tasks → two tests for the same thing.
- **Vague wording** — "User can view projects they have access to" — access to what exactly? Ambiguity here becomes ambiguity in plans, tests, and verification.
- **Missing user journeys** — No logout requirement. No password reset. No first-admin bootstrap. No app navigation. These surface only when you walk through the product end-to-end, not when you review a category list.

**Impact:** In a real project (55 initial requirements), this review step identified 8 gaps, 4 ambiguous requirements, 13 edge cases, and reduced the count to 51 sharper requirements. Without it, those issues propagate into planning, execution, and verification — each layer guessing at what the requirement actually means.

## Proposed Solution

### Change 1: Quality Filter (pre-generation)

Add requirement quality rules to `templates/requirements.md` so the agent applies them WHILE generating, not after. Five filter rules:

| Rule | What it catches | Example |
|------|----------------|---------|
| **Is this a real decision?** | Defaults no one would omit | "Session persists" — drop |
| **WHAT vs HOW?** | Implementation patterns | "Auth wrappers on all functions" — move to CLAUDE.md |
| **Is this a duplicate?** | Same feature, different angle | Merge "admin invites" + "invite-only signup" |
| **Is this vague?** | Ambiguous terms | "projects they have access to" → "shared projects + own personal projects" |
| **Is this obvious CRUD?** | Implied operations | "User can edit task" and "User can delete task" — implied by create |

### Change 2: Four-Lens Review Step (post-generation, pre-approval)

Insert a structured review between "here are the requirements" and "does this look good?" in both `new-project.md` and `new-milestone.md`. The review analyzes all requirements through four lenses:

**Lens 1 — User Journey Completeness:** Walk through every distinct user workflow end-to-end. For each step, verify a requirement exists. Specifically look for bootstrap gaps (how does the first user get in?), navigation gaps (how do they move between features?), and exit gaps (logout, undo, go back).

**Lens 2 — Edge Cases:** Document scenarios where requirements interact in non-obvious ways. Categorize as critical (will cause bugs), important (affects UX), minor (nice to handle). These aren't missing requirements — they're questions that phase plans must answer.

**Lens 3 — Testability:** Every requirement must have an unambiguous test. Flag requirements where acceptance criteria is unclear, triggers are undefined, or multiple interpretations exist.

**Lens 4 — Pitfalls:** Scan for gold-plating risk (features that could become rabbit holes), YAGNI (features unused in month one), and implicit requirements everyone expects but nobody stated.

**Output:** The review produces a `REQUIREMENTS-REVIEW.md` artifact in `.planning/` with findings organized by lens, suggested additions/changes/drops, and a summary table. The user reviews this BEFORE the confirmation gate.

### Proposed Flow

```
Current:
  Generate requirements → "Does this look good?" → Commit

Proposed:
  Apply quality filter during generation
    → Generate requirements
    → Run four-lens review → Write REQUIREMENTS-REVIEW.md
    → Present findings + suggested changes
    → "Does this look good?" (user sees both requirements + review)
    → Apply accepted changes → Commit
```

## Files to Change

### 1. `templates/requirements.md`

**What:** Add a `<quality_filter>` section to the template guidelines.

**Where:** Inside the existing `<guidelines>` block, after the "Requirement Format" section.

**Content:** The five filter rules (real decision, WHAT vs HOW, duplicates, vague, obvious CRUD) with examples of what to drop/merge/clarify.

**Benefit:** The agent applies the filter DURING generation, so the initial requirement list is already cleaner before the review step runs.

### 2. `workflows/new-project.md` — Step 7

**What:** Insert a "Requirements Review" sub-step between generating REQUIREMENTS.md and the confirmation gate.

**Where:** After "Generate REQUIREMENTS.md" and before "Present full requirements list for user confirmation."

**Content:**
- Run four-lens analysis on generated requirements
- Write findings to `.planning/REQUIREMENTS-REVIEW.md`
- Present summary (gaps found, ambiguous requirements, edge cases, pitfalls)
- Apply filter: drop defaults, merge duplicates, clarify vague ones, add missing requirements
- THEN ask for user confirmation

**Benefit:** The confirmation gate now has substance — the user sees both the requirements AND the review findings, making their approval meaningful.

### 3. `workflows/new-milestone.md` — Step 9

**What:** Same update as `new-project.md` — mirror the review step for subsequent milestones.

**Where:** After requirements generation, before confirmation gate.

**Benefit:** Consistency. Every time requirements are defined (new project or new milestone), the same review quality bar applies.

## Benefits to the Community

1. **Fewer downstream issues.** Vague or duplicate requirements create vague or duplicate plan tasks, tests, and verification steps. Catching them at definition time saves work in every subsequent phase.

2. **Smaller, sharper requirement sets.** The filter typically removes 10-15% of requirements (defaults, duplicates, implementation details). Fewer requirements = less planning overhead = faster execution.

3. **Edge case documentation.** The review creates a reusable edge case list that phase plans can reference. Without it, every phase planner independently discovers the same edge cases (or doesn't).

4. **User journey validation.** The most valuable lens. Walking through the product end-to-end catches requirements that category-based thinking misses (navigation, bootstrap, logout, password reset).

5. **Teachable framework.** Users learn to think about requirements quality through the four lenses. The review artifact becomes a conversation starter, not just a checklist.

## Example: Before and After

**Before (55 requirements):**
```
- [ ] AUTH-01: Admin can invite users by email to create an account
- [ ] AUTH-02: User can sign up only via an invite (no self-registration)
- [ ] AUTH-04: User session persists across browser refresh
- [ ] AUTH-05: All Convex queries and mutations are secured via auth wrappers
- [ ] TASK-06: User can edit task title and description
- [ ] TASK-07: User can delete a task
```

**After review + filter (51 requirements):**
```
- [ ] AUTH-01: First admin account is created during deployment setup
- [ ] AUTH-02: Admin can invite users by email; users can only sign up via invite link
- [ ] AUTH-03: User can log in with email and password
- [ ] AUTH-04: User can reset their password via email link  ← NEW (journey gap)
- [ ] AUTH-05: User can log out from any page                ← NEW (journey gap)
- [ ] AUTH-06: Admin can view all team members and deactivate accounts  ← NEW (journey gap)
```

**Dropped:** session persistence (default), auth wrappers (implementation detail), edit task (implied CRUD), delete task (implied CRUD)
**Merged:** invite + signup → one requirement
**Added:** password reset, logout, admin bootstrap, team management (user journey gaps)
**Net:** -4 dropped, -6 merged, +5 added = 51 sharper requirements

---

*Discovered during CalmDo project initialization. The review step caught issues that the standard confirmation gate missed.*
