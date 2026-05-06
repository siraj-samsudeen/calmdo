import { test } from "./fixtures";

const EMAIL = "test@example.com";
const PASSWORD = "Password1!";

// clearAll runs before the test, so it starts with a clean slate.
// Sign up (not sign in) because no account exists at the start.
// Steps share state: step 2 (sign out) continues from step 1's authenticated session.
test("auth flow", async ({ session }) => {
  await test.step("sign up shows welcome with email", async () => {
    await session
      .visit("/")
      .fillIn("Email", EMAIL)
      .fillIn("Password", PASSWORD)
      .clickButton("Sign up")
      .assertText(`Welcome, ${EMAIL}!`);
  });

  await test.step("sign out returns to sign-in form", async () => {
    await session.clickButton("Sign out").assertText(/sign in/i);
  });
});
