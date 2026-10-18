# Test plan and quality gates

**Current state:** specifications only. Existing `lune run scripts/check.luau` was reported to pass for the bootstrap repo on 2026-10-18; none of the gameplay tests below are claimed to exist or pass. Keep `tests/README.md` if already present and compatible.

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
| T-003 | Pure-random/guarantee boundaries | Fixed-seed cases at H-1/H, reset on genuine find, no demo counter effect; **only if guarantee approved** | M0 model, M1 engine |
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

## Deterministic test examples

1. **Exactly once:** accept a fresh unit, generate its search eligibility, simulate connectivity loss, retry same operation ID. Assert one search event and at most one genuine reward.
2. **Capacity stall:** extractor speed 10/s with a downstream capacity of 0. After the intermediate output buffer reaches capacity, assert eligible-clearing count does not advance.
3. **Surgical editing:** remove a belt holding units. If bounded recovery has capacity, conserve all units; otherwise reject the edit atomically, preserving original graph and quantities.
4. **Rarity:** for an approved H guarantee, set failure counter to H-1 and accept one eligible unit without natural success; assert one awarded archive, then failure counter 0. A demo must not change it.
5. **Promotion:** seed a saved player with nonzero archives, discovery counter, layout and Intel; approve operation once; replay operation; assert one fee, one clearance, retained permanent state and no new fake awards.
6. **Bad requests:** fuzz finite numbers, IDs, unexpected Instances, wrong ownership, rate bursts and repeated nonce/operation IDs. Assert no mutation on rejected request.
7. **Leaderboard:** delayed committed find just before midnight UTC still belongs to the original day. Publishing it twice cannot increment a period score twice. Equal scores tie. Test Monday/month-end/year-end rollover.

## Reporting requirements

Test reports should record **date, commit, tool/version, test/seed, inputs, expected output, actual result, pass/fail, logs, and unresolved manual tasks**. For device reports also record model, graphics, FPS method, online mode, scene contents and network. For a performance number include sample size and percentile method.

**CI must never be reported as green because a local actionlint check passes.** Studio and physical-device checks require actual execution and evidence. A unit test cannot certify Roblox DataStore behavior by itself.

## Prioritized failures (block release)

Lost or duplicated genuine archives; profile overwrite on load failure; ability to fake Intel or permanent rank; non-conserving edits; double purchase/promote; inaccessible/no-rate-limit client paths; unbounded queues/tick spikes; unreconciled leaderboard credit for demo/admin sources; cosmetic receipt double-fulfillment. Any of these blocks the relevant milestone regardless of visual polish.
