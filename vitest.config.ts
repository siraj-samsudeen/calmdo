import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

// @convex-dev/auth/dist/react/client.js is an internal path not in the package
// exports field. feather-testing-convex imports it; inlining both packages through
// Vite's bundler lets the alias resolve correctly.
// See: https://github.com/get-convex/convex-auth/issues/281
const authClientPath = path.resolve(
  "node_modules/@convex-dev/auth/dist/react/client.js",
);

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { "@convex-dev/auth/dist/react/client.js": authClientPath },
  },
  test: {
    globals: true,
    coverage: {
      provider: "v8",
      thresholds: { lines: 100, functions: 100, branches: 100, statements: 100 },
      include: ["src/**", "convex/**"],
      exclude: [
        "convex/_generated/**",
        "**/*.test.*",
        "**/test.setup.*",
        "src/main.tsx",
        "src/routeTree.gen.ts",
        "src/routes/__root.tsx",
        "convex/testingFunctions.ts",
        "convex/auth.ts",
        "convex/http.ts",
      ],
    },
    projects: [
      {
        plugins: [react()],
        resolve: {
          alias: { "@convex-dev/auth/dist/react/client.js": authClientPath },
        },
        test: {
          name: "browser",
          environment: "jsdom",
          include: ["src/**/*.test.{ts,tsx}"],
          setupFiles: ["./src/test.setup.ts"],
          server: {
            deps: {
              inline: ["feather-testing-convex", "@convex-dev/auth"],
            },
          },
        },
      },
      {
        test: {
          name: "edge-runtime",
          environment: "edge-runtime",
          include: ["convex/**/*.test.ts"],
          server: { deps: { inline: ["convex-test"] } },
        },
      },
    ],
  },
});
