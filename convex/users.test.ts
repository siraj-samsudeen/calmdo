import { convexTest } from "convex-test";
import { api } from "./_generated/api";
import { test, expect } from "vitest";
import schema from "./schema";

test("viewer returns null when unauthenticated", async () => {
  const t = convexTest(schema);
  expect(await t.query(api.users.viewer, {})).toBeNull();
});

test("viewer returns null when user has no email", async () => {
  const t = convexTest(schema);
  const userId = await t.run(async (ctx) => ctx.db.insert("users", {}));
  expect(await t.withIdentity({ subject: userId }).query(api.users.viewer, {})).toBeNull();
});
