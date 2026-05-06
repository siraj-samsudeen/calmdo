import { describe } from "vitest";
import { test } from "../convex/test.setup";
import { renderWithSession } from "feather-testing-convex/rtl";
import App from "./App";

describe("App", () => {
  test("authenticated user sees welcome with their email", async ({ testClient }) => {
    const userId = await testClient.run(async (ctx) =>
      ctx.db.insert("users", { email: "test@example.com" }),
    );
    const client = testClient.withIdentity({ subject: userId });
    const session = renderWithSession(<App />, client);
    await session.assertText(/Welcome, test@example.com!/);
  });

  test("unauthenticated user sees sign-in form", async ({ testClient }) => {
    const session = renderWithSession(<App />, testClient, { authenticated: false });
    await session.assertText(/sign in/i);
  });
});
