import { vi, test, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useQuery } from "convex/react";
import Content from "./Content";

vi.mock("convex/react", async (importOriginal) => {
  const actual = await importOriginal<typeof import("convex/react")>();
  return { ...actual, useQuery: vi.fn() };
});

vi.mock("@convex-dev/auth/react", () => ({
  useAuthActions: () => ({ signOut: vi.fn() }),
}));

test("shows loading state", () => {
  vi.mocked(useQuery).mockReturnValue(undefined);
  render(<Content />);
  expect(screen.getByText("Loading…")).toBeInTheDocument();
});

test("shows welcome and sign-out button when authenticated", async () => {
  vi.mocked(useQuery).mockReturnValue("hello@example.com");
  render(<Content />);
  expect(screen.getByText("Welcome, hello@example.com!")).toBeInTheDocument();
  await userEvent.click(screen.getByRole("button", { name: /sign out/i }));
});
