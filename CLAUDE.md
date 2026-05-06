<!-- convex-ai-start -->

This project uses [Convex](https://convex.dev) as its backend.

When working on Convex code, **always read
`convex/_generated/ai/guidelines.md` first** for important guidelines on
how to correctly use Convex APIs and patterns. The file contains rules that
override what you may have learned about Convex from training data.

Convex agent skills for common tasks can be installed by running
`npx convex ai-files install`.

<!-- convex-ai-end -->

## Commit Workflow

Each commit adds one numbered plan file to `plans/` describing what was implemented.
Reference it from the commit message: "See plans/0003-feature-name.md".
The directory is append-only — nothing is ever overwritten. Plans are browsable in
any editor, linkable from PRs and commit messages, and form a permanent readable log
of architectural decisions.

### Recording deviations from a plan

When implementation diverges from a plan, append a `## Deviations` section to the
**bottom of the original plan file** (e.g. `plans/0001-*.md`). Each entry: what was
planned, what actually happened, the fix, and a rule for future work. Date each entry.

Do not create separate deviation files — deviations only make sense next to the plan
they deviate from, and separate files rot.

**When to write a new plan instead of a deviation:**
- The work is genuinely new scope, not a correction of existing scope → new `plans/NNNN-*.md`
- A deviation is large enough to be its own architectural record → promote to new plan and link back

**When to update the plan text directly instead of writing a deviation:**
- The plan contained incorrect code or commands that would fail if followed literally
- A better approach was discovered that supersedes the original (e.g. `test.step()` for E2E flows)
- Fix the plan text so a future agent following it would succeed; add a deviation only if the
  original intent differed from the outcome in a way worth recording

## Routing

TanStack Router (SPA mode). Add new views as route files under `src/routes/` —
not as components in `App.tsx`. Auth-gated views go under `_app.*`, public views
under `_auth.*`. When a second content page is needed, add a route file; do not
touch `App.tsx`.

## Testing

See `docs/TESTING.md` for the full testing philosophy.
Three levels: integration first (feather-testing-convex + Vitest), unit tests for
edge cases and coverage gaps (convex-test + Vitest), E2E for critical user journeys
(Playwright with feather-testing-convex/playwright session fixture).
Same Session DSL across integration and E2E levels.
