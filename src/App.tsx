import { RouterProvider, createRouter } from "@tanstack/react-router";
import { useState } from "react";
import { routeTree } from "./routeTree.gen";

export default function App() {
  const [router] = useState(() => createRouter({ routeTree }));
  return <RouterProvider router={router} />;
}
