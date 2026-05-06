# Plan: Prevent build failures from reaching Vercel

## Context

PR #2 hit two Vercel deploy failures that local development missed:

1. **`tsc -b` errors in `src/App.test.tsx`** — `assertText(/regex/)` (DSL types
   it as `string`) and an implicit-any `ctx` parameter. Vitest skipped both
   because it strips types via esbuild without typechecking.

2. **`tsc` over `convex/` failed on `import.meta.glob`** — `convex deploy`
   runs its own typecheck pass with the convex tsconfig, which doesn't include
   Vite types. The frontend build had passed; this was a separate pass.

Both are detectable in <5 seconds locally with `tsc`. Neither is detectable
with `vitest --run`. The gap was: nothing ran `tsc` before push.

---

## What this plan adds

### 1. `verify` script in `package.json`

Mirrors Vercel's deploy gauntlet in one command:

```json
"verify": "npm run build && tsc -p convex --noEmit && vitest --run"
```

- `npm run build` → `tsc -b && vite build` (catches src/ errors + bundles)
- `tsc -p convex --noEmit` (catches the second-pass errors `convex deploy` would hit)
- `vitest --run` (catches test regressions)

### 2. `.githooks/pre-push`

Tracked, executable script that runs `npm run verify` on every `git push`.
Refuses the push on failure. Bypass via `git push --no-verify` for genuine WIP.

### 3. `prepare` script wires `core.hooksPath`

```json
"prepare": "git config core.hooksPath .githooks"
```

`npm install` runs `prepare` automatically, so collaborators (and future
Claude Code agents) inherit the hook with no manual setup. No husky
dependency needed — `core.hooksPath` is a built-in Git feature.

### 4. `CLAUDE.md` documents the rule

A "Pre-push verification" section explains the two-pass typecheck and points
to `npm run verify`. Future agents read CLAUDE.md before working.

---

## Hook + CI together

The hook fails *before* push, with logs in the user's own terminal — fast
feedback, no Vercel auth needed.

The GitHub Actions workflow at `.github/workflows/ci.yml` runs the same
`npm run verify` on every PR and push to `main`. It catches the cases the
hook can't: pushes that used `--no-verify`, machines where `prepare` didn't
run, or contributors who haven't run `npm install` since the change landed.

Belt and suspenders. The hook is the fast loop; CI is the backstop.

---

## How to bypass (and when not to)

`git push --no-verify` skips the hook. Acceptable when:
- Pushing a doc-only branch with no code changes
- Pushing intentionally broken WIP to share context with a teammate

Not acceptable to silence a real type or test error. Fix it.
