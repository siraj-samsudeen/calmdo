import { createFileRoute } from "@tanstack/react-router";
import Content from "../Content";

export const Route = createFileRoute("/_app/")({
  component: Content,
});
