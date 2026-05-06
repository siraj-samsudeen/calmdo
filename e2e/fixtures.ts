import { createConvexTest } from "feather-testing-convex/playwright";
import { api } from "../convex/_generated/api";

export const test = createConvexTest({
  convexUrl: process.env.VITE_CONVEX_URL!,
  clearAll: api.testingFunctions.clearAll,
});

export { expect } from "@playwright/test";
