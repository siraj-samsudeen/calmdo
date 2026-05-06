import { vi, test, expect, beforeEach } from "vitest";
import { render, screen, cleanup } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import SignInForm from "./SignInForm";

const mockSignIn = vi.fn();

vi.mock("@convex-dev/auth/react", () => ({
  useAuthActions: () => ({ signIn: mockSignIn }),
}));

beforeEach(() => {
  cleanup();
  mockSignIn.mockReset();
  mockSignIn.mockResolvedValue(undefined);
});

test("renders sign-in flow by default", () => {
  render(<SignInForm />);
  expect(screen.getByRole("button", { name: "Sign in" })).toBeInTheDocument();
  expect(screen.getByText("Don't have an account?")).toBeInTheDocument();
  expect(screen.getByText("Sign up instead")).toBeInTheDocument();
});

test("toggles between sign-in and sign-up flows", async () => {
  render(<SignInForm />);
  await userEvent.click(screen.getByText("Sign up instead"));
  expect(screen.getByRole("button", { name: "Sign up" })).toBeInTheDocument();
  expect(screen.getByText("Already have an account?")).toBeInTheDocument();
  await userEvent.click(screen.getByText("Sign in instead"));
  expect(screen.getByRole("button", { name: "Sign in" })).toBeInTheDocument();
});

test("shows error message when sign-in fails", async () => {
  mockSignIn.mockRejectedValue(new Error("Invalid credentials"));
  render(<SignInForm />);
  await userEvent.type(screen.getByPlaceholderText("Email"), "test@example.com");
  await userEvent.type(screen.getByPlaceholderText("Password"), "wrongpass");
  await userEvent.click(screen.getByRole("button", { name: "Sign in" }));
  expect(await screen.findByText("Error signing in: Invalid credentials")).toBeInTheDocument();
});
