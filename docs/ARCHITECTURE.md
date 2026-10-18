# Architecture — Find the Secret Archive

**State:** M0 design proposal, not an assertion that every module has been implemented. Parent specification: Master GDD v2.1 and the approved decisions log.

## Architecture principles

One Git monorepo; one Roblox experience architecture; **no external backend in M0/M1**. Server-authoritative economy, clearing, rarity, building, progression and persistence. Client-authoritative **presentation only**. Pure, deterministic simulation components must be runnable with Lune wherever Roblox APIs are not required. Introduce files and abstractions when a feature requires them; do not create placeholder services just to fill folders.

## Existing layout versus intended expansion

Existing runtime roots as described by the initial setup:

```text
src/server/Bootstrap.server.luau  -> ServerScriptService.Server
src/client/Bootstrap.client.luau  -> StarterPlayer.StarterPlayerScripts.Client
src/shared/                     -> ReplicatedStorage.Shared
scripts/                         -> local tooling, outside the Roblox place
tests/                           -> offline tests, outside the Roblox place
```

Potential M1 layout **after** features are approved (not a scaffolding instruction):

```text
src/
  server/
    Bootstrap.server.luau
    services/
      PlayerDataService.luau
      PlotService.luau
      BuildService.luau
      ProductionService.luau
      DiscoveryService.luau
      EconomyService.luau
      ProgressionService.luau
      TutorialService.luau
      StatsService.luau
      LeaderboardService.luau          # global publishing follows M3 gate
    network/                            # validated remote handlers, when needed
  client/
    Bootstrap.client.luau
    controllers/                        # input, placement, tutorial, reveal
    ui/                                 # components and status screens
    visuals/                            # bounded paper/warehouse effects
  shared/
    config/                             # versioned public definitions
    types/                              # stable public contracts
    simulation/                         # pure graph/rates/queue arithmetic
    util/                               # small reusable pure helpers
scripts/                                # tooling and reproducible simulations
tests/                                  # seeded simulations and fixtures
assets/                                 # source assets and exports as defined by pipeline
```

This is not an Express-style controller/service/repository mapping. **Services own authoritative domain behavior**, client controllers orchestrate UX, and `shared/simulation` holds engine-free domain calculations. Persistence adapters should live behind `PlayerDataService` (separate `repositories/` only if concrete duplication justifies it).

## Ownership of domain boundaries

| Owner | Responsibilities | Never trusts |
| --- | --- | --- |
| PlayerData | Session locking, migrations, profile loading, budgets, durable operations, reconciliation | A client-provided balance or progress |
| Plot + Build | Eight-plot ownership, slots/ports/grid topology, safe equipment edits, inventory conservation | Client-declared placement, inventory, ownership |
| Production | Logical input units, queues, processing rates, backpressure, fractional accumulation, fixed-step/capped catch-up | Visual paper objects or client-reported throughput |
| Discovery | Once-per-eligible-unit roll, server RNG, optional approved guarantee, unique reward operation IDs and pending commitments | Client randomness, discovered archive count |
| Economy + Progression | Intel credit/spending, machine eligibility, permanent count-derived rank, sector access and voluntary promotion | Client prices, permissions or rank |
| Tutorial | Server-confirmed step completion; separate unranked demonstration reward | UI animation as proof of completion |
| Stats | One-time authoritative event semantics and versioned period counters | Client timings/scores and repeated events |
| Leaderboard | Idempotent, budget-aware global projections of committed stats; reconciliation | Uncommitted local counters or stale snapshots |
| Client controllers | UI, input, previews, motion, sounds, visual layers, discovery inbox | None of the gameplay authority |

Do not create `CommerceService` or a receipt pipeline until a later milestone makes purchases necessary.

## Core production flow

```text
plot supply (fresh logical units)
    -> manual sort OR authorized extractor
    -> ONE clearing eligibility event (+ potential archive award)
    -> bounded ordinary-output buffer
    -> player-connected conveyors (validated directed graph)
    -> processor
    -> secure output (+ one production Intel award)
```

A genuine archive reward is **additional** to ordinary output. Each fresh unit receives discovery eligibility **exactly once**. The scanner/process stage never gates the existence of an archive; reprocessing, moving belts and reconnects cannot regenerate clearing events.

### Simulation contract

- Initial target: **5 Hz** server production update, elapsed-time accounting, fractional unit accumulators and stable traversal order.
- Cap each update's catch-up to **2 seconds** and log discarded production time (GDD proposed defaults).
- Buffer/output capacities are finite; a full downstream stage propagates backpressure and eventually halts extraction.
- One logical unit is not represented by one Roblox Part. Client budget starts at **240 representative moving papers** across nearby plots (including max 120 owner and 30 per nearby visitor plot), to be validated on target devices.
- Production engine should accept pure data/state and return deterministic state transitions/events for seeded offline tests. Server adapters manage the clock, Roblox instances, remotes and save operations.
- Graph validation: designated machine footprints, 4-stud grid, typed ports, no cycles, blocked lanes, bounds, safe edit previews and transactional recovery of in-flight content.

## Server-to-client API design (when implemented)

No remotes are required by this documentation-only change. When introducing them, define typed intent messages (e.g. `RequestManualClear`, `RequestBuild`, `RequestPurchase`, `RequestPromotion`) and server-originated snapshots/notifications. Request payloads contain **intent and identifiers**, not derived prices, completion times, drop results, or raw user profile tables.

For each message document the schema, caller permissions, idempotency key, rate limit, validation errors and lifecycle. Validate finite numeric values, table size, IDs, ownership, proximity if relevant and legal state transitions. Enforce one owner of every state transition. Do not expose arbitrary instance paths or privileged operations.

## Persistence and durable awards

Suggested profile domains: `schemaVersion`, `balanceVersion`, `intel`, `lifetimeArchives`, `discoveryFailureCounter`, bounded pending/committed award identity, sector/clearance state, machines/layout/queues/fractions, cumulative production/stats, first-search timing, tutorial flags, cosmetics/preferences and bounded operation records.

**Critical invariant:** never claim a genuine reward permanently saved only because a Lua table was incremented. M1 must approve a documented durable protocol for grant -> persistent commit/ack -> presentation/recovery, including duplicate requests, disconnects, retries, session contention and partial failures. Need separate test/staging stores and fail-closed profile loading (retry, not a blank writable replacement).

Session locking, bounded backoff, save budgets, release/shutdown handling, idempotent purchases/promotions and migrations are required. If retaining operation IDs in bounded history, define how long-term idempotency and receipt reconciliation remain safe after eviction. Promotion keeps archives, rank, genuine discovery counter, stats, tutorial and cosmetics; resets factory layout and Intel according to the approved rules.

## Global boards / statistics

Permanent **archive title** = function of lifetime genuine archive total. Separately, `StatsService` records archives found, fresh documents cleared, production Intel earned, and optional validated secondary categories. Period buckets use UTC day, Monday week, month and all-time with server event occurrence timestamps. Test grants, demonstrations, refunds and rebuild grants are excluded as appropriate. In M1 ship authoritative counters and local UI; global board publication begins after its M3 reliability gate. Use idempotent **absolute scores**, reconcile stale/failing snapshots and avoid per-document DataStore writes.

## Configuration and rollout

Use stable IDs and explicit schema/balance versioning for machine specs, tiers, capacities, prices, rank thresholds, sectors, art identifiers and discovery policy. Make supported content extensible by data + assets; genuinely new mechanics require code/tests. Maintain a migration/rollback plan for changes to player-owned state; preserve earned archives and counter. Do not couple simulation to a particular UI hierarchy or artist asset name.

## Open architecture decisions

- Select and verify a maintained profile/session persistence solution and define its real commit semantics.
- Choose approved rarity/guarantee rules and data encoding for pending awards.
- Define bounded queue recovery and exact event identity for throughput accounting.
- Confirm when a leaderboard projection can be reconciled without trusting stale writes.
- Validate Studio-only scene/asset workflows before considering the experience reproducible.

## Platform implementation references

- [Roblox: secure client/server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Roblox: DataStores and Studio API-access isolation](https://create.roblox.com/docs/cloud-services/data-stores)
- [Roblox: DataStores versus MemoryStores](https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores)

A Studio test environment must never be configured to write to the production DataStore by accident; use a separate test experience/store boundary. Any persistence abstraction adopted during M1 must be reviewed against current documented Roblox behavior.
