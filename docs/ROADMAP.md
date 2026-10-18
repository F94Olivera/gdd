# Implementation roadmap — M0 to M4

**Planning status:** initialized 2026-10-18. Milestones are **acceptance gates**, not fixed delivery dates or evidence that features already exist. The Master GDD v2.1 controls gameplay scope. Assign owners and realistic sprint estimates only after M0 blockers and the actual repo have been reviewed.

## Definition of Done (all gameplay slices)

- An approved rule / decision ID and explicit acceptance criteria; no unrequested changes to monetization, rarity or progression.
- Relevant modules/types/config documented; errors and non-happy-path transitions handled.
- Automated checks pass (`lune run scripts/check.luau`), with unit/seeded regression tests for newly introduced pure logic.
- Server input validation and exploit/replay cases covered for all affected interactions.
- Studio Play check performed; multiplayer/touch and persistence checks where the feature warrants them.
- Producer/art handoff complete for any asset contract; placeholders labeled; no proprietary reference assets used.
- Report changed files, test results **actually observed**, known limitations, unresolved decisions and safe next increment.
- Schema/balance compatibility and rollback impact addressed when persistent state changes.

## M0 — Specification + foundation (current)

**Already reported as done in the initial setup audit:** local repo initialization, pinned toolchain, Rojo build/serve, Luau format/lint checks, Wally resolution, offline smoke checks, local clone test, and Studio opening the built place. This is not proof of a functional game or remote CI.

**Remaining:**

- [ ] Finish manual Studio **live Rojo connect** verification (edit in VS Code -> appears in Studio -> removal syncs).
- [ ] Run Studio Play and confirm both bootstrap messages in Output.
- [ ] Complete onboarding on the second developer's separate Mac/PC.
- [ ] Create/authorize a private remote only when requested; then run and confirm GitHub Actions check.
- [ ] Compare `docs/GDD.md` against the full original Master GDD v2.1 and attach/link canonical source in the actual coding workspace.
- [ ] Run initial pure simulator with reproducible seeds: clearing rates, bounded buffers, random and proposed guarantee; export median/p90/p99 first-find waits under realistic sessions.
- [ ] Resolve Q-001–Q-003 in `DECISIONS.md` (random/guarantee, target waits, late-capacity bounds).
- [ ] Review rank titles, first promotion economy, sector plan and critical persistence strategy before building affected systems.
- [ ] Map asset ownership, authorized Roblox group/experience ownership and Studio-only scene versioning strategy.

**Exit gate:** signed-off blocking M0 rules, executable documented offline balance model, actually verified Rojo/Studio round trip, updated `DECISIONS.md` and M1 scoped tasks. No need to build gameplay to pass M0.

## M1 — First playable vertical slice

**Scope:** one Ground plot/floor and replenishing pile; free connected starter manual lane; an extractor, basic routable conveyor and processor; ordinary production + Intel; one genuine archive class; permanent count/title; interactive tutorial and demonstration; one voluntary promotion; robust persistence with recovery. Placeholder art is sufficient.

**Recommended implementation order:**

1. Define versioned shared machine/price/progression configuration + typed domain contracts; config validation tests.
2. Pure server-production model: source extraction, one-time unit identity/eligibility, bounded queues, graph checks, fractional rates, backpressure and edit conservation; seeded Lune tests.
3. Server plot/build ownership, safe topology mutations and explicit input validation; local single-player Studio checks.
4. Discovery policy **only after Q-001–Q-003**; server RNG, guarantee if approved, clean award identity and durable/pending state tests.
5. Profile solution with session ownership, migrations, retry/reconnect/shutdown handling and separate test stores; verify the persistence commit boundary.
6. Ordinary Intel processing and serialized purchases/upgrade/promotion operations.
7. Client input, minimal status/bottleneck UI, representative pile/tray visuals and skippable/resumable server-confirmed tutorial.
8. Local lifetime title/counter and stats events + first-search timing; two-client interaction and touch rotate/cancel checks.

**Exit gate:** a new player can clear material, earn Intel, buy automation, route processing, legitimately uncover one archive, safely leave/rejoin, see correct permanent count/title and complete a voluntary promotion. All critical exploit/duplicate/lost-reward tests in `TEST_PLAN.md` pass. No Robux, advanced sector/floor, global boards or polished final art required.

## M2 — Usability and resilience

- [ ] Touch control quality: hold/tap, placement preview, rotate/cancel, readable UI and production bottleneck state.
- [ ] Reveal inbox, replay-without-credit, reduced motion, sound and announcement toggles, high contrast.
- [ ] Full inventory-safe edit/removal UX and protection from accidental factory resets.
- [ ] Offline simulation vs online rates/visual reconciliation; graph congestion and throughput explanations.
- [ ] Measured new-player tutorial completion / first automation / sensible factory workflow.

**Exit gate:** meaningful PC/touch playtests and interruption/recovery tests, without lost progress or UI blocking production.

## M3 — Closed alpha and scale

- [ ] Expand **up to** three sectors/floors only after explicit scope approval; validate all authored ports and transfers.
- [ ] Eight-populated-plot production/load checks under named device/network test conditions.
- [ ] Recovery, reconnect, data-budget, profile contention and progression stress scenarios.
- [ ] Build Stats/Leaderboard global projections and UTC daily/weekly/monthly/all-time board verification: occurrence times, idempotency, throttling, absolute-score reconciliation, stale UI and no demo grants.
- [ ] Review test instrumentation, first-find distribution and upper-level production rarity with real play sessions.

**Exit gate:** a closed alpha can be operated and recovered; only global categories passing the reliability gate go live.

## M4 — Launch readiness

- [ ] Original polished, licensed art/audio with reproducible source and published asset manifest.
- [ ] Validated tutorial, accessibility and product analytics privacy expectations.
- [ ] Core public global boards (archives, cleared units, production Intel) working for four UTC periods, not conflated with permanent rank.
- [ ] Cosmetic-only commerce if approved: server-validated entitlements, receipt idempotency and failure recovery.
- [ ] Device/performance targets measured, not merely listed; migrations/rollbacks tested; operational ownership and incident plan.
- [ ] Security, policy, age/device/platform review and final user experience QA.

**Exit gate:** production publishing approved by the two developers and the producer; no unresolved integrity bugs around rewards, saves or purchases. Publishing itself is a separately authorized action.

## Target performance (hypotheses; never report as achieved without measurements)

| Metric | Initial target | Measurement required |
| --- | --- | --- |
| Server players/plots | 8 populated plots | Named hardware, actual multiplayer Studio/live equivalent |
| Simulation node scale | 60 logical nodes per plot | Graph shape/queue saturation profile |
| Production update | p95 below 10 ms | Timed server ticks with realistic content |
| Mobile performance | 30 FPS minimum on a named midrange phone | Real device, graphics settings, network + content recorded |
| Desktop performance | 60 FPS on a named baseline | Device, graphics and network recorded |
| First interaction / automation / demonstration | 20 s / 2 min / 5 min | Cohort event timings in real sessions |
| Rarity distribution | median/p90/p99 + rank pacing | >=100,000 seeded synthetic runs per balance revision per GDD |

## Future (not part of current authorization)

Secondary leaderboards (documents processed, fastest-first), value-added ordinary paper, limited assignments, tool progression, splitters, richer industrial routing, controller/console and additional commerce mechanics each require a distinct scope decision, tests and realistic cost estimate. Never silently promote them into M1.
