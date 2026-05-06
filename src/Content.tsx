import { useAuthActions } from "@convex-dev/auth/react";
import { useQuery } from "convex/react";
import { api } from "../convex/_generated/api";

export default function Content() {
  const { signOut } = useAuthActions();
  const email = useQuery(api.users.viewer);
  // useQuery: undefined = loading, null = query returned null, string = data.
  // Always === undefined (strict) — !email conflates loading with empty.
  if (email === undefined) return <p>Loading…</p>;
  /* v8 ignore next -- null unreachable: Content only mounts behind _app.tsx auth guard */
  if (email === null) return null;
  return (
    <div className="flex flex-col gap-8 max-w-lg mx-auto">
      <p>Welcome, {email}!</p>
      <button
        className="bg-dark dark:bg-light text-light dark:text-dark text-sm px-4 py-2 rounded-md border-2"
        onClick={() => void signOut()}
      >
        Sign out
      </button>
      {/* TODO: add app content here */}
    </div>
  );
}
