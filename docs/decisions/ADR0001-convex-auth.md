# ADR-0001: Convex Auth with Password Provider

**Date:** 2026-05-01
**Status:** Accepted

## Context

The app needs authentication. Convex offers a first-party auth library
(`@convex-dev/auth`) that integrates directly with the Convex backend,
eliminating a separate auth service and external token exchange.

## Decision

Use `@convex-dev/auth` with the Password provider (email + password).

## Alternatives considered

- **Clerk** — third-party; adds external dependency and billing; overkill for a
  small team tool.
- **Magic link** — simpler UX but requires email delivery infrastructure not
  present in the starter.

## Consequences

- Auth session and identity are managed entirely within Convex; no external
  token exchange.
- The `authTables` schema must be spread into every app's `schema.ts`.
- All mutations access the current user via `ctx.auth.getUserIdentity()`.
- The `users` table from `authTables` is the source of truth for the assignee
  picker in any task-related screen.
