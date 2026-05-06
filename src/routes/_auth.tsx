import { createFileRoute, Navigate, Outlet } from "@tanstack/react-router";
import { useConvexAuth } from "convex/react";

export const Route = createFileRoute("/_auth")({
  component: AuthLayout,
});

function AuthLayout() {
  const { isLoading, isAuthenticated } = useConvexAuth();
  /* v8 ignore next -- transient auth-loading state; feather resolves auth synchronously */
  if (isLoading) return <p>Loading…</p>;
  /* v8 ignore next -- authenticated-at-/login redirect covered by E2E */
  if (isAuthenticated) return <Navigate to="/" />;
  return <Outlet />;
}
