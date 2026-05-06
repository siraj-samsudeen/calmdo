import { createRootRoute, Outlet } from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/router-devtools";

export const Route = createRootRoute({
  component: () => (
    <>
      <Outlet />
      {/* v8 ignore next -- DEV-only devtools; never rendered in test or production builds */}
      {import.meta.env.DEV && <TanStackRouterDevtools />}
    </>
  ),
});
