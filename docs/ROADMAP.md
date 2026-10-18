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

**Technical foundation:** local repo initialization, pinned toolchain, Rojo build/serve, Luau format/lint checks, Wally resolution, offline smoke checks, local clone test, and Studio opening the built place were reported in the [initial setup audit](history/setup-validation-2026-10-18.md). No gameplay is implemented.

**Reconciled on 2026-10-18:**

- [x] Manual Studio live Rojo connection and edit/removal synchronization confirmed by the developer in the [setup follow-up](history/setup-follow-up-2026-10-18.md). Not rerun by the assistant during this review.
- [x] Both `[Server] Bootstrap ready` and `[Client] Bootstrap ready` in Studio Play Output confirmed by the developer in the same follow-up. Not a multiplayer or device test.
- [x] Remote `origin` configured as `https://github.com/F94Olivera/gdd.git`; integration branch is `master`. [GitHub Actions run 39155891887](https://github.com/F94Olivera/gdd/actions/runs/39155891887) completed successfully for commit `032131b00250a5da27972b067852b6984155c1e8`.
- [x] Local `lune run scripts/check.luau` rerun successfully during the repository review: formatting, lint, Rojo build and structural smoke checks.
- [x] Original Master GDD v2.1 reviewed against `docs/GDD.md`, with the companion prompt and future-concepts backlog inspected as reference material. Original-file retention/linking is no longer a requirement per producer decision E-005. This review does not make the working summary a verbatim transcription or approve proposed balance values.

**Separate contributor follow-up:** onboarding on the second contributor's Windows computer remains their responsibility, outside this setup's acceptance scope per the setup follow-up. It is not claimed as verified and does not block this local setup.

**First code increment (2026-10-18):** isolated continuous-quantity production model
in `scripts/models/Production.luau`, with explicit rates, two bounded buffers,
backpressure and capped steps; seven Lune tests included in the project check.
No gameplay integration or approved balance. This is a foundation for the full
seeded simulator below, not completion of that deliverable or a milestone gate.

**Remaining:**

- [x] Reconcile available reviewed starter details and competition rules in GDD §§4/8 (E-011). Starter connection resolved by D-013; competition presentation/rewards resolved by D-019.
- [x] Prepare the reviewable simulator specification and proposed deterministic first slice in BALANCE §5; no implementation or balance approval.
- [x] Resolve starter part of Q-010 via D-013 (replacement at 1/s).
- [x] Resolve remaining Q-010 competition presentation/rewards via D-019.
- [x] Run initial pure simulator with reproducible seeds: clearing rates, bounded buffers, approved p=0.00001/H=200000 guarantee and labelled pure-random control; export median/p90/p99 first-find waits under realistic sessions.
- [x] Resolve Q-001 and Q-003: producer decisions D-011/D-012 approve p=0.00001, mandatory H=200000, total 60/s cap and two maximum-capacity reference lines.
- [x] Resolve Q-002 with measured simulations and D-015 reference targets; real playtests pending.
- [x] Approve initial prices/first promotion D-014 and rank titles D-016; later promotion outside M1.
- [x] Review rank titles/first promotion (D-014/D-016) and critical persistence strategy (D-017); M1 failure tests pending.
- [x] Close initial sector plan/dimensions/capacities D-018: Ground-only launch.
- [x] Functional asset responsibilities and Studio source-preservation strategy in ASSET_PIPELINE. E-013 confirms no existing scenes; producer defers names/Roblox owner from M0. Actual permissions/first restore trial remain gates before future asset publication/integration.

**Exit gate:** signed-off blocking M0 rules, executable documented offline balance model, actually verified Rojo/Studio round trip, updated `DECISIONS.md` and M1 scoped tasks. No need to build gameplay to pass M0.

**Trabajo autorizado (E-012):** paso 1 implementado; resultados, comandos,
hipótesis y límites en BALANCE §13. D-013/D-019 resuelven starter y competición de Q-010. Paso 2 aprobado D-014–D-016 y repetido: E10 cumple objetivos; resultados en
BALANCE §14. Commit `d98f601`, [CI exitoso](https://github.com/F94Olivera/gdd/actions/runs/39172893779).
Paso 3: estrategia documentada en ARCHITECTURE y casos P-001–P-012 en TEST_PLAN;
Q-007/D-017 aprobada como estrategia, pruebas reales pendientes de M1.
Paso 4 resuelto D-018/D-019/E-013, pendiente de commit/CI. Paso 5 pendiente. No agregar fixtures vecinos sin defecto. M0 continúa abierto.

## M1 — First playable vertical slice

**Scope:** one Ground plot/floor and replenishing pile; free connected starter manual lane; an extractor, basic routable conveyor and processor; ordinary production + Intel; one genuine archive class; permanent count/title; interactive tutorial and demonstration; one voluntary promotion; robust persistence with recovery. Placeholder art is sufficient.

**Recommended implementation order:**

1. Define versioned shared machine/price/progression configuration + typed domain contracts; config validation tests.
2. Pure server-production model: source extraction, one-time unit identity/eligibility, bounded queues, graph checks, fractional rates, backpressure and edit conservation; seeded Lune tests.
3. Server plot/build ownership, safe topology mutations and explicit input validation; local single-player Studio checks.
4. Discovery under D-011/D-012, after remaining M0 gates including Q-002 and durable protocol Q-007; server RNG, mandatory 200000-unit guarantee, clean award identity and durable/pending state tests.
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

- [ ] Ground-only initial launch D-018; Upper/Basement remain a separately approved expansion, not an alpha/launch dependency.
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
