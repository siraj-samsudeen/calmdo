# Stack Research

**Domain:** Project management web app (GTD inbox, time tracking, team knowledge base)
**Researched:** 2026-04-03
**Confidence:** HIGH

## Recommended Stack

The tech stack is decided. This research documents current versions, setup patterns, complementary packages, and known issues for each technology.

### Core Technologies

| Technology | Version | Purpose | Setup Notes |
|------------|---------|---------|-------------|
| React | 19.2.4 | UI framework | All stack deps support React 19 via peer deps |
| React DOM | 19.2.4 | DOM rendering | Ships with React |
| Vite | 8.0.3 | Build tool / dev server | Instant HMR, native ESM |
| Convex | 1.34.1 | Backend + real-time database | Peers: react ^18 or ^19. Run `npx convex dev` for local dev deployment |
| @convex-dev/auth | 0.0.91 | Authentication | Peers: convex ^1.17, @auth/core ^0.37.0, react ^18 or ^19 |
| @auth/core | 0.37.0 (pinned) | Auth provider foundation | Pin this exact version -- @convex-dev/auth requires ^0.37.0, not latest |
| TanStack Router | 1.168.10 | Type-safe client-side routing | File-based routing via Vite plugin, auto code-splitting |
| Tailwind CSS | 4.2.2 | Utility-first CSS | v4 uses @tailwindcss/vite plugin, CSS-based config (no tailwind.config.js) |
| shadcn/ui | CLI (latest) | Component library | Not an npm dep -- CLI copies components into your source. Uses Radix + Tailwind |

### Backend & Data

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| convex | 1.34.1 | Database, functions, real-time subscriptions | End-to-end type safety, automatic reactivity, in-memory testing via convex-test |
| convex-helpers | 0.1.114 | Validators, custom functions, relationships, row-level security | Official companion lib from Convex team. Adds Zod integration, relationship helpers, and custom function wrappers |
| convex-test | 0.0.46 | In-memory Convex backend for tests | Peers: convex ^1.32. Used by feather-testing-convex under the hood |

### Authentication

| Technology | Version | Purpose | Setup |
|------------|---------|---------|-------|
| @convex-dev/auth | 0.0.91 | Auth framework for Convex | `npx @convex-dev/auth` scaffolds config. Uses `ConvexAuthProvider` instead of `ConvexProvider` |
| @auth/core | 0.37.0 | Auth.js core (peer dep) | Pin to 0.37.0. Do NOT install latest -- breaking changes above this version |
| Password provider | built-in | Email/password login | Import from `@convex-dev/auth/providers/Password`. Separate sign-up/sign-in via `flow` field |

**Auth setup pattern:**

1. `npm install @convex-dev/auth @auth/core@0.37.0`
2. `npx @convex-dev/auth` (scaffolds convex/auth.ts, adds env vars)
3. Spread `authTables` into your schema
4. Wrap app with `ConvexAuthProvider` (not `ConvexProvider`)
5. Configure Password provider in `convex/auth.ts`
6. Invite-only: add a custom `createAccount` mutation that only admins can call, disable self-registration

### Routing

| Technology | Version | Purpose | Setup |
|------------|---------|---------|-------|
| @tanstack/react-router | 1.168.10 | Type-safe client routing | File-based routes in `src/routes/` |
| @tanstack/router-plugin | 1.167.12 | Vite plugin for file-based routing | Must be listed BEFORE `@vitejs/plugin-react` in vite plugins array |
| @tanstack/react-router-devtools | 1.166.11 | Dev-only route debugging | Auto-excluded from production builds |

**Vite config pattern:**

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { tanstackRouter } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    tanstackRouter({ target: 'react', autoCodeSplitting: true }),
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: { '@': '/src' },
  },
})
```

**Auth route protection:** Use `beforeLoad` on a pathless layout route (e.g., `_authenticated.tsx`) to check auth and `redirect()` to login. This prevents flash of protected content.

### UI Layer

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| shadcn/ui | CLI | Accessible components with full source control | Copies into `src/components/ui/`. AI-friendly, Radix primitives, Tailwind styling |
| @tailwindcss/vite | 4.2.2 | Tailwind v4 Vite plugin | Replaces PostCSS config. No tailwind.config.js needed -- use CSS @theme instead |
| lucide-react | 1.7.0 | Icon library | shadcn/ui default icon set. Tree-shakeable |
| class-variance-authority | 0.7.1 | Variant-based component styling | Used by shadcn/ui components for style variants |
| clsx | 2.1.1 | Conditional class joining | Lightweight className utility |
| tailwind-merge | 3.5.0 | Tailwind class deduplication | Prevents conflicting utility classes. Used in `cn()` helper |
| tw-animate-css | 1.4.0 | Animation utilities | Tailwind v4 compatible animation plugin (replaces tailwindcss-animate for v4) |
| sonner | 2.0.7 | Toast notifications | Lightweight, accessible. shadcn/ui has a Sonner wrapper component |
| cmdk | 1.1.1 | Command palette | Used by shadcn/ui Command component. Good for task search / quick actions |

### Forms & Validation

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| react-hook-form | 7.72.0 | Form state management | Minimal re-renders, uncontrolled inputs. shadcn/ui Form component wraps this |
| @hookform/resolvers | 5.2.2 | Schema validation bridge | Connects Zod schemas to react-hook-form |
| zod | 4.3.6 | Schema validation | Type-safe validation. Used by both forms (via resolver) and Convex functions (via convex-helpers Zod integration) |

**Form pattern:** Define a Zod schema, pass to `useForm` via `zodResolver`, use shadcn/ui `<Form>` + `<FormField>` components. One schema validates both client-side and can be shared with Convex function args via convex-helpers.

### Drag & Drop (Kanban)

| Technology | Version | Purpose | Status |
|------------|---------|---------|--------|
| @dnd-kit/react | 0.3.2 | Drag-and-drop for React | NEW rewrite of dnd-kit. Replaces @dnd-kit/core + @dnd-kit/sortable |
| @dnd-kit/dom | 0.3.2 | DOM abstraction layer | Peer dep of @dnd-kit/react |

**Important:** @dnd-kit/react (v0.x) is a ground-up rewrite that consolidates `@dnd-kit/core`, `@dnd-kit/sortable`, and `@dnd-kit/utilities` into a single package. It is in pre-1.0 and the API may change. Confidence: MEDIUM.

**Alternative:** If @dnd-kit/react 0.x proves too unstable, fall back to `@dnd-kit/core@6.3.1` + `@dnd-kit/sortable@10.0.0` which are stable and battle-tested with extensive kanban examples using shadcn/ui + Tailwind.

### Date & Time Handling

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| date-fns | 4.1.0 | Date formatting, manipulation, relative time | Tree-shakeable, immutable, no-class API. v4 is ESM-native. Use for "2 hours ago", "due tomorrow", timer display |

**Why not alternatives:**
- dayjs: Mutable API, plugin-based feature loading is clunky
- Temporal API: Not yet available in all browsers. date-fns provides the same immutability benefits today
- luxon: Heavier bundle, OOP API doesn't match React's functional style

### Testing

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| vitest | 4.1.2 | Test runner | Shares Vite config, native ESM, fast. Use `projects` array for separate envs |
| convex-test | 0.0.46 | In-memory Convex backend | Tests Convex functions without network. Peer: convex ^1.32 |
| feather-testing-convex | 0.5.5 | React+Convex integration testing | Wires convex-test's in-memory backend into React's provider tree. Components test against real Convex functions |
| feather-testing-core | 0.1.2 | Phoenix Test-inspired fluent DSL | Fluent API for both Playwright E2E and React Testing Library |
| @testing-library/react | 16.3.2 | React component rendering in tests | Used under the hood by feather-testing-convex |
| @testing-library/user-event | 14.6.1 | User interaction simulation | Realistic event firing (click, type, tab) |
| @testing-library/jest-dom | 6.9.1 | DOM assertion matchers | `toBeInTheDocument()`, `toHaveTextContent()`, etc. |
| @playwright/test | 1.59.1 | E2E browser testing | Full browser automation for workflow testing |
| jsdom | 29.0.1 | DOM environment for unit/integration tests | Used as Vitest environment for React component tests |

**Vitest multi-project config:** Use `projects` array to separate Convex function tests (edge-runtime env) from React component tests (jsdom env). This is required because convex-test needs edge-runtime but React components need jsdom.

```typescript
// vitest.config.ts
export default defineConfig({
  projects: [
    {
      test: {
        name: 'convex',
        environment: 'edge-runtime',
        include: ['convex/**/*.test.ts'],
      },
    },
    {
      test: {
        name: 'react',
        environment: 'jsdom',
        include: ['src/**/*.test.{ts,tsx}'],
        setupFiles: ['src/test-setup.ts'],
      },
    },
  ],
})
```

### Development Tools

| Tool | Version | Purpose | Notes |
|------|---------|---------|-------|
| @vitejs/plugin-react | 6.0.1 | React Fast Refresh for Vite | Place AFTER tanstackRouter plugin in vite config |
| TypeScript | latest (5.x) | Type safety | Convex generates types from schema into `convex/_generated/` |
| ESLint | 9.x | Linting | Use flat config format (eslint.config.js) |
| Prettier | latest | Formatting | Standard formatting |
| @tanstack/react-router-devtools | 1.166.11 | Route debugging | Dev-only, tree-shaken in prod |

## Supporting Libraries (Domain-Specific)

These are needed for specific features in the project management domain.

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| nuqs | 2.8.9 | Type-safe URL search params | Kanban filters, search queries, view state in URL. Integrates with TanStack Router |

**Considered but NOT needed yet:**

| Library | Purpose | When to Add |
|---------|---------|-------------|
| @tanstack/react-table | Data tables | If you need sortable/filterable task lists beyond kanban. Defer until needed |
| tiptap or plate | Rich text editing | If comments/activity logs need formatting beyond plain text. Defer |
| @tanstack/react-virtual | Virtualized lists | If task lists exceed ~100 items per view. Defer |

## Installation

```bash
# Core framework
npm install react react-dom convex @tanstack/react-router

# Auth
npm install @convex-dev/auth @auth/core@0.37.0

# UI (install shadcn CLI components separately via `npx shadcn@latest add [component]`)
npm install lucide-react class-variance-authority clsx tailwind-merge sonner cmdk

# Forms
npm install react-hook-form @hookform/resolvers zod

# Drag & drop
npm install @dnd-kit/react

# Date handling
npm install date-fns

# Convex utilities
npm install convex-helpers

# Dev dependencies
npm install -D vite @vitejs/plugin-react typescript @tailwindcss/vite tailwindcss
npm install -D @tanstack/router-plugin @tanstack/react-router-devtools
npm install -D vitest convex-test jsdom @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D feather-testing-convex feather-testing-core
npm install -D @playwright/test
npm install -D @types/react @types/react-dom
```

**shadcn/ui setup (run after npm install):**

```bash
npx shadcn@latest init
# Then add components as needed:
npx shadcn@latest add button card dialog form input label select textarea
npx shadcn@latest add command sonner dropdown-menu avatar badge checkbox
npx shadcn@latest add tabs sheet popover tooltip separator
```

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| TanStack Start | Convex IS the backend. SSR/server functions add unnecessary complexity for an SPA | TanStack Router (client-only) |
| TanStack Query / @convex-dev/react-query | Convex useQuery provides real-time reactivity out of the box. Adding TanStack Query adds a caching layer that fights Convex's subscription model | Convex's built-in useQuery/useMutation/useAction |
| React Router | TanStack Router provides type-safe routing with better DX | TanStack Router |
| @auth/core latest (>0.37.0) | @convex-dev/auth pins to ^0.37.0. Installing a newer version causes runtime errors | @auth/core@0.37.0 exactly |
| tailwindcss-animate | Designed for Tailwind v3. Incompatible with Tailwind v4's CSS-first config | tw-animate-css (Tailwind v4 compatible) |
| tailwind.config.js | Tailwind v4 uses CSS-based configuration via @theme directive. JS config is deprecated | CSS @theme in your main stylesheet |
| PostCSS for Tailwind | Tailwind v4 has a dedicated Vite plugin. No PostCSS config needed | @tailwindcss/vite |
| Convex Ents | Experimental ORM-like layer. Adds complexity without stability guarantees for a v1 product | convex-helpers for relationships + raw db API |
| moment.js | Enormous bundle, mutable, legacy | date-fns |
| react-beautiful-dnd | Deprecated, unmaintained | @dnd-kit/react |
| Zustand / Redux / Jotai | Convex useQuery handles all server state reactively. Local UI state should use React useState/useReducer | Convex useQuery for server state, React state for local UI |
| Jest | Vitest is faster, shares Vite config, native ESM support | Vitest |

## Version Compatibility Matrix

| Package | Compatible With | Critical Notes |
|---------|-----------------|----------------|
| convex@1.34.1 | react@^18 or ^19 | Types auto-generated from schema |
| @convex-dev/auth@0.0.91 | convex@^1.17, @auth/core@^0.37.0, react@^18 or ^19 | MUST pin @auth/core@0.37.0 |
| convex-test@0.0.46 | convex@^1.32 | Runs in edge-runtime env |
| feather-testing-convex@0.5.5 | convex@>=1.0, convex-test@>=0.0.1, react@>=18, vitest@>=1.0 | Has many optional peer deps -- only install what you use |
| @tanstack/react-router@1.168.x | react@>=18 or >=19 | Frequent releases, pin minor for stability |
| @tanstack/router-plugin@1.167.x | vite@>=5 | Must be first plugin in vite config |
| tailwindcss@4.2.2 | @tailwindcss/vite@4.2.2 | Match versions between tailwindcss and @tailwindcss/vite |
| shadcn/ui CLI | tailwindcss@4.x, react@>=18 | Uses tw-animate-css for Tailwind v4 (not tailwindcss-animate) |
| @dnd-kit/react@0.3.2 | react@>=18 | Pre-1.0, API may change. Evaluate stability before committing |
| zod@4.3.6 | Standalone | Major version jump from v3 -- verify convex-helpers Zod integration works with v4 |

## Convex-Specific Patterns

### Schema Design
- Start with schema from day 1 (not schemaless) because @convex-dev/auth requires `authTables` in schema
- Use `v.id("tableName")` for foreign keys (one-to-many relationships)
- Create indexes for every query pattern: name them `by_field1_and_field2`
- Arrays in documents: limited to ~10 elements for good practice, max 8192. Use for checklists (bounded), NOT for comments (unbounded)
- Store comments, activity logs, and sub-tasks as separate tables with parent references

### Real-Time Architecture
- Every `useQuery` creates a subscription -- Convex auto-pushes updates
- Mutations are optimistic by default in the client
- No need for WebSockets, polling, or cache invalidation code
- Use `useAction` only for side effects (email, external API calls)

### Scheduled Functions
- Convex supports cron jobs (`crons.daily()`, `crons.interval()`) for recurring tasks
- Use `ctx.scheduler.runAfter()` for one-off delayed tasks
- Useful for: daily "focus list" reset, cleanup of expired sessions

### File Storage
- Convex has built-in file storage via `ctx.storage`
- Upload URL generated server-side, POST from client, store `Id<"_storage">` in documents
- Relevant if learning resources need file attachments later

## Sources

- [Convex React Docs](https://docs.convex.dev/client/react) -- provider setup, hooks, React 19 peer dep verified via npm
- [Convex Auth Setup](https://labs.convex.dev/auth/setup) -- @convex-dev/auth installation and provider config
- [Convex Auth Passwords](https://labs.convex.dev/auth/config/passwords) -- Password provider, sign-up/sign-in flows, validation
- [Convex Best Practices](https://docs.convex.dev/understanding/best-practices/) -- schema design, index patterns
- [Convex Schema Relationships](https://stack.convex.dev/relationship-structures-let-s-talk-about-schemas) -- one-to-many, many-to-many patterns
- [Convex Indexes](https://docs.convex.dev/database/reading-data/indexes/) -- index design, naming, performance
- [convex-helpers GitHub](https://github.com/get-convex/convex-helpers) -- validators, custom functions, Zod integration
- [TanStack Router Vite Install](https://tanstack.com/router/latest/docs/installation/with-vite) -- plugin config, file-based routing
- [TanStack Router Auth](https://tanstack.com/router/v1/docs/guide/authenticated-routes) -- beforeLoad, redirect, route context
- [Tailwind CSS v4](https://tailwindcss.com/blog/tailwindcss-v4) -- Vite plugin, CSS-based config, @theme
- [shadcn/ui Vite Setup](https://ui.shadcn.com/docs/installation/vite) -- CLI init, component installation
- [shadcn/ui Form](https://ui.shadcn.com/docs/forms/react-hook-form) -- react-hook-form + Zod pattern
- [dnd-kit Kanban Example](https://github.com/Georgegriff/react-dnd-kit-tailwind-shadcn-ui) -- React + dnd-kit + Tailwind + shadcn/ui
- [Convex Testing](https://docs.convex.dev/testing/convex-test) -- convex-test setup, Vitest config
- [Convex Cron Jobs](https://docs.convex.dev/scheduling/cron-jobs) -- scheduled functions, cron syntax
- npm registry -- all version numbers verified via `npm view [package] version` on 2026-04-03

---
*Stack research for: CalmDo -- calm project management web app*
*Researched: 2026-04-03*
