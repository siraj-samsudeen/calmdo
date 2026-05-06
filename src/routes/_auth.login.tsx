import { createFileRoute } from "@tanstack/react-router";
import SignInForm from "../components/SignInForm";

export const Route = createFileRoute("/_auth/login")({
  component: SignInForm,
});
