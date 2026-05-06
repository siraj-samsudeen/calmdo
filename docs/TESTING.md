# Testing Philosophy

Integration is the default. Mocks are the exception.

## Three levels

**Integration (feather-testing-convex + Vitest)** — written first, the workhorse.
Tests React components against a real in-memory Convex backend. Every `useQuery`
and `useMutation` hits actual Convex functions running against the real schema.
No mocks for data — use `seed()` instead. Runs at unit-test speed. Produces code
coverage.

**Unit (convex-test + Vitest)** — written to cover edge cases and fill coverage gaps.
Tests Convex backend functions in isolation with no React involved. Reach for these
when: logic is complex enough to need exhaustive case coverage, or a scenario is
genuinely hard to produce through a rendered component (deep error paths, race
conditions, third-party failures).

**E2E (Playwright)** — written last, the confidence layer.
Tests critical user journeys in a real browser against a running dev server.
Prioritizes cross-system confidence, not exhaustive edge-case coverage.
No coverage concern.

## One DSL across all levels

Integration and E2E tests share the same Session DSL — `.fillIn()`, `.clickButton()`,
`.assertText()`, `.click()`, `.refuteText()`, `.submit()`, `.within()` — regardless
of whether the adapter is React Testing Library or Playwright. Inspired by
[Phoenix Test](https://hexdocs.pm/phoenix_test/PhoenixTest.html).

Integration: `renderWithSession(<App />, client)` → session
E2E: `{ session }` fixture from `feather-testing-convex/playwright`

Methods exclusive to Playwright (real browser): `.visit()`, `.assertPath()`,
`.assertHas()`, `.refuteHas()`. Do not use these in integration tests.

## Convex `useQuery` state semantics

`useQuery` returns three distinct values — check them with strict equality:

```ts
const data = useQuery(api.x.y);
if (data === undefined) return <Loading />;  // query in-flight
if (data === null) return <Empty />;          // query returned null
return <View data={data} />;                  // T narrowed
```

`!data` and `data == null` (loose equals) are bugs: they conflate loading with
empty and swallow the loading state silently. Always use `=== undefined`.

## MECE states

For each component, enumerate its visual states (loading, empty, populated, error).
Write exactly one test per state. Assert multiple aspects within each test — do not
spread one state across multiple tests.

Mocks are primarily reserved for transient, timing-sensitive, or otherwise
impractical-to-produce states.

When a test needs domain data, seed it before rendering using the `seed()` fixture —
`userId` is auto-filled from the test user:

```tsx
// Single user
test("shows task list", async ({ client, seed }) => {
  await seed("tasks", { title: "Buy milk", completed: false });
  const session = renderWithSession(<App />, client);
  await session.assertText("Buy milk");
});

// Multi-user: createUser() returns a second authenticated client with .userId
test("users only see their own tasks", async ({ client, seed, createUser }) => {
  await seed("tasks", { title: "Alice's task", completed: false });
  const bob = await createUser();
  await seed("tasks", { title: "Bob's task", completed: false, userId: bob.userId });

  const aliceTasks = await client.query(api.tasks.list, {});
  expect(aliceTasks).toHaveLength(1);

  const bobTasks = await bob.query(api.tasks.list, {});
  expect(bobTasks[0].title).toBe("Bob's task");
});
```

## Coverage policy

Production code is expected to maintain 100% coverage. Treat it as a forcing
function for discipline, not a theological truth about software quality.

If a branch is intentionally left uncovered, mark it inline and document the reason
in the commit's plan file (`plans/NNNN-slug.md`):

```ts
/* v8 ignore next -- [reason] */
```

Legitimate exceptions:
- Impossible runtime states (exhaustive type guards, `default: throw`)
- Framework or runtime behaviour that cannot be deterministically reproduced
- Defensive environment checks (`process.env.NODE_ENV !== "production"`)
- Transient timing states covered by mock tests instead
- Browser/platform-specific behaviour

Do not write artificial tests solely to satisfy the metric.
