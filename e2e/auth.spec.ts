import { test } from "./fixtures";

const EMAIL = "test@example.com";
const PASSWORD = "Password1!";

// clearAll runs before each test so every test starts with a clean slate.
// Both tests sign up (not sign in) because no account exists at the start of each test.
test.describe("auth flow", () => {
  test("sign up shows welcome with email", async ({ session }) => {
    await session
      .visit("/")
      .fillIn("Email", EMAIL)
      .fillIn("Password", PASSWORD)
      .clickButton("Sign up")
      .assertText(`Welcome, ${EMAIL}!`);
  });

  test("sign out returns to sign-in form", async ({ session }) => {
    await session
      .visit("/")
      .fillIn("Email", EMAIL)
      .fillIn("Password", PASSWORD)
      .clickButton("Sign up")
      .clickButton("Sign out")
      .assertText(/sign in/i);
  });
});
