# Decisions, assumptions and open questions

**Purpose:** durable record of **producer-approved** decisions, with explicit status. A proposal is not approval. Never convert an assistant suggestion into a locked product rule without an actual producer response.

## Decision protocol

For each new decision record: `ID`, date, `Status` (`Accepted`, `Proposed`, `Open`, `Superseded`), context, alternatives considered, **producer approval** (quote/link when available), affected GDD section, implementation consequences and any migration/review trigger. Do not backdate producer approvals. If a future decision supersedes an older entry, add a new entry and mark the old ID superseded rather than deleting history.

## Approved product baseline from Master GDD v2.1 (2026-10-15)

These are **GDD-approved direction**, not new user approvals during this documentation pass.

| ID | Status | Decision / scope |
| --- | --- | --- |
| D-001 | Accepted (GDD v2.1) | One genuine Confidential Archive class. Equal credit +1 per genuine find; count has no finite cap. |
| D-002 | Accepted (GDD v2.1) | Discovery eligibility at **fresh clearing**, manual or automated, never gated by scanning/processing. |
| D-003 | Accepted (GDD v2.1) | Intel is the sole production currency; no Research currency, dossier requirement, duplicate conversion or archive-consuming unlocks. |
| D-004 | Accepted (GDD v2.1) | Lifetime archive count determines permanent title; independent production/earnings boards supplement competition. |
| D-005 | Accepted (GDD v2.1) | Eight independent bounded plots; PC and touch launch targets; Ground-only in M1. |
| D-006 | Accepted (GDD v2.1) | Bounded queues and backpressure; no re-rolling old material after editing, reconnect or promotion. |
| D-007 | Accepted (GDD v2.1) | Interactive, skippable, resumable tutorial with unranked Demonstration Archive. Hold-to-clear free. |
| D-008 | Accepted (GDD v2.1) | Voluntary promotions based on ordinary production + Intel; preserve archives and discovery counter. |
| D-009 | Accepted (GDD v2.1) | No combat, pets, theft, trading, offline finds, paid archives or pay-to-luck in launch scope. |
| D-010 | Accepted (GDD v2.1) | Core global boards: genuine archives, fresh papers cleared and production Intel earned, each over UTC daily/weekly/monthly/all-time; secondary boards gated separately. |

## Producer decisions — 2026-10-18

### D-011 — Fixed discovery probability with mandatory work guarantee

- Status: Accepted; resolves Q-001. Supersedes the original proposed H=300000 and the open pure-random/guarantee choice; preserves D-001/D-002/D-006/D-007.
- Producer approval: attached text supplied in this chat, “Decisión: implementar un sistema de probabilidad fija con garantía obligatoria”; “Probabilidad base: 0,001%”; “la garantía permanece en 200.000 documentos.” This entry preserves the decision without requiring the local attachment path.
- Rule: each newly accepted manual or automatic clearing has one opportunity. With 199999 consecutive failures, the next eligible document guarantees exactly one genuine archive; otherwise use p=0.00001. Any genuine find resets failures to zero. First and subsequent finds use identical rules; no shortening after unlucky streaks.
- Probability never changes with upgrades, promotion, sectors, archive count or production speed. Counter survives sessions, disconnects, layout edits and promotions. Demonstration Archive affects neither genuine count nor counter. No production, opportunities or counter progress while offline; blocked clearing generates none.
- Server owns RNG, counter and awards; commits must be consistent and idempotent across save failures/reconnects. Explain the work guarantee clearly; no hidden dynamic odds. Ordinary output/payment remains additional under existing rules.
- Alternatives: pure random and the prior 300000 proposal are superseded as launch policies; pure random may remain an explicitly labelled analytical control.
- Impact: GDD §3; BALANCE §§1/5; future Discovery and persistence contracts. Requires H−1/H, reset, demo exclusion, retention and durable retry tests. Q-007 still owns the unresolved durable protocol. No runtime or saved profiles changed here; future parameter changes require an explicit decision and versioned configuration/migration review.

### D-012 — Launch total throughput cap and reference factory

- Status: Accepted; resolves Q-003.
- Producer approval: same supplied attachment, “capacidad máxima sostenible de 60 documentos elegibles por segundo por jugador/fábrica para el lanzamiento”; “Este máximo ... comprende toda la extracción manual y automática combinada”.
- Rule: total manual + automatic eligible clearing is capped at 60 documents/s per player/factory, across every machine, floor and sector. At most two maximum-capacity extractor lines at launch; other configurations must also obey the global cap. Expose restrictions in construction rules and UI, with no hidden production/probability reductions.
- Approved reference: two independent lines, each extractor Tier 3=30/s, upgraded conveyor=50/s, processor Tier 2=40/s, sustained effective throughput=30/s if supply and bounded buffers permit. This approves these reference capacities, not prices, buffer sizes, extra sectors or arbitrary routing.
- Bottlenecks/backpressure govern real output; logical quantities remain separate from visual papers. Parameters/limits belong in versioned configuration when implemented.
- Alternatives: uncapped scaling and the exploratory 100/s launch candidate are superseded. Later expansions need an explicit decision/configuration revision.
- Impact: GDD §5; BALANCE §§2/5; architecture/build validation and eventual combined manual/automatic budget tests. Aggregate cap enforcement and allocation under simultaneous sources need an engineering contract before implementation. No change to Production or its two-buffer contract here.
- Economy: the attachment uses 1 Intel/processed unit for its 216000 Intel/hour steady-state calculation before multipliers; prices, expansion costs and promotion requirements remain provisional and require simulation. No inference of approved Q-004/Q-005/Q-006 values.
- Acceptance: use p=0.00001, H=200000 and total cap=60/s for M0/design and initial launch. Simulate progression, interrupted sessions, stalls and first-find distributions before claiming validated public pacing. This does not close M0 or authorize simulator/gameplay implementation in this documentation slice.

### D-013 — Primer extractor sustituye el clearing manual de la línea gratuita

- Date: 2026-10-18
- Status: Accepted; resuelve la parte starter de Q-010.
- Producer approval: respuesta explícita “Aprobar sustitución en la línea gratuita” a la propuesta de sustitución, conexión incluida a 1/s y mejoras posteriores de cinta/procesador.
- Rule: el primer extractor sustituye el clearing manual en esa línea; no suma ambos caudales. Usa la conexión gratuita a 1/s. Permite comprar mejoras posteriores de cinta/procesador.
- Impact: escenario económico offline y futuro starter M1. No aprueba el precio propuesto de 30 Intel para runtime, los demás precios, paquetes de segunda línea, rangos ni economía de promoción. No resuelve las restricciones adicionales de presentación/premios de competición pendientes en Q-010.
- Acceptance: antes/después de comprar el primer extractor el clearing nominal continúa a 1/s; coste solo con Intel disponible; el inventario conserva su elegibilidad y pago ordinario.

### D-014 — Economía inicial M1 y primera promoción

- Date: 2026-10-18
- Status: Accepted; resuelve economía inicial y parte M1 de Q-005.
- Producer approval: “Precios originales y promoción a 100.000 procesados +50.000 Intel”, en respuesta a las alternativas medidas del paso 2.
- Rule: precios incrementales originales de BALANCE §2 como candidato inicial M1; primera promoción voluntaria con 100000 unidades ordinarias procesadas de por vida, 50000 Intel disponibles y tutorial/equivalente. Reset a starter gratuito +100 Intel, multiplicador total 1.25.
- Alternatives: precios ×2/×5 y primera promoción 25k/10k no elegidos. E10 es el escenario de referencia aprobado; tasas/buffers/sesiones/demoras y paquete conectado de segunda línea conservan sus estados de autoridad propios.
- Retention: archivos/rango/contador de fallos y fracciones de elegibilidad acumuladas, tutorial, estadísticas y premios pendientes sobreviven. Preview explicita fee, Intel sobrante reseteado e inventario descartado antes del consentimiento.
- Impact: BALANCE §§2–3/14, GDD §§5–6, futura configuración M1 versionada. No autoriza gameplay ni segunda promoción (250k/100k y 1.50 permanecen fuera de M1).
- Acceptance: repetir E10 con 100000 semillas por política, validar asequibilidad sin suerte, conservación/reset/retención y pacing D-015; playtests pendientes.

### D-015 — Objetivos de pacing de referencia M0

- Date: 2026-10-18
- Status: Accepted; resuelve Q-002 para M0, sujeto a validar en playtests.
- Producer approval: “Aprobar estos objetivos de referencia; confirmar después con playtests.”
- Rule: primer archivo con progresión ideal y una promoción: mediana <=37 min y p90/p99 <=75 min **online** desde primera unidad elegible. Referencias sostenidas aceptadas: 60/s mediana ~19.3 min y p90/p99 ~55.6 min; 1/s manual mediana ~19.26 h y p90/p99 ~55.56 h.
- Limits: ausencia aumenta calendario; no promesa de hallazgo genuino en tutorial. La única garantía sigue siendo H por trabajo (D-011), nunca tiempo calendario. Sesiones/demoras del harness son hipótesis, no un SLA ni validación de retención real.
- Acceptance: volver a contrastar las cohortes afectadas contra estos objetivos, publicar censura/bandas y validar después construcción/input reales sin cambiar p/H por inferencia.

### D-016 — Títulos permanentes M1

- Date: 2026-10-18
- Status: Accepted; resuelve Q-004.
- Producer approval: “Aprobar umbrales y títulos propuestos.”
- Rule: 0 Trainee, 1 Archive Finder, 5 Investigator, 15 Senior Investigator, 40 Archive Specialist, 100 Director of Archives. Solo lifetime genuino; sin límite de hallazgos posterior a 100, sin consumo ni efecto de rankings periódicos.
- Impact: BALANCE §3 y GDD §3; futura configuración/UI M1. No premios de competición ni multiplicador de suerte.
- Acceptance: mostrar pacing medido en el escenario elegido E10, no atribuirle las mediciones de precios ×2 presentadas como alternativa. Tests de fronteras de rango se implementarán con la configuración M1.

## Engineering baseline for M0 (from existing validated repo setup)

| ID | Status | Decision / rationale |
| --- | --- | --- |
| E-001 | Accepted as current setup | Single Git monorepo, Rojo-managed Luau source, Roblox Studio for runtime/visuals, VS Code for editing. |
| E-002 | Accepted as current setup | `src/server`, `src/client`, `src/shared`; pinned Rokit toolchain and existing Lune/Selene/StyLua check. |
| E-003 | Accepted as current scope constraint | No external Node.js API, SQL database, Docker, compulsory dependency-injection framework or unrequested packages in M0. |
| E-004 | Accepted as team workflow | Small reviewable changes with checks; no unattended push, Studio publishing or asset upload. |

### E-005 — Original reference file retention

- Date: 2026-10-18
- Status: Accepted
- Context: the original Master GDD v2.1, companion Claude prompt and future-concepts workbook were supplied and inspected during the repository review.
- Producer decision: "olvidate de los archivos originales, no importa" in this chat, followed by authorization to continue the roadmap reconciliation.
- Impact: retaining, copying or linking the original files in the repository is not an M0 requirement. Continue with the working repository documentation and explicit producer decisions; no new gameplay or balance approval follows from supplying the files. The working GDD remains a summary, not a verbatim conversion.
- Alternatives: retain originals in the repository or document their external location; neither is required by the producer.
- Required review: incorporate identified summary omissions separately without changing product rules. No runtime or persistence migration.

### E-006 — First isolated M0 code increment

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "Implementemos primero un modelo offline mínimo de producción con tasas, buffers limitados y backpressure, con tests en Lune, sin integrarlo todavía al gameplay. Los valores de prueba no son balance aprobado."
- Impact: authorize the isolated continuous-quantity model and offline tests; keep M0 and all open product/balance choices unchanged. This does not authorize gameplay integration or offline player production.
- Implementation choice: fixed two-buffer line, downstream-first steps, explicit parameters and reported discarded catch-up time. These are experiment semantics, not approved gameplay timing.
- Alternatives deferred: arbitrary graphs, discrete unit eligibility, discovery, economy and full seeded balance scenarios.
- Required review: conservation, capacity/rate bounds, stalls/recovery, determinism and invalid inputs in Lune. No persistent state or migration.

### E-007 — Temporal convergence verification of the M0 model

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "verificar la convergencia del modelo al reducir el paso temporal, antes de ampliar escenarios o integrarlo al gameplay."
- Impact: three deterministic Lune fixtures (stable flow, bottleneck, blocking/recovery), shared horizon/events, conservation and buffer checks on every transition, measured error and documented tolerances. All values remain experimental fixtures.
- Implementation: compare step halvings with independent fluid solutions and two fine numerical references; retain the existing downstream-first model. Results and limits are in `BALANCE.md` section 8.
- Deferred: RNG, discoveries, economy, graphs and gameplay integration. No balance, gameplay tick or open product choice is approved. No M0/M1 gate changes.

### E-008 — Transport bottleneck verification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "verificar el modelo cuando el transporte es el cuello de botella, antes de ampliar topología o integrar gameplay."
- Impact: two deterministic Lune scenarios on the existing two-buffer line, independent analytic oracles, per-component and per-window refinement including transition increments. Results in `BALANCE.md` section 9.
- All numbers remain experimental fixtures. No gameplay, balance, RNG, economy, graph or milestone gate approval. Existing model semantics retained after verification.

### E-009 — Nonempty buffers and small downstream verification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "verificar la misma línea de dos buffers con estados iniciales no vacíos y capacidad downstream pequeña, antes de ampliar topología o integrar gameplay."
- Impact: two deterministic Lune fixtures, independent discrete/fluid oracles, component/window errors and conservation including initial inventory. Results and limitations in `BALANCE.md` section 10.
- Existing downstream-first contract retained; no defect found within this scope. Values are experimental, not approved balance. No RNG, discovery, economy, topology, dependencies or gameplay added; M0 remains open and product decisions remain pending.

### E-010 — Complete partial-buffer line verification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "Completá en una sola entrega la verificación pendiente de esta línea de dos buffers: estados inicialmente parciales, tasas de transporte y procesamiento distintas, llenado/vaciado interior y detención/recuperación."
- Impact: two grouped offline fixtures with independent analytic discrete/fluid oracles, component/window errors and conservation at every transition; results in `BALANCE.md` section 11. Existing model contract retained.
- All numbers remain experimental. No RNG, discoveries, economy, graphs, dependencies or gameplay authorized. M0 remains open; no milestone gate or pending product decision changes.

### E-011 — Documentary M0 reconciliation and simulator specification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "Prepará una especificación revisable del primer simulador offline de balance"; "sin implementar todavía el simulador"; "M0 sigue abierto".
- Impact: GDD §§4/8 reconcile available starter and competition rules; BALANCE §5 owns the reviewable specification and proposed deterministic first slice. No new balance or experiment semantics approved.
- Evidence: ROADMAP records the prior original-GDD review: free connected sorter/conveyor/processor at 1 unit/s and included first-extractor connection capacity. Exact connection scope and additional competition presentation/reward wording are unavailable (Q-010). E-005 removes file retention requirements, not this evidence gap.
- Alternatives: invent missing details or preserve their unresolved status; use the latter. No code, fixtures, contract, dependencies, gameplay or migration changes.
- Required review: documentation consistency and local checks; later implementation requires separate scope.

### E-012 — Autorización del simulador completo offline y cierre secuencial de M0

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: “Este pedido autoriza implementar el simulador offline necesario, incluyendo modelos experimentales de economía y descubrimiento. No autoriza trasladarlos al runtime.”
- Impact: supersede los límites de autorización de E-011 para implementar el harness; primero verificar runner determinista, después economía/descubrimiento con pruebas incrementales. D-011/D-012 permanecen aprobadas; los demás números siguen siendo hipótesis.
- Gates: completar/verificar cada uno de los cinco pasos antes del siguiente, commit y push normal a rama/remoto verificados y comprobar CI. Autorizados aquí; sin force-push, merge, publicación ni DataStores.
- Restrictions: no dependencias ni cambio de Production/contrato sin consulta previa. Resolver decisiones de producto con respuesta explícita; silencio no es aprobación.
- Current: runner y descubrimiento experimental verificados localmente; Q-010 starter resuelta por D-013; runner/economía/descubrimiento implementados y corridas documentadas en BALANCE §13. Sin aprobación implícita de precios, pacing, rangos o promoción.

## Open producer choices — do not silently implement

| ID | Status | Question / alternatives | Why it matters |
| --- | --- | --- | --- |
| Q-001 | **Resolved — D-011** | Fixed p=0.00001 with mandatory H=200000 work guarantee, identical first/subsequent rules. | Prior pure-random / H=300000 alternatives superseded |
| Q-002 | **Resolved — D-015** | Target median, p90 and p99 time-to-first archive; expected sustained waits at starter/mid/endgame; acceptable session length? | Early retention and avoiding trivial late-game rarity |
| Q-003 | **Resolved — D-012** | Total 60 eligible documents/s per player/factory, manual + automatic across all floors/sectors. | At most two maximum-capacity lines; visible global restriction |
| Q-004 | **Resolved — D-016** | Accept/revise rank thresholds and names (0/1/5/15/40/100)? | UI and long-run status progression |
| Q-005 | **M1 resolved — D-014** | First: 100k processed/50k Intel, grant100, total1.25. Second promotion remains unapproved/outside M1. | Economy, save resets and migrations |
| Q-006 | Open — before sectors M3 | How many launch sectors, what machinery capacities and available building footprint? | Asset and load budgets |
| Q-007 | Open — before persistence M1 | Which maintained data profile solution and durable grant protocol? | Preventing duplicate/lost rare awards |
| Q-008 | Open — before broader content | Optional assignments, manual tools, value-added paper, splitter/merger routing? | New gameplay mechanics require explicit scope authorization |
| Q-009 | Open — before asset production | Final art budgets, Roblox group ownership and publishing permissions? | Reproducibility and two-person work |
| Q-010 | Open — before affected implementation | Starter resolved by D-013: replacement on the free 1/s connection. What additional competition presentation/reward restrictions were intended? | The prior review identifies omissions without preserving their full wording; do not invent prizes or additive throughput. |

## Next producer discussion

D-014–D-016 resuelven las decisiones de economía inicial/pacing/rangos del paso 2.
Continuar con Q-007 (guardado) y luego Q-006/Q-009/Q-010 (alcance/assets), en ese
orden y con fuentes/evidencia. No reabrir probabilidades ni pedir otra aprobación
de las decisiones ya aceptadas. Playtests permanecen pendientes de M1.

## Decision entry template

```markdown
### D-017 — <short title>
- Date: YYYY-MM-DD
- Status: Proposed | Accepted | Superseded
- Context: ...
- Alternatives: ...
- Producer decision and reference: ...
- Impact: ...
- Required tests/migrations: ...
- Supersedes: ...
```
