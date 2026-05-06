import { createConvexTest, renderWithConvex, renderWithConvexAuth } from "feather-testing-convex";
import { renderWithSession } from "feather-testing-convex/rtl";
import schema from "./schema";

export const modules = import.meta.glob("./**/!(*.*.*)*.*s");
export const test = createConvexTest(schema, modules);
export { renderWithConvex, renderWithConvexAuth, renderWithSession };
