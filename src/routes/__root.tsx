import { createRootRoute, Outlet } from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/router-devtools";
import { ConvexAuthProvider } from "@convex-dev/auth/react";
import { ConvexReactClient } from "convex/react";

const convex = new ConvexReactClient(import.meta.env.VITE_CONVEX_URL as string);

export const Route = createRootRoute({
  component: () => (
    <ConvexAuthProvider client={convex}>
      <Outlet />
      {import.meta.env.DEV && <TanStackRouterDevtools />}
    </ConvexAuthProvider>
  ),
});
