import { vi, describe, test, expect, beforeEach } from "vitest";
import { render, screen, cleanup } from "@testing-library/react";
import { useQuery, useConvexAuth } from "convex/react";
import App from "./App";

// Strip ConvexAuthProvider so there's no real Convex client created at module scope.
vi.mock("./routes/__root.tsx", async () => {
  const { createRootRoute, Outlet } = await import("@tanstack/react-router");
  return { Route: createRootRoute({ component: Outlet }) };
});

vi.mock("convex/react", async (importOriginal) => {
  const actual = await importOriginal<typeof import("convex/react")>();
  return { ...actual, useQuery: vi.fn(), useConvexAuth: vi.fn() };
});

vi.mock("@convex-dev/auth/react", () => ({
  useAuthActions: () => ({ signOut: vi.fn() }),
}));

beforeEach(() => {
  cleanup();
  vi.mocked(useConvexAuth).mockReturnValue({ isLoading: false, isAuthenticated: false });
  vi.mocked(useQuery).mockReturnValue(undefined);
});

describe("App", () => {
  test("authenticated user sees welcome with their email", async () => {
    vi.mocked(useConvexAuth).mockReturnValue({ isLoading: false, isAuthenticated: true });
    vi.mocked(useQuery).mockReturnValue("test@example.com");
    render(<App />);
    expect(await screen.findByText("Welcome, test@example.com!")).toBeInTheDocument();
  });

  test("unauthenticated user sees sign-in form", async () => {
    render(<App />);
    expect(await screen.findByRole("button", { name: /sign in/i })).toBeInTheDocument();
  });
});
