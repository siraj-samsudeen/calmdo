# Plan: Merge E2E Auth Tests into a Single Flow with `test.step()`

## Motivation

The two E2E tests in `e2e/auth.spec.ts` were originally separate:
- "sign up shows welcome with email"
- "sign out returns to sign-in form"

Each ran its own `clearAll` + full sign-up sequence. The sign-out test duplicated
the sign-up steps only to reach a post-login state, which was redundant.

## Change

Combined into one `test("auth flow")` using `test.step()`.

**Before**: two tests, each starting from scratch. Sign-out test re-signs-up just
to get authenticated, then signs out.

**After**: one test, two steps. Step 2 continues from step 1's authenticated
session — no re-signup needed. The flow is: visit → sign up → assert welcome →
sign out → assert sign-in form.

## Tradeoff

With `test.step()`, a step 1 failure skips step 2. This is acceptable here
because sign-up and sign-out are a single sequential journey, not independent
scenarios. For independent scenarios (wrong password, rate limiting, etc.) separate
tests remain the right structure.

## No coverage impact

E2E tests are not included in Vitest coverage. This is a test structure change only.
