# Find the Secret Archive — Game Design Document (working Markdown)

**Source:** *Find the Secret Archive — Master Game Design Document v2.1*, dated 2026-10-15.
**Status:** M0 working repository transcription/summary of the main product rules. This is **not** represented as a word-for-word replacement for the original 12-page GDD. Keep the original available and review this summary against it before declaring it the sole canonical source.
**Authority:** a later explicit, recorded producer decision supersedes the original GDD only in the area it names. Proposed numeric values are not automatically approved.

## 1. High concept and player promise

Players clear very large amounts of ordinary paperwork in an industrial archive warehouse. They begin by sorting by hand, earn **Intel** when ordinary documents complete secure processing, then automate clearing through increasingly capable factory lines. The long-term collectible goal is a genuine, rare **Confidential Archive**.

- **One archive class**, with unlimited potential finds. Every genuine server-awarded archive is worth exactly **+1** lifetime archive and all finds count equally.
- No rarity tiers, variants, duplicate penalties, individual collectible checklist, Research currency, dossier gates, archive-consuming upgrades or hidden throughput-based changes to discovery odds.
- Permanent player title/rank derives **only** from lifetime genuine archives; independent production leaderboards recognize different accomplishments.
- Readable stylized industrial realism, original assets and writing, R15 third-person avatars, eight independent plots, PC and touch for first release. Console release requires separate controller validation.
- No combat, pets, theft, trading, offline discoveries or paid archive rolls for launch.

**Design tension:** Archives must stay genuinely rare, while ordinary production, first automation, visible factory improvements, economic decisions and social presentation provide worthwhile moment-to-moment goals. Long passive waiting is not sufficient gameplay.

## 2. Core loop and discovery

```text
clear fresh paperwork -> get one discovery opportunity ->
ordinary output -> bounded conveyor route -> secure processing -> Intel ->
upgrade extractor / processor / belt / bay -> clear more fresh paperwork
```

- Manual sorter and automated extractor use the **same eligibility rule** per newly cleared logical unit. Roll **once at accepted clearing/extraction**, not during downstream scanning.
- Reveal a manual find at the pile or an automated find in a **protected discovery tray**. An awarded archive is additional to, not a replacement for, the ordinary unit and its potential Intel income.
- Scanner/processor classifies/processes ordinary output; **it is not an archive-discovery gate**.
- Prototype finds are server-sampled during clearing; visual paper layers recede to expose the awarded object. **Do not** imply literal pre-hidden world coordinates or advantageous pile corners. Physical hidden placement is deferred.
- When a buffer fills, upstream production eventually stalls. No clearing means no new search opportunities. Reconfiguring belts, retrying, reconnecting, changing sectors or resuming simulation never rerolls material already accepted.
- Each plot has replenishing supply. No global depletion, no shared resource competition, and visitors have **read-only** factory access. The plot owner owns their machine discoveries.

## 3. Rarity, guarantees and permanent rank

The original GDD proposes a fixed probability **p = 0.00001 = 0.001% per eligible unit** regardless of manual/automated clearing or sector. The alternative proposed protection is a **work-based guarantee at H = 300,000** consecutive failed eligible units: if chosen, the 300,000th gets an archive. These are **M0 tuning proposals, not an approved choice between pure random and guarantee**. No implementation should silently pick one.

If the guarantee is approved, the failure counter survives disconnects, sectors, promotions and layout edits. It resets on a genuine find and is unaffected by tutorial demonstrations. Guarantee-triggered genuine finds count the same as random ones. The public UI must accurately explain enabled odds/protection. See [BALANCE.md](BALANCE.md) for simulations and assumptions.

**Proposed, unapproved permanent titles:** 0 Trainee; 1 Archive Finder; 5 Investigator; 15 Senior Investigator; 40 Archive Specialist; 100 Director of Archives. No terminal collectible count; players above the highest title continue accumulating archives. Do not sell permanent rank or archive credit.

## 4. Interactive tutorial and reveal

Tutorial is contextual, short, skippable, resumable after disconnect and replayable from Help. Server-confirmed steps: (1) clear starter pile, (2) process documents and earn Intel, (3) purchase first extractor, (4) inspect clearly labeled **Demonstration Archive**, (5) understand true archive count and next rank, (6) choose a useful throughput upgrade and connect it.

Proposed tutorial mechanism: free connected starter lane; after **30 valid starter units and the first extractor purchase**, grant **one** demonstration. Demonstration does **not** grant Intel, lifetime archives, leaderboard progress or a guarantee-counter reset/advance. Genuine finds during the tutorial are genuine and count normally. Input hold-to-repeat is free for everyone, constrained to the same server-approved manual rate.

Proposed UX targets: first interaction within 20 seconds; first automation within two minutes; demonstration within five minutes (must be measured). Show the genuine reveal **after the durability protocol confirms it**. It may have a skippable three-second inspection; ending or replaying animation never changes ownership. Retry pending commits without falsely promising a completed save. A discovery inbox batches reveals so the UI never blocks production.

Accessible presentation includes touch-friendly targets, high contrast, reduced motion, sound controls, concise text, and muted banners for visitors. Do not use fake near misses or false scarcity countdowns.

## 5. Factory construction, upgrades and economy

**Initial layout concept:** eight **100×100 stud** independent plot envelopes around a compact hub. Start with a **16×16 build grid**, **4 studs per cell**. Fixed production bays contain machines in designated slots; conveyors are player-routed between typed ports on the grid. M1 uses **Ground only**. Planned maximum for launch is Ground, Upper and Basement, initially **24 studs floor-to-floor**, pending asset/camera validation.

- M1 supports straight and corner belts with 90-degree rotation, valid footprint preview, and explicit connection status; no splitters/merges.
- Reject graph cycles, invalid ports, occupied grid positions, outside-plot placement, blocked lanes and unsafe removals.
- Editing affected routes pauses their flow. Preserve in-flight inventory on moves. Removing belts returns units to bounded recovery; reject edits without safe recovery capacity.
- Selling belts refunds the recorded purchase price only once; machines are not initially sellable.
- Show machine states: working, no supply, output full, disconnected. Distinguish **rated** from **measured** throughput.

**Intel** is the only gameplay currency. Securely processed ordinary material initially earns **1 Intel per unit**. Intel buys equipment, capacity upgrades, bays/floors and voluntary promotion fees. An archive find must never require buying another random roll. Ordinary work and production milestones must carry progression even during unlucky archive streaks.

Original GDD proposed starter values (see [BALANCE.md](BALANCE.md) for review status): free manual lane at 1 unit/s; first extractor 30 Intel at 1 unit/s; basic processor 60 Intel at 10 units/s; extractor tier 2 upgrade 120 Intel at 10 units/s; extractor tier 3 upgrade 600 Intel at 30 units/s; processor tier 2 upgrade 350 Intel at 40 units/s; belt segment 5 Intel at 10 units/s with an upgrade costing 25 to 50 units/s. Treat these as incremental prices and hypotheses, not approved balance.

## 6. Voluntary clearance promotion

Promotions unlock sector/equipment eligibility based on **production + spendable Intel**, never a required rare find. Original proposed eligibility: first promotion at **25,000 processed lifetime ordinary units + 10,000 Intel + tutorial-equivalent validated automation**; second at **250,000 lifetime units + 100,000 Intel**. These thresholds require simulations and playtests.

Proposed multipliers: first clearance **+25% ordinary Intel per output**; second **+50% total**, formula `1 + 0.25 × clearanceIndex`. This is **not** an archive probability boost. Show explicit confirmation and full reset preview; no forced or automatic promotion.

At promotion: consume the approved fee, set spendable Intel to **100 rebuild grant**, restore the free starter lane, reset purchased factory layout/bays/floors; clear in-flight ordinary output only after confirmation. Retain lifetime archives, permanent rank, discovery failure counter, pending genuine rewards, cumulative production, tutorial, sector eligibility/clearance and cosmetics/preferences. Recorded promotional operation IDs must prevent double charge or double advancement.

## 7. Runtime and saved data

Server owns RNG, logical rates, finite bounded queues, inventory, Intel, purchase validation, placement/topology, permanent archive credit, rank and authoritative stats. Clients own input, preview, visuals, accessibility, sounds and UI only. Prototype simulation targets **5 Hz**, capped catch-up **2 seconds** per update and limited client paper animation (**240 global local-view cap; 120 owner; 30 per nearby visitor plot**). These need device measurements. One paper **visual** is not one paper **economic unit**.

Profile design must account for session locking, schema and balance versions, migrations, durable genuine grants, bounded operation identity/reconciliation, safe errors, retries, release/shutdown save, tutorial flags, machine/belt layouts, queues/fractions and preferences. Loading failure must leave the player in a retry state, not a blank playable profile that can overwrite saves.

A Lua in-memory update is **not** proof that a reward is durable. Define the exact commit boundary, handle pending rewards, and verify disconnect/retry recovery before introducing a production economy. Remote inputs must be checked on server for data type, finite numbers, size, permissions, ownership, distances, state, bounds, prerequisites and rate limits.

## 8. Global competition

Permanent **archive title** remains lifetime-count-only. Independently display leaderboards over **UTC daily, Monday-start weekly, calendar monthly and all-time** windows.

| Metric | Authoritative score rule | Planned scope |
| --- | --- | --- |
| Archives found | +1 for each genuine server-awarded find; no demo/admin grants | Core launch, all four windows |
| Documents cleared | Each fresh eligible clearing event exactly once | Core launch, all four windows |
| Intel earned | Production-derived Intel only; exclude refunds/rebuild/compensation/admin grants | Core launch, all four windows |
| Documents processed | Each original secure processed unit once; no transformation recount | Secondary, after reliability gate |
| Fastest first archive | Cumulative **online** time from first accepted manual/automated clearing to first genuine award | Secondary, all-time initially |

Rank/title never changes because a daily leaderboard resets. Tie scores share standing; display order may be stable without implying superiority. Show category/period selectors, top scores, user's confirmed score, UTC reset countdown, last refresh and staleness. Do not invent exact position outside returned top list. Proposed refresh target **five minutes**, pending budget checks. Delayed grants count toward **server occurrence** windows, not processing/saving time; retain idempotent event identity.

M1 records authoritative local stats and event metadata; global periodic core boards are gated on M3 reliability and must work before M4 public launch. Absolute-score publication, reconciliation and throttling are required. A leaderboard outage must not stall factories or saving. Fastest-first is a luck-influenced record, not a pure skill measure; demonstrate exclusion and no restart after promotion.

## 9. Release and excluded scope

Milestones M0–M4 and exit gates are maintained in [ROADMAP.md](ROADMAP.md). The first playable M1 includes **one floor, one pile, manual clear, extractor, conveyor routing, processor, one genuine archive class, tutorial/demo, rank, one promotion and persistence**. Use placeholders first.

Launch monetization direction: optional previewable **cosmetics** (machine skins, plot decorations, vault presentations) without mechanics/stat buffs. No paid real-money offers in M0/prototype. No paid archives, odds, rankings, direct Intel sales or production multipliers at launch. Any future alternative requires an explicit producer decision and new review of official Roblox rules.

Reference footage can motivate **readable feedback**, compact upgrades, production metrics and placement previews. It does not authorize copying a competitor's assets, exact layout, graphics, scripting, economy or supposedly hidden rules. Defer power/water networks, complex recipes, huge tech trees, splitters, new manual tools, assignment quests and value-added paper product until specifically approved.

## 10. Decisions requiring producer approval (M0)

See `DECISIONS.md`; key blockers are: pure randomness versus disclosed hard guarantee; target time-to-first/ongoing genuine discovery at each throughput tier; maximum launch throughput; finalized permanent rank thresholds/titles; voluntary promotion fees and sectors; and a persistence strategy with auditable durable awards. All numerical proposals in this working GDD remain hypotheses until explicitly accepted.
