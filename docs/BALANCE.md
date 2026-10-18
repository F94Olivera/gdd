# Balance and simulation specification

**Version:** working proposal from Master GDD v2.1 (2026-10-15).
**Approval state:** numeric values are **NOT locked**. This file is a design input and measurement log, **not executable configuration**. When gameplay is implemented, a reviewed versioned Luau config in `src/shared/config/` should become the runtime source for approved numbers; keep this document synchronized.

## 1. Discovery proposal and alternative

| Parameter | GDD proposed value | Status |
| --- | --- | --- |
| Probability per eligible **fresh clearing** unit | `p = 0.00001` (0.001%, one in 100,000 on average without protection) | **Proposed** |
| Manual vs machine vs sectors | Same `p` | Product invariant (exact `p` proposed) |
| Guaranteed find after continuous misses | `H = 300000` consecutive failed eligible units | **Open**: guarantee policy not yet approved |
| Scope of guarantee counter if enabled | Survives disconnects, sector changes, edit and promotion | Product invariant **if enabled** |
| Counter behavior | A genuine find resets; demonstration has no effect | Product invariant **if enabled** |
| Success when downstream full | No eligible clearing, hence no new roll | Product invariant |
| Ranked reward | Exactly +1 genuine archive, regardless of random or approved guarantee | Product invariant |

For **pure random**, expected clearing units between finds = `1 / p` = **100,000**. For a hard cap at H successful eligible units, the expectation is:

```text
E[units to next find] = (1 - (1 - p)^H) / p
```

For p=1e-5 and H=300000, **E ≈ 95,021** clearing units. If the cap is enabled, the **maximum** gap in eligible units is 300,000; this is a work-based guarantee, **not** a promise about wall-clock time when lines stall or players log off.

| Sustained eligible throughput | Mean time with proposed guarantee | Hard cap from zero failures |
| --- | --- | --- |
| 1 unit/sec | ~26.4 hours | ~83.3 hours |
| 10 units/sec | ~2.64 hours | ~8.33 hours |
| 30 units/sec | ~52.8 minutes | ~2.78 hours |
| 100 units/sec | ~15.8 minutes | ~50 minutes |

These are mathematical steady-rate examples from the GDD, **not player-session observations**. Early throughput is expected to increase rapidly. Do not conceal slow pacing with fake rarity rewards, hidden throughput nerfs, or an additional archive rarity tier.

## 2. Economy proposal

**Base ordinary income**: secure processing pays one Intel per original ordinary output unit before approved clearance multipliers. A genuine archive is additional and does not change this ordinary payment.

| Upgrade / item | Proposed incremental Intel cost | Proposed capacity/effect |
| --- | ---: | --- |
| Free starter lane | 0 | 1 manual cleared unit/sec with connected output |
| Extractor | 30 | 1 automatically cleared unit/sec |
| Basic processor | 60 | 10 processed units/sec |
| Extractor tier 2 | 120 | Increases extractor to 10 units/sec |
| Extractor tier 3 | 600 | Increases extractor to 30 units/sec |
| Processor tier 2 | 350 | Increases processor to 40 units/sec |
| Belt segment | 5 | 10 transported units/sec |
| Belt upgrade | 25 | Increases belt to 50 units/sec |

Prices and rates are **unapproved tuning hypotheses**. Treat belt cost as per segment; machine upgrades as incremental prices. No off-by-one rounding exploits or extra archive-roll units from faster processors.

## 3. Progression proposal

| Clearance level | Proposed requirements | Ordinary Intel multiplier | Reset and retention |
| --- | --- | --- | --- |
| 0 | Starter | 1.00× | No reset |
| 1 | 25,000 lifetime ordinary units processed, 10,000 spendable Intel, completed tutorial/equivalent | 1.25× | Reset spendable Intel to 100 and restore free lane; preserve archive total/counter |
| 2 | 250,000 lifetime ordinary units processed, 100,000 spendable Intel | 1.50× total | Same voluntary reset policy |

Multiplier formula proposed: `1 + 0.25 * clearanceIndex`. Do not add another currency or use lifetime archive count as an unlock requirement. Promotions are confirmed explicitly by the player and idempotent on server.

| Lifetime archives | Proposed permanent title |
| ---: | --- |
| 0 | Trainee |
| 1 | Archive Finder |
| 5 | Investigator |
| 15 | Senior Investigator |
| 40 | Archive Specialist |
| 100 | Director of Archives |

These are milestone titles, not archive count caps. **All rank thresholds and titles are open for producer confirmation.**

## 4. Load, tick and visual budgets

| Parameter | Proposed value | Caveat |
| --- | --- | --- |
| Server production updates | 5 Hz | Use elapsed-time fractional accumulators |
| Max catch-up time per update | 2 seconds | Record discarded elapsed time |
| Maximum moving paper visuals per client | 240 | Representative visuals, not one per unit |
| Owner plot visual sub-budget | 120 | Device-dependent |
| Nearby other plot sub-budget | 30 per plot | Adaptive LOD |
| Production graph load target | 8 plots × 60 nodes | Requires realistic playtest |
| p95 production tick | under 10 ms | Not benchmarked |
| Mobile / desktop | 30 / 60 FPS | Must name and record tested devices |

## 5. Simulation harness required during M0

Build a deterministic seeded Lune simulation that accepts at least: `p`, optional `H`, clearing rates over time, queue capacities, machine graph topology, upgrade timeline, player session windows, stalls/reconnects, promotion events and planned endgame throughput. Tests must model real **eligible units**; do not simply assume full peak rate without backpressure.

For **each** candidate balance version, report >= **100,000 synthetic player runs** (GDD target), random seeds/model version and:

- Median / p90 / p99 wall-clock and **active** time to first genuine find; later gaps and permanent rank progress.
- Tail distributions for pure random vs capped-guarantee; worst-case eligible units and real-time exposure.
- First automation and ability to afford the next useful purchase without luck.
- Short-session, disconnected line, blocked output, reconnect, promotion and late-capacity scenarios.
- Honest scarcity at the maximum proposed launch throughput, without fabricated server nerfs.

Store outputs/parameters in a reproducible, non-secret artifact and summarize accepted changes here. Don't mark numerical values as verified until those tests have run.

## 6. Revision log (initial)

| Revision | Date | Source | Result |
| --- | --- | --- | --- |
| `GDD-2.1-proposal` | 2026-10-15 | Original Master GDD v2.1 | Hypotheses transcribed; no simulation conducted as part of this documentation task |

## 7. Producer sign-off required

Resolve `Q-001`, `Q-002`, `Q-003`, `Q-004` and `Q-005` in `DECISIONS.md` before claiming the numbers above are locked or building durable discovery/promotion data around them.
