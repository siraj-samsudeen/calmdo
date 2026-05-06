import { query } from "./_generated/server";
import { getAuthUserId } from "@convex-dev/auth/server";

export const viewer = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (userId === null) return null;
    const user = await ctx.db.get(userId);
    /* v8 ignore next -- userId from a valid identity always has a document */
    if (!user) return null;
    return user.email ?? null;
  },
});
