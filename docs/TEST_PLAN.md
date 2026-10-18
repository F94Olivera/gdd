# Test plan and quality gates

**Current state:** M0 offline production/balance models and tests are implemented;
results and commands are in BALANCE §13. Gameplay, engine, persistence and device
acceptance below remain pending; offline tests do not certify those layers.

## Test layers

| Layer | Runs in | Suitable for | Not proof of |
| --- | --- | --- | --- |
| Formatting / lint / Rojo build | CLI, Lune and CI | Syntax, project structure, deterministic smoke checks | Roblox runtime behavior |
| Pure unit tests / seeded simulations | Lune | Rate math, queue invariants, graph validity, rank formulas, RNG models | Physics, prompts, networking and DataStores |
| Integration tests | Roblox Studio Play | Services, UI, remotes, actual engine API and bootstrap wiring | Device performance or live multi-server behavior |
| Multiplayer / adversarial | Studio with >=2 clients, targeted harness | Plot ownership, races, spoofing, replication and contention | Live-scale distributed DataStore reliability |
| Persistence / failure-injection | Separate test experience and stores | Save durability, idempotency, disconnect/reconnect, throttles, migration | Production readiness without rollout tests |
| Device / production-like | Named PC and phones with recorded settings | FPS, touch, content fidelity and large plots | General results for unnamed devices |

## Acceptance matrix

| ID | Requirement | Minimum passing evidence | Earliest gate |
| --- | --- | --- | --- |
| T-001 | Clear fresh unit only once | Unit ID/eligibility idempotent despite replay, reconnect or repeated request | M1 |
| T-002 | Manual and automated discovery | Both can find without a scanner/processor gate | M1 |
| T-003 | Approved discovery guarantee D-011 | p=0.00001, H=200000; 199999 misses → next unit guarantees exactly +1; same first/later rules, reset on any genuine find, retention, no demo effect | M0 model, M1 engine |
| T-004 | Full-buffer backpressure | Full processor/route stops upstream clearing; no searches while stopped | M1 |
| T-005 | Inventory conservation | Move, remove, invalid edit and disconnected belt preserve ordinary units; no duplicate search | M1 |
| T-006 | Graph constraints | Invalid cycles, ports, overlaps, bounds, blocked lanes denied safely | M1 |
| T-007 | Exploit input protection | Reject forged Intel, archives, rank, prices, invalid numbers, NaN, infinity, overlarge tables, replay IDs | M1 |
| T-008 | Parallel purchases/promotions | Concurrent requests cannot double spend/grant or bypass requirements | M1 |
| T-009 | Durable genuine grant | Disconnect/retry at each boundary causes neither silent loss nor duplicated reward | M1 blocker |
| T-010 | Failed profile load | Explicit retry state; never overwrite existing profile with blank | M1 |
| T-011 | Save/rejoin/promotion | Retain archives, counter, tutorial, stats and pending grants; reset factory/Intel only according to rules | M1 |
| T-012 | Demonstration exclusion | Does not change rank, genuine awards, leaderboard totals, Intel or guarantee counter | M1 |
| T-013 | Tutorial and reveal | Skip/resume/replay without added grants; genuine find during tutorial still counts | M1/M2 |
| T-014 | Two-player plot isolation | Visitors can't clear, build, collect rewards or affect probabilities | M1 |
| T-015 | Touch building | Tap/hold/rotate/cancel and comprehensible invalid placement feedback | M1/M2 |
| T-016 | Server performance | Eight plots × 60 nodes, measured p95 tick under 10 ms or documented variance | M3 |
| T-017 | Client performance | Measured 30 FPS named midrange phone / 60 FPS named desktop or investigated variance | M3/M4 |
| T-018 | UTC boundaries | Day/week/month rollover, event occurrence timestamp, delayed commits, timezone handling | M3 |
| T-019 | Global leaderboard integrity | Absolute scores, no duplicate/stale overwrite, ties, stale cache, recovery from throttling | M3/M4 |
| T-020 | Cosmetic commerce | Verified ownership and idempotent receipt grant, including retries | M4 if monetization exists |

## Approved launch cap acceptance (D-012)

Future tests must enforce total manual + automatic accepted clearing <=60/s across
all lines/floors/sectors, deny a third maximum-capacity extractor line, and verify
that alternative configurations obey the same cap. Cover simultaneous sources,
block/recovery and variable steps under an explicit shared-budget contract. Two
reference lines (30/50/40 each) target 60/s sustained when unblocked; startup and
buffer discretization must be reported separately. Verify visible construction/UI
limits and unchanged p under throughput/upgrades. The offline harness tests the shared budget and declared maximum-line limit;
server construction/UI and engine tests remain unimplemented. Eight plots ×60 nodes
is a separate load target.

## M0 balance harness specification

Current two-buffer verification is documented in BALANCE §§8–11 and
`tests/README.md`; no further neighboring fixtures are required absent a concrete
defect. The sole specification for the proposed runner, scenarios, reproducibility,
metrics and acceptance is [BALANCE §5](BALANCE.md#5-simulation-harness-required-during-m0).
The authorized offline harness is implemented and measured in BALANCE §13, with
runner/discovery/economy tests included in the check. T-003 has offline boundary
evidence; T-001–T-006 engine/build/idempotency acceptance remains pending for M1.
No new Studio/device evidence. Seeded cohorts and sensitivity are separate commands,
not the fast CI check. Product sign-off remains required.

## Deterministic test examples

1. **Exactly once:** accept a fresh unit, generate its search eligibility, simulate connectivity loss, retry same operation ID. Assert one search event and at most one genuine reward.
2. **Capacity stall:** extractor speed 10/s with a downstream capacity of 0. After the intermediate output buffer reaches capacity, assert eligible-clearing count does not advance.
3. **Surgical editing:** remove a belt holding units. If bounded recovery has capacity, conserve all units; otherwise reject the edit atomically, preserving original graph and quantities.
4. **Rarity:** under D-011, set failure counter to 199999 and accept the next eligible unit; assert one awarded archive, then failure counter 0. A demo must not change it.
5. **Promotion:** seed a saved player with nonzero archives, discovery counter, layout and Intel; approve operation once; replay operation; assert one fee, one clearance, retained permanent state and no new fake awards.
6. **Bad requests:** fuzz finite numbers, IDs, unexpected Instances, wrong ownership, rate bursts and repeated nonce/operation IDs. Assert no mutation on rejected request.
7. **Leaderboard:** delayed committed find just before midnight UTC still belongs to the original day. Publishing it twice cannot increment a period score twice. Equal scores tie. Test Monday/month-end/year-end rollover.

## Guardado: aceptación verificable para M1 (diseño M0 paso 3)

Contrato único en [ARCHITECTURE: Persistence and durable awards](ARCHITECTURE.md#persistence-and-durable-awards).
**Todos pendientes de ejecutar**; estos casos no afirman uso de DataStores ni pruebas
pasadas. Primero fake store determinista con fallo por frontera, después experiencia
Roblox/stores de prueba separados. No producción ni Studio API access en este paso.

| ID | Fallo/ejercicio | Aceptación |
| --- | --- | --- |
| P-001 | Lectura falla, perfil malformado o esquema futuro | 0 perfiles blancos jugables, 0 sobrescrituras; nil genuino crea perfil una vez |
| P-002 | Dos cargas simultáneas y lease expirado | Un owner; fence viejo no escribe aunque continúe corriendo; clock skew produce stop seguro |
| P-003 | Callback invocado repetidamente/conflicto CAS | Mismo candidato/resultado, sin RNG/efectos dentro; seq anterior exacta o rechazo seguro |
| P-004 | Crash antes/durante/después de commit de hallazgo | Count durable base o base+1 según commit; jamás +2; salida ordinaria incluida y pagable una vez |
| P-005 | Backend guarda y respuesta se pierde | Read sin caché/retry CAS reconoce mismo mutationId/awardId; mismo contador y +1 único |
| P-006 | Crash antes de guardar plan natural siguiente | Reencuentra mismo hallazgo/ID desde plan anterior; ninguna unidad posterior fue aceptada sin plan durable; misma distribución p/H |
| P-007 | Rejoin, promoción, edición y fracciones de lote | Cursor/fallos/plan/fracción/count retenidos; no nuevo roll para IDs antiguos; ausencia 0 producción |
| P-008 | Commit sin reveal; reveal sin ack; ack se pierde | Outbox reenvía ID, replay visual no suma; cursor sigue evitando duplicados tras retirar entrada |
| P-009 | Outbox32 llena, buffers llenos y servicio caído | Límites respetados; pausa visible antes de overflow; no drop silencioso ni tiempo bancado |
| P-010 | Compra/promoción concurrente y replay tras mucho tiempo | Una fee/reset/avance; high-water durable rechaza antiguas aunque evictó historial detallado; preview correcto |
| P-011 | Throttling, 8 perfiles activos y cierre abrupto | Orden serial, budgets/tamaño medidos, backoff sin cola ilimitada, ningún “guardado” falso; rejoin reconcilia |
| P-012 | Migrations/rollback/corrupt backup y aislamiento | Archivos/IDs/counter no disminuyen por migración; restore controlado preserva awards; test jamás escribe namespace/universo prod |

Para cada frontera registrar checkpoint anterior/candidato/backend tras crash,
awardId/mutationId/epoch/seq y cantidades esperadas/observadas. Repetir ambas
políticas de evento: natural y garantía H; incluir demo sin entrada genuina.
Gates: no M1 discovery jugable hasta P-001–P-010; no despliegue con persistencia hasta
P-011/P-012 en servicios de prueba. UI debe distinguir provisional/confirmado y
pacing debe medirse con latencia real de la estrategia, ausente del simulador M0.

## Reporting requirements

Test reports should record **date, commit, tool/version, test/seed, inputs, expected output, actual result, pass/fail, logs, and unresolved manual tasks**. For device reports also record model, graphics, FPS method, online mode, scene contents and network. For a performance number include sample size and percentile method.

**CI must never be reported as green because a local actionlint check passes.** Studio and physical-device checks require actual execution and evidence. A unit test cannot certify Roblox DataStore behavior by itself.

## Prioritized failures (block release)

Lost or duplicated genuine archives; profile overwrite on load failure; ability to fake Intel or permanent rank; non-conserving edits; double purchase/promote; inaccessible/no-rate-limit client paths; unbounded queues/tick spikes; unreconciled leaderboard credit for demo/admin sources; cosmetic receipt double-fulfillment. Any of these blocks the relevant milestone regardless of visual polish.
