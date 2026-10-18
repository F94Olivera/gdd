# Agent instructions — Find the Secret Archive

These rules apply to **Codex, Claude, and other coding assistants** working in this repository. They are instructions for work quality and collaboration, not permission to make unattended production changes.

## 1. Before editing

1. Inspect the **actual repository** (`README.md`, `default.project.json`, `rokit.toml`, Wally manifests/lock, `src/`, `scripts/`, `tests/`, CI) and its current Git status. Do not assume planned paths exist.
2. Read `docs/GDD.md`, `docs/DECISIONS.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `docs/BALANCE.md`, and `docs/TEST_PLAN.md` for affected systems. Refer to the original Master GDD v2.1 when the working summary is ambiguous.
3. State the narrow goal, files to modify, risks, and acceptance checks. Implement **one reviewable milestone slice**, not the entire launch game in one dump.
4. Separate verified facts from assumptions, proposals, and producer decisions. Ask focused questions about blocking product tradeoffs; do not silently choose them.

## 2. Product invariants (must not be violated)

- One genuine **Confidential Archive** collectible class; every legitimate discovery increments `lifetimeArchives` by **exactly one**. No rarity tiers, variants, duplicate penalties, unique-file checklist or collectible consumption.
- Rank titles derive **only** from lifetime genuine discoveries. Production/earnings leaderboards are separate competition categories.
- A newly accepted eligible paperwork unit gets **one** discovery opportunity **at clearing** (manual or authorized extractor), not when a scanner/processor completes. Scanner/processor is for ordinary income, not discovery eligibility.
- An ordinary output unit remains payable through secure processing even when clearing also discovers an archive; rewards are additional.
- Server-owned RNG, eligibility, counts, rewards, Intel, machine throughput, layout validation, queue occupancy and progress. No client-supplied luck or archive grants.
- Bounded buffers and backpressure; full downstream capacity eventually stops new clearing and hence new discovery opportunities. Never reroll old units after belt edits, reconnection or promotion.
- A **Demonstration Archive** is tutorial-only: no lifetime credit, rankings, Intel or guarantee-counter impact. Genuine natural finds during tutorial still count.
- Voluntary promotions never require random finds; lifetime archives, rank and discovery failure counter survive them. No offline production/discovery in launch scope.
- PC and touch are launch targets, eight independent plots are the load target; launch excludes combat, pets, theft, trading, paid archives and pay-for-luck mechanics.

## 3. Scope gates

**Current work is M0**, unless the producer explicitly authorizes an M1 slice. Preserve existing bootstraps and configs. Do not scaffold dozens of empty modules or fake working gameplay.

Do **not** add Express, Node.js services, PostgreSQL, Docker, paid products, external analytics pipelines, gameplay packages or Roblox frameworks by default. Do not choose Knit or ProfileService by habit. When persistence becomes an M1 deliverable, review current maintenance/security of ProfileStore or an alternative and document the selection.

Resolve before production implementation: hard-guarantee vs pure-random policy, intended player-facing time-to-find targets, late-game throughput cap, rank thresholds, clearance fees, sector count and durable discovery grant protocol. Proposed numbers in `BALANCE.md` are **not approvals**.

## 4. Engineering rules

- Use typed Luau (`--!strict`) for new runtime scripts and explicit types at public module boundaries. Prefer small, composable modules with simple ownership and no dependency-injection theater.
- `src/server` owns authority, purchase validation, data access, simulation, RNG, leaderboards and monetization receipt checks. `src/client` owns input, display, effects, previews and accessible UX. `src/shared` holds **public** types, configuration and deterministic/pure calculations only.
- Use a fixed, explicit bootstrap order. Avoid hidden circular `require()` dependencies and remote contracts spread over unrelated scripts.
- Validate all external input at the **server boundary**: type, shape, finite numbers, IDs, permissions, ownership, distance where applicable, prerequisites, range, state, rate limit and operation ID. Serialize expensive/critical mutations; reject replays.
- Server simulation uses bounded logical quantities, deterministic update ordering, fractional units and capped catch-up; client papers are representative visuals, never one physical object per economic unit.
- Build transactions must reject invalid graph cycles, ports, overlaps and bounds. No inventory loss or duplicate opportunities during topology edits. A failed edit must leave state consistent.
- Define a persistence **durability boundary**. An in-memory update does **not** equal a durable save. Test idempotent pending awards/retries before saying a reward is safely committed. Separate test and production stores.
- Store versioned, stable IDs for definitions and migrations; never silently change probability, destroy archive counts or wipe existing progress to facilitate a code change.
- Treat all data in `ReplicatedStorage` as visible to clients. Do not place credentials, private algorithms or privileged secrets in `src/shared`.

## 5. Repository and tools

- Keep Git as source of truth for Luau files; do not make parallel edits to Rojo-managed Studio scripts.
- Do not modify `default.project.json` without auditing its managed instance tree and Studio sync impact.
- Respect `rokit.toml`, `wally.lock`, `.gitattributes` and `.gitignore`; do not run automatic dependency upgrades. Add dependencies only with a concrete need and source/maintenance review.
- Binary art belongs in LFS according to `.gitattributes`; textual models/configuration stay in normal Git. Merely storing a source asset in LFS does **not** upload it to Roblox or embed it in Rojo builds.
- Never publish, upload assets, push, force-push, merge, create/delete Git remotes, mutate live DataStores or enable Studio live API access without explicit authorization.
- Validate local changes with `lune run scripts/check.luau`; add offline tests for pure logic; perform Studio Play, multiplayer and touch checks where appropriate. Do not pretend Lune can emulate all Roblox engine APIs.

## 6. Art collaboration

The engineering contributor owns code, data contracts, integration and reproducible builds; the art contributor owns Blender/Substance source content and agreed exports. Asset handoffs need stable IDs, scale, pivots, attachment/port locations, texture budgets, collision, licensing and review. Keep originals, not only uploaded Roblox asset IDs. Use placeholders until the core loop works.

## 7. Required task handoff

For every completed task, report:

1. **Scope and changed files** (not just a high-level success claim).
2. **Design choices** made and decisions still awaiting producer approval.
3. **Commands run and results**; distinguish not-run checks from successful checks.
4. **Studio/multiplayer/device verification** actually performed versus pending.
5. **Known risks**, regressions and the smallest safe next step.

Update `docs/DECISIONS.md` on explicit producer decisions, `docs/BALANCE.md` for tuning proposals and measured results, `docs/ROADMAP.md` when a milestone gate changes, and the README for setup/workflow changes. Never edit a canonical product rule just to make tests pass.
