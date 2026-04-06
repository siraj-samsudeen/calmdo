# Phase 1: Foundation & Deploy - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2025-07-14
**Phase:** 01-foundation-deploy
**Areas discussed:** Invite & Auth Flow, App Shell & Sidebar, Project List & Detail, Task List Within Projects

---

## Invite & Auth Flow

### Admin Bootstrapping (AUTH-01)

| Option | Description | Selected |
|--------|-------------|----------|
| Seed script | Run a CLI command after deploy to create first admin | ✓ |
| Environment variable | Set ADMIN_EMAIL + ADMIN_PASSWORD in env vars, auto-create on first deploy | |
| First-signup-is-admin | First person to sign up becomes admin | |

**User's choice:** Seed script
**Notes:** User asked if first-signup-is-admin would save work. Claude explained both approaches are roughly equivalent effort (~15 min difference), but seed script keeps the auth flow simpler with no special cases. User agreed.

### Invite Link Mechanism

| Option | Description | Selected |
|--------|-------------|----------|
| Email with magic link | System sends invite email with unique signup link | |
| Manual link sharing | Admin generates link in UI, copies and shares manually | ✓ |

**User's choice:** Manual link sharing
**Notes:** User asked about email service requirement. Claude confirmed email option needs Resend/SendGrid configured as Convex action — extra infrastructure for Phase 1. Manual sharing avoids that entirely.

### Invite Token Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Single-use token | Unique per invite, works once, expires 7 days | ✓ |
| Multi-use link | One team link, works for multiple signups, can be revoked | |
| You decide | Claude picks | ✓ (delegated) |

**User's choice:** Delegated to Claude → Single-use token
**Notes:** Claude chose single-use as better fit for 2-5 person team where you invite individually.

### Login Page Style

| Option | Description | Selected |
|--------|-------------|----------|
| Centered card | Clean centered form, logo, email + password, minimal | ✓ |
| Split layout | Left branding/illustration, right form | |

**User's choice:** Centered card

---

## App Shell & Sidebar

### Sidebar Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Fixed sidebar | Always visible, never collapses, ~220px | ✓ |
| Collapsible sidebar | Can collapse to icon-only ~60px, toggle button | |

**User's choice:** Fixed sidebar

### Sidebar Layout

| Option | Description | Selected |
|--------|-------------|----------|
| Logo top, nav icons, user avatar + name + logout at bottom | Standard layout | |
| Logo top, nav icons, user dropdown menu at bottom | Dropdown variant | |
| You decide | Standard SaaS sidebar | ✓ (delegated) |

**User's choice:** Delegated to Claude → Logo top, nav middle, user avatar + dropdown bottom

### Placeholder Pages

| Option | Description | Selected |
|--------|-------------|----------|
| Simple empty state | Icon + "Coming soon" message | |
| Feature preview | Description of what page will do + "Coming in Phase X" | |
| You decide | Whatever feels complete while being honest | ✓ (delegated) |

**User's choice:** Delegated to Claude → Simple empty state with icon + short description

### Responsive Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Desktop-only | Fixed sidebar, min-width, don't worry about mobile | |
| Basic responsive | Sidebar becomes hamburger on mobile, content adapts | ✓ |

**User's choice:** Basic responsive

---

## Project List & Detail

### Project List Display

| Option | Description | Selected |
|--------|-------------|----------|
| Card grid | Cards in responsive grid with name, description, badge | |
| Simple list | Rows/table with name, description, type. Compact. | ✓ |

**User's choice:** Simple list

### Shared vs Personal Separation

| Option | Description | Selected |
|--------|-------------|----------|
| Two sections | "Shared" section on top, "Personal" below | |
| Single list with badges | All projects, each with shared/personal badge | |
| Tabs | "Shared" and "Personal" tabs | ✓ |

**User's choice:** Tabs

### Archive Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Soft archive | Disappears from list, accessible via Archived tab, restorable | ✓ |
| Archive with confirmation | Same + confirmation dialog | |

**User's choice:** Soft archive (no confirmation dialog)

### New Project Creation

| Option | Description | Selected |
|--------|-------------|----------|
| Button + inline form | Opens inline form on page | |
| Button + modal | Opens modal with name, description, shared/personal toggle | |
| You decide | Fastest for user | ✓ (delegated) |

**User's choice:** Delegated to Claude → Button + modal

---

## Task List Within Projects

### Task Row Display

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal rows | Just title per row, click to expand | |
| Info-rich rows | Title + description snippet + status badge | ✓ |

**User's choice:** Info-rich rows

### Task Detail View

| Option | Description | Selected |
|--------|-------------|----------|
| Side panel | Slide-out panel on right, list stays visible | ✓ |
| Full page | Navigate to dedicated task page | |
| Modal | Task detail in overlay | |

**User's choice:** Side panel

### Markdown Description

| Option | Description | Selected |
|--------|-------------|----------|
| Read-only render + edit button | Rendered markdown, click Edit for textarea | |
| Live markdown editor | Split/toggle edit + preview | |
| You decide | Simplest usable approach | ✓ (delegated) |

**User's choice:** Delegated to Claude → Read-only render + edit button → textarea

### New Task Creation

| Option | Description | Selected |
|--------|-------------|----------|
| Inline add | Persistent "+ Add task" input, type title, Enter | ✓ |
| Button + side panel | Click button, opens empty side panel | |

**User's choice:** Inline add

---

## Claude's Discretion

- D-03: Invite token — single-use, per-email, 7-day expiry
- D-06: Sidebar layout — logo top, nav middle, user dropdown bottom
- D-07: Placeholder pages — simple empty states with icon + description
- D-12: Project creation — modal dialog
- D-15: Markdown editing — read-only render + edit toggle to textarea

## Deferred Ideas

None — discussion stayed within phase scope.
