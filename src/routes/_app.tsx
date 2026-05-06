import { createFileRoute, Navigate, Outlet } from "@tanstack/react-router";
import { useConvexAuth } from "convex/react";

export const Route = createFileRoute("/_app")({
  component: AppLayout,
});

function AppLayout() {
  const { isLoading, isAuthenticated } = useConvexAuth();
  /* v8 ignore next -- transient auth-loading state; feather resolves auth synchronously */
  if (isLoading) return <p>Loading…</p>;
  if (!isAuthenticated) return <Navigate to="/login" />;
  return <Outlet />;
}
