# Plan: Fix Test Provider Conflict and Achieve 100% Coverage

## Problem

After implementing plan 0001, two categories of test failures remained:

### 1. Provider conflict: `__root.tsx` owned `ConvexAuthProvider`

`renderWithSession(<App />, client)` from feather wraps the component with its own
`ConvexTestAuthProvider` (outer). But `__root.tsx` also created a `ConvexReactClient`
and wrapped with `ConvexAuthProvider` (inner). React context inner-wins: feather's auth
state was silently overridden by the inner provider, which used an undefined
`VITE_CONVEX_URL` and stayed in `isLoading: true` forever.

**Fix**: Move `ConvexReactClient` + `ConvexAuthProvider` from `__root.tsx` to `main.tsx`.
`main.tsx` is excluded from tests (by coverage config + by not being imported by tests).
`__root.tsx` is now layout-only (`<Outlet />` + DevTools). Feather's outer provider
is now the only one in the test tree.

### 2. `import.meta.glob` not available in browser project

`convex-test`'s internal `import.meta.glob` was not being Vite-transformed in the
browser project, because `convex-test` was not in `server.deps.inline`. Without the
transform, the glob function itself was undefined at runtime.

**Fix**: Add `"convex-test"` to `server.deps.inline` in the browser vitest project.

### 3. Glob pattern excluded `_generated/`

`import.meta.glob("./**/!(*.*.*)*.*s")` in `convex/test.setup.ts` used extglob negation.
In Vite 8 (rolldown), this pattern silently excluded `_generated/` files, so
`convex-test` could not find the generated schema. Changed to:

```ts
import.meta.glob(["./**/*.{ts,js}", "!./**/*.test.*"])
```

Array-style glob with a separate exclude pattern works correctly in rolldown.

### 4. RTL `asyncUtilTimeout` too short for App-level tests

Router initialization (TanStack Router: pending → idle) + auth state effect
(`ConvexAuthStateFirstEffect` useEffect) + Convex query resolution total ~1.2s in
jsdom. RTL's default `asyncUtilTimeout` is 1000ms. `session.assertText()` timed out.

**Fix**: In `src/test.setup.ts`, configure RTL globally:
```ts
configure({ asyncUtilTimeout: 5000 });
```

### 5. `seed()` injects `userId` into `users` table

Feather's `seed(table, data)` auto-fills `userId` from the authenticated user. This
conflicts with the `users` table schema from `authTables`, which does not accept a
`userId` field. Validator rejects it.

**Fix**: Use `testClient.run()` to insert the user directly with only `{ email: "..." }`.
Then call `testClient.withIdentity({ subject: userId })` manually.

### 6. `renderWithSession` defaults to `authenticated: true`

Passing `testClient` (no identity) to `renderWithSession` without `{ authenticated: false }`
causes `ConvexProviderWithAuth` to set `isAuthenticated: true`. For the unauthenticated
smoke test, explicit `{ authenticated: false }` is required — this triggers the
synchronous path in `ConvexProviderWithAuth` (no `useEffect` needed).

## Changes

### `src/main.tsx`
Owns `ConvexReactClient` + `ConvexAuthProvider` (moved from `__root.tsx`).

### `src/routes/__root.tsx`
Layout only: `<Outlet />` + DevTools (conditional on `import.meta.env.DEV`).

### `vitest.config.ts`
- Added `"convex-test"` to browser project `server.deps.inline`.
- Added `globals: true` to browser project (not inherited from root).
- Removed `src/routes/__root.tsx` from coverage exclude (now testable).
- Added `convex/auth.ts`, `convex/http.ts` to coverage exclude (framework files).

### `convex/test.setup.ts`
Changed glob from extglob negation to array + exclude pattern.

### `src/App.test.tsx`
- Uses feather `test` fixture (not raw `convexTest`).
- Inserts user with email via `testClient.run()` (not `seed()`).
- Passes `{ authenticated: false }` for unauthenticated test.

### `src/test.setup.ts`
Added `configure({ asyncUtilTimeout: 5000 })` from `@testing-library/react`.

## Result

All 9 tests pass. 100% coverage (statements, branches, functions, lines).
