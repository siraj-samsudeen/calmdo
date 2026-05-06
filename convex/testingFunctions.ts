import { mutation } from "./_generated/server";
import schema from "./schema";

export const clearAll = mutation({
  args: {},
  handler: async ({ db }) => {
    /* v8 ignore next -- safety guard, never runs in production */
    if (process.env.IS_TEST !== "true") throw new Error("clearAll is test-only");
    for (const table of Object.keys(schema.tables) as Array<keyof typeof schema.tables>) {
      const docs = await db.query(table).collect();
      await Promise.all(docs.map((d) => db.delete(d._id)));
    }
  },
});
