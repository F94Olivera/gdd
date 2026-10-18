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

## Open producer choices — do not silently implement

| ID | Status | Question / alternatives | Why it matters |
| --- | --- | --- | --- |
| Q-001 | **Open — M0 blocker** | Pure random `p=0.00001` versus same odds plus public hard guarantee at `H=300000`, or revised validated values? | Fairness, disclosure, durable counter and real waits |
| Q-002 | **Open — M0 blocker** | Target median, p90 and p99 time-to-first archive; expected sustained waits at starter/mid/endgame; acceptable session length? | Early retention and avoiding trivial late-game rarity |
| Q-003 | **Open — M0 blocker** | Launch maximum sustainable eligible-unit throughput per player/plot? | One archive must remain rare, without hidden nerfs |
| Q-004 | Open — before progression tuning | Accept/revise rank thresholds and names (0/1/5/15/40/100)? | UI and long-run status progression |
| Q-005 | Open — before promotion M1 | Approve 25k/250k production requirements, 10k/100k Intel fees, 100 rebuild grant and 25% increments? | Economy, save resets and migrations |
| Q-006 | Open — before sectors M3 | How many launch sectors, what machinery capacities and available building footprint? | Asset and load budgets |
| Q-007 | Open — before persistence M1 | Which maintained data profile solution and durable grant protocol? | Preventing duplicate/lost rare awards |
| Q-008 | Open — before broader content | Optional assignments, manual tools, value-added paper, splitter/merger routing? | New gameplay mechanics require explicit scope authorization |
| Q-009 | Open — before asset production | Final art budgets, Roblox group ownership and publishing permissions? | Reproducibility and two-person work |

## Next producer discussion (focused round)

Ask about Q-001, Q-002 and Q-003 **together** after presenting an actual seeded balance simulation. Record the producer's exact choices here. Do not imply that the GDD's illustrative table is a measured player-session result. Then address rank/promotion tuning; handle technology defaults without repetitive permission questions where possible.

## Decision entry template

```markdown
### D-011 — <short title>
- Date: YYYY-MM-DD
- Status: Proposed | Accepted | Superseded
- Context: ...
- Alternatives: ...
- Producer decision and reference: ...
- Impact: ...
- Required tests/migrations: ...
- Supersedes: ...
```
