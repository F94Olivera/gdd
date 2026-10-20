# Implementation roadmap — M0 to M4

**Status:** M0 completed on 2026-10-18; M0.1 exit gate passed on 2026-10-20 (Studio/art follow-ups M0.1-06/07/12 still open, non-blocking); M1 in progress, M1-01 done under E-016 and M1-02 under E-017. Milestones are **acceptance gates**, not fixed delivery dates or evidence that features already exist. The Master GDD v2.0 ([transcription](reference/MASTER_GDD_v2.0.md)) controls gameplay scope. Assign owners and realistic sprint estimates only after M0 blockers and the actual repo have been reviewed.

## Definition of Done (all gameplay slices)

- An approved rule / decision ID and explicit acceptance criteria; no unrequested changes to monetization, rarity or progression.
- Relevant modules/types/config documented; errors and non-happy-path transitions handled.
- Automated checks pass (`lune run scripts/check.luau`), with unit/seeded regression tests for newly introduced pure logic.
- Server input validation and exploit/replay cases covered for all affected interactions.
- Studio Play check performed; multiplayer/touch and persistence checks where the feature warrants them.
- Producer/art handoff complete for any asset contract; placeholders labeled; no proprietary reference assets used.
- Report changed files, test results **actually observed**, known limitations, unresolved decisions and safe next increment.
- Schema/balance compatibility and rollback impact addressed when persistent state changes.

## M0 — Specification + foundation (complete)

**Technical foundation:** local repo initialization, pinned toolchain, Rojo build/serve, Luau format/lint checks, Wally resolution, offline smoke checks, local clone test, and Studio opening the built place were reported in the [initial setup audit](history/setup-validation-2026-10-18.md). No gameplay is implemented.

**Reconciled on 2026-10-18:**

- [x] Manual Studio live Rojo connection and edit/removal synchronization confirmed by the developer in the [setup follow-up](history/setup-follow-up-2026-10-18.md). Not rerun by the assistant during this review.
- [x] Both `[Server] Bootstrap ready` and `[Client] Bootstrap ready` in Studio Play Output confirmed by the developer in the same follow-up. Not a multiplayer or device test.
- [x] Remote `origin` configured as `https://github.com/F94Olivera/gdd.git`; integration branch is `master`. [GitHub Actions run 39155891887](https://github.com/F94Olivera/gdd/actions/runs/39155891887) completed successfully for commit `032131b00250a5da27972b067852b6984155c1e8`.
- [x] Local `lune run scripts/check.luau` rerun successfully during the repository review: formatting, lint, Rojo build and structural smoke checks.
- [x] ~~Original Master GDD v2.1 reviewed against `docs/GDD.md`, with the companion prompt and future-concepts backlog inspected as reference material. Original-file retention/linking is no longer a requirement per producer decision E-005. This review does not make the working summary a verbatim transcription or approve proposed balance values.~~ **Revisado 2026-10-19:** el archivo original entregado por el productor se titula *Master GDD v2.0* (9 páginas, 8 secciones), no «v2.1»/«12-page»; además GDD.md §8 (competición global) no es trazable a ese archivo. Ver [contraste](history/source-contrast-2026-10-19.md) y M0.1-01/M0.1-03.

**Separate contributor follow-up:** onboarding on the second contributor's Windows computer remains their responsibility, outside this setup's acceptance scope per the setup follow-up. It is not claimed as verified and does not block this local setup.

**First code increment (2026-10-18):** isolated continuous-quantity production model
in `scripts/models/Production.luau`, with explicit rates, two bounded buffers,
backpressure and capped steps; seven Lune tests included in the project check
(at that increment; the suite now has 16 Production cases).
No gameplay integration or approved balance. This is a foundation for the full
seeded simulator below, not completion of that deliverable or a milestone gate.

**M0 acceptance record:**

- [x] Reconcile available reviewed starter details ~~and competition rules~~ in GDD §4 ~~/8~~ (E-011). Starter connection resolved by D-013; ~~competition presentation/rewards resolved by D-019~~ → la «omisión de competición» no existe en el GDD v2.0 entregado; D-019 sigue válida como decisión del productor, pero su premisa debe re-trazarse (M0.1-03). **Re-trazado 2026-10-20:** D-021 ratifica la competición como decisión del productor.
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

### Exit-gate audit — 2026-10-18

| Exit requirement | Evidence and actual boundary | Result |
| --- | --- | --- |
| Blocking product rules signed off | D-011–D-019: p/H/cap, starter, initial prices/promotion, pacing, rank titles, Ground/dimensions/capacities and competition. E-013 defers identities/Roblox owner explicitly from M0, not publishing permissions. | Pass |
| Executable documented offline model | BALANCE §§5/12–14; Production unchanged; runner, purchases, sessions, bounded queues, stalls/reconnect, promotion and natural/guaranteed streams. >=100000 per scenario/policy; source hashes/seeds/commands/censoring exported. Check + replay + sensitivity observed. | Pass |
| Actually verified Rojo/Studio round trip | Developer-confirmed edit/removal sync and server/client Play Output in history/setup-follow-up-2026-10-18.md. Existing bootstrap unchanged. No new assistant engine run, multiplayer or device claim. | Pass (prior user evidence) |
| Updated decision log and technical strategy | DECISIONS D-011–D-019/E-013; ARCHITECTURE D-017; TEST_PLAN P-001–P-012. Protocol is approved design; actual durability must pass M1 tests. | Pass for M0 |
| Asset/Studio responsibilities reconciled | ASSET_PIPELINE: functional responsibilities, source/restore workflow and future publication gate. Producer confirms no previous scenes; there is no authored scene to restore now. | Pass within E-013 scope |
| Concrete M1 plan, dependencies and acceptance | M1-01–M1-12 below; first slice isolated and explicit, no gameplay implemented in M0. | Pass |

**Disposition: M0 complete.** This closes specification/foundation, not gameplay,
persistence implementation, production readiness or authorization to start M1.
M0 has no remaining blocker under the producer's E-013 scope clarification.
Future asset permissions/restore, service failure tests, engine/device evidence,
real construction pacing and eight-plot load remain their named milestone gates.

### Sequential delivery evidence

| Step | Result | Commit / remote check |
| --- | --- | --- |
| 1 offline simulator | Runner before economy/discovery; reproducible outputs and checks, existing conversation documents included | `6e2802f`; [CI success](https://github.com/F94Olivera/gdd/actions/runs/39172535646) |
| 2 pacing/economy | D-014–D-016 and affected E10/control/sensitivity rerun; targets met | `d98f601`; [CI success](https://github.com/F94Olivera/gdd/actions/runs/39172893779) |
| 3 safe-save strategy | D-017 approved; official/source review and idempotent protocol; no service access | `fa541cb`; [CI success](https://github.com/F94Olivera/gdd/actions/runs/39173514986) |
| 4 scope/assets | D-018/D-019/E-013; original scene absence reported, source preservation plan, no upload | `a72f46b`; [CI success](https://github.com/F94Olivera/gdd/actions/runs/39173852158) |
| 5 closure/M1 | This exit-gate audit and dependency/acceptance plan; final commit/push/CI reported at handoff | Final handoff records actual commit/run; not inferred from local checks |

## M0.1 — Revalidación contra las fuentes originales (abierto, 2026-10-19)

**Origen:** el productor entregó los tres archivos originales (Master GDD, Claude Master
Prompt y Future Concepts Backlog) como fuente de verdad y pidió contrastarlos con el
trabajo de M0. Diagnóstico completo en
[history/source-contrast-2026-10-19.md](history/source-contrast-2026-10-19.md).
Los ítems M0 ya marcados no se borran: los mal interpretados quedan tachados arriba y
se corrigen aquí. M0.1 no reabre decisiones D-011–D-019 ni autoriza M1.

- [x] **M0.1-01** Confirmar con el productor la versión canónica del GDD: el archivo
  entregado es **v2.0** (9 páginas, 8 secciones); el repo cita «v2.1», «12-page» y el
  backlog cita «v2.1 section 11». Si existe v2.1, entregarlo y repetir el contraste;
  si no existe, corregir todas las referencias a «v2.1» en AGENTS/README/docs (Q-011).
  **Hecho 2026-10-20 (E-014):** no existe v2.1; el canónico es v2.0.
- [x] **M0.1-02** Decidir si los tres originales (o exportaciones de texto) entran al
  repo bajo `docs/reference/` con hash SHA-256 registrado. El propio GDD §8 pide
  «keep the GDD … in the repository»; E-005 dijo «no requerido», no «prohibido» (Q-013).
  **Hecho 2026-10-20 (E-014):** transcripciones textuales y SHA-256 completos en
  [reference/](reference/README.md); los binarios quedan fuera del repo.
- [x] **M0.1-03** Re-trazar D-004, D-010, GDD.md §8 (competición global: categorías
  *documents cleared* / *Intel earned* / *fastest first*, periodos UTC, semana lunes,
  refresco 5 min) y la premisa de D-019 al archivo canónico. Si no están en el
  original, re-etiquetarlos como propuesta del asistente y pedir ratificación o
  rechazo explícito mediante una D-0xx; no cambiar su estado por inferencia.
  **Hecho 2026-10-20:** D-021 los ratifica tal como están, con origen «productor».
- [x] **M0.1-04** Resolver «sector» vs «piso» y qué desbloquea la primera promoción.
  GDD v2.0 §5: «Promotion opens a new sector and machine eligibility»; GDD.md §5 hoy:
  «no additional sector or throughput is unlocked by the first promotion in M1».
  D-018 resolvió pisos (Ground/Upper/Basement), no el conteo de sectores que AGENTS §3
  lista como bloqueante (Q-012).
  **Hecho 2026-10-20 (D-022):** un sector al lanzamiento inicial; la primera promoción
  da clearance 1 y 1.25× sin abrir sector; los sectores llegan con la expansión.
- [x] **M0.1-05** Incorporar a `docs/GDD.md` los detalles de v2.0 omitidos, sin cambiar
  reglas: vault counter y tres posiciones de exhibición cosmética; texto overhead con
  rango y total; banners con cooldown/agregación; serial/timestamp solo como
  procedencia; «controls before lore, never require a store visit»; «owning more
  archives does not stack production buffs»; validación de configuración al arranque.
  **Hecho 2026-10-20:** agregados a GDD.md §§1, 4, 5, 7 citando la sección de v2.0.
- [ ] **M0.1-06** Inventariar herramientas de arte realmente disponibles y verificadas:
  Higgsfield queda descartado (D-020) y lo reemplaza Gemini Pro (NanoBanana); registrar
  estado de instalación de Blender y Substance; probar de forma supervisada el acceso
  del asistente a Gemini antes de afirmar que funciona (ver ASSET_PIPELINE).
  **Avance 2026-10-20 (E-015):** el productor informa que Alan ya trabaja con Blender y
  Substance en su máquina (no verificado por el asistente). Pendiente: prueba de Gemini.
- [ ] **M0.1-07** Cerrar la lista de plugins de Roblox Studio y quién los instala
  (ver README «Roblox Studio plugins»); confirmar instalación en la máquina del
  desarrollador y en la del segundo contribuidor.
  **Nota 2026-10-20 (E-015):** Alan no trabaja en el repo; basta con la máquina del
  productor. Pendiente hasta instalar Studio.
- [x] **M0.1-08** Citar los IDs F01–F19 del backlog en GDD.md §9 / Q-008 para que todo
  pedido futuro de alcance sea trazable al registro de ideas.
  **Hecho 2026-10-20:** GDD.md §9 y Q-008 citan los F-IDs y enlazan la transcripción.
- [x] **M0.1-09** Tras cerrar M0.1-01, actualizar `AGENTS.md` §1 («Refer to the original
  Master GDD v2.1»), README «Authority order» y los encabezados de ARCHITECTURE/BALANCE.
  **Hecho 2026-10-20:** también GDD.md, ROADMAP y la tabla D-001–D-010 de DECISIONS.
  Solo quedan citas a «v2.1» en registros históricos y en el texto original del backlog.

- [x] **M0.1-10** Base técnica re-verificada en esta estación el 2026-10-19 (el repo
  estaba recién clonado sin toolchain): Rokit 1.2.0 desde el release oficial (SHA-256
  `eb8e6b4f…a3ee`, igual al digest publicado), Git LFS 3.8.0 vía Homebrew, trust
  explícito de las seis fuentes y `rokit install` (Rojo 7.7.1, Wally 0.3.2, Selene
  0.32.0, StyLua 2.6.0, Luau LSP 1.70.1, Lune 0.11.0), `wally install`, plugin Rojo
  instalado en `~/Documents/Roblox/Plugins`, `lune run scripts/check.luau` **pasa**, y
  todas las corridas de BALANCE §§12–14 repetidas con resultados idénticos. Detalle en
  [contraste §10](history/source-contrast-2026-10-19.md). Cubre los ítems M0 de las
  líneas 24–25 (CLI); las líneas 22–23 (Studio) **no**: ver M0.1-12.
- [ ] **M0.1-12** Round trip Rojo/Studio en esta estación: Roblox Studio **no está
  instalado** en esta Mac (no existe `/Applications/RobloxStudio.app`), por lo que la
  conexión live, la sincronización de edición/borrado y el Output `[Server]/[Client]
  Bootstrap ready` siguen siendo evidencia del entorno anterior. Instalar Studio,
  conectar el plugin a `localhost:34872`, repetir las tres comprobaciones y registrarlas
  con fecha. Responsable: productor/desarrollador (requiere cuenta Roblox en Studio).

- [x] **M0.1-11** Seguimientos de la revisión de código del 2026-10-19 (ver
  [contraste §9](history/source-contrast-2026-10-19.md)); ninguno bloquea y ninguno
  cambia reglas: extender `selene` a `scripts/` y `tests/` con un std adecuado para
  Lune; mover el default de `economyScenarios.base()` a la promoción aprobada
  (100 000/50 000) o renombrar la base como hipótesis; reutilizar `BalanceMetrics`
  en `seededBalance.luau`; documentar que el coste de bahía no tiene número aprobado.
  Hacerlo solo tras M0.1-10, para poder correr `lune run scripts/check.luau` y las
  repeticiones byte a byte antes y después.
  **Hecho 2026-10-20:** los cuatro puntos y el comentario de «seven Lune tests»;
  resultados idénticos antes y después (detalle en BALANCE «Seguimiento de código M0.1-11»).

**Auditoría del exit gate M0.1 — 2026-10-20:** versión canónica v2.0 confirmada
(E-014); D-001–D-003 y D-005–D-009 trazan a v2.0, D-004/D-010 y GDD.md §8 a la
decisión del productor D-021; Q-011–Q-013 cerradas (E-014, D-022). **Aprobado.**
Quedan abiertos, sin bloquear: M0.1-06 (prueba de Gemini), M0.1-07 (plugins) y
M0.1-12 (round trip en Studio), todos a la espera de instalar Studio.

**Exit gate M0.1:** versión canónica confirmada, cada regla de `docs/GDD.md` y cada
D-001–D-010 trazable a una sección del original o a una decisión explícita del
productor, y Q-011–Q-013 cerradas. No requiere código ni Studio.

## M1 — First playable vertical slice

**Scope:** one Ground plot/floor and replenishing pile; free connected starter manual lane; an extractor, basic routable conveyor and processor; ordinary production + Intel; one genuine archive class; permanent count/title; interactive tutorial and demonstration; one voluntary promotion; robust persistence with recovery. Placeholder art is sufficient.

**Order and dependencies:** each row is a separate reviewable task, not permission
to implement all at once. Engineering owns code/integration; art owns editable
sources/exports; identities remain deferred per E-013. Preserve Git as code source.

| ID | Small deliverable | Depends on | Acceptance / verification |
| --- | --- | --- | --- |
| M1-01 ✅ 2026-10-20 | Minimal versioned definition catalog + explicit domain types for one line, rank and first promotion | New producer authorization to begin M1 | Stable IDs, approved D-011–D-019 values traced, no second sector/promotion; validate invalid prices/rates/IDs and rank boundaries in Lune. Define candidate buffers/tick as engineering experiments; no remotes, services or dependencies. |
| M1-02 ✅ 2026-10-20 | Pure authoritative accepted-unit accounting and bounded production budget | M1-01 | Separate provisional/confirmed work; fresh global unit cursor/fractions; combined manual+auto <=60/s, max2 maximum lines, stable ordering, no banking; conservation and variable-step/stall tests. Confirm gameplay step/buffers preserve desired throughput; do not copy h from the offline harness by habit. |
| M1-03 | Pure Ground graph and transactional edits | M1-02 | Straight/corner typed ports, 90deg rotation, bounds/overlap/cycle rejection; preserve old inventory and eligibility or reject atomically when bounded recovery cannot fit it. Lune invalid/edit/replay cases. |
| M1-04 | Pure D-017 transaction/cursor/lease/outbox state machine with fake store | M1-01/M1-02 | Immutable CAS candidates, no RNG in callback, permanent idempotence despite history eviction; inject failures P-001–P-010. No Roblox DataStore access in this task. |
| M1-05 | Native storage adapter in isolated test experience/store | M1-04; actual test owner/destination/permissions confirmed | Fail-closed loads, session fencing, bounded budgets/retries, exact commit ack and recovery. Execute service P-001–P-012, including lost responses and two servers. No production stores; any Studio API enablement needs its explicit test-only authorization. |
| M1-06 | Server natural-plan/discovery + atomic ordinary output/award/outbox | M1-02/M1-05 | Plan persisted before accepting units, p/H endpoints and distribution validated, one genuine +1, ordinary payment retained; no reveal before ack. Natural/guarantee crash/rejoin tests and demo exclusion. Do not declare durable grants from fake-store evidence alone. |
| M1-07 | Ground plot ownership + validated server build/manual intents | M1-03/M1-05 | One owner per plot, read-only visitors, finite/type/shape/ID/state/distance/rate/operation validation and serialized edits. Studio Play then >=2-client rejection/isolation checks. No client grants or luck. |
| M1-08 | Serialized Intel purchases/upgrades and one voluntary promotion | M1-06/M1-07 | Original incremental prices, physical belt segment count priced correctly; second-line bundle remains a harness shortcut. Full reset preview (no new sector, D-022), first promotion D-014, one charge/advance on replay, permanent cursor/counter/count retained. Re-measure purchase/promotion pacing with actual routing and save latency. |
| M1-09 | First placeholder handoff + canonical Studio-source restore | M1-01/M1-03; a real scene exists | Engineer specifies footprint/pivots/ports; artist retains originals/exports/provenance. ASSET_PIPELINE restore trial passes from clean workspace; source place versioned with narrow ignore/LFS changes only when needed. No polished art pack or upload by default. |
| M1-10 | Minimal PC/touch input, placement/status and confirmed/pending UI | M1-07/M1-08/M1-09 | Free hold-to-clear, rotate/cancel, readable invalid/blocked/saving states, bounded representative papers, reduced motion; Studio PC and touch emulator checks recorded honestly, named physical device checks before launch. |
| M1-11 | Skippable/resumable tutorial, demo and genuine reveal inbox | M1-06/M1-10 | Server-confirmed steps; proposed demo timing is evaluated explicitly before locking it, demo never affects Intel/rank/counter/stats; genuine tutorial find counts normally. Reveal/replay/ack never grants again. |
| M1-12 | End-to-end vertical-slice acceptance and recovery handoff | M1-05–M1-11 | New player clears/earns/automates/routes/finds/rejoins/promotes safely. T-001–T-015 and P-001–P-012 evidence as applicable; report exact engine/device/service runs and failures. Eight populated-plot performance remains M3, not claimed from M1. |

**M1-01 delivered (2026-10-20, E-016):** `src/shared/Catalog.luau` and `tests/catalog.luau`. Bays and buffer sizes stay out until they have approved numbers; tick 5 Hz and catch-up 2 s are recorded as GDD v2.0 defaults to measure, not approvals. Engine loading is unverified until Studio is installed. Next: M1-02, which needs buffer sizes first.

**M1-02 delivered (2026-10-20, E-017):** `src/server/ProductionLedger.luau` and `tests/productionLedger.luau`. Shared 60/s budget in stable ID order, 5 Hz sub-steps with 2 s capped catch-up, contiguous unit IDs with surviving fractions, and a 600-unit provisional bound that stops clearing until `confirm`. Sealing batches, leases and the outbox remain M1-04. Next: M1-03 (pure Ground graph and transactional edits).

**First next slice (original note):** M1-01 only, after explicit authorization. Add the smallest
catalog/types needed to represent the existing starter and upgrade definitions,
plus meaningful validation/rank-boundary tests. Do not scaffold services, choose a
framework, change Production/its contract or wire Roblox gameplay as part of that
first slice. Experimental tick/buffer choices must be verified before M1-02 accepts
them; test IDs above link to TEST_PLAN rather than duplicate its specifications.

**Before enabling real services or content:** confirm intended test universe/store,
Roblox owner/permissions and restoreability when a real asset/scene exists. These
are future prerequisites, not facts inferred from the GitHub repository owner.
M1's native adapter has a higher implementation/testing cost than using a wrapper;
its fail-closed and fencing contract must pass service failure injection before use.

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
