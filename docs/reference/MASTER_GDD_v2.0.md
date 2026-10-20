<!-- Transcripción textual generada a partir del original; no editar a mano. Ver docs/reference/README.md. -->

# Find the Secret Archive

*Master Game Design Document | Version 2.0 | 15 October 2026*

Players clear enormous quantities of ordinary paperwork to uncover rare Confidential Archives. They begin by hand, earn Intel from processed paperwork, and build machinery that searches more material. Every genuine archive has the same collectible value and increases the lifetime archive total by exactly one.

### Design authority

The companion Claude Master Prompt version governs development process; this GDD governs game behavior. Later explicit producer decisions take precedence when recorded in the decision log. Numeric values and proposed defaults are tuning hypotheses until validated; they are not measured outcomes.

### Core rules

| System | Version 2 baseline |
| --- | --- |
| Collectible | One Confidential Archive class. No rarity tiers, variants, weighted scoring, duplicate penalties, or unique-file checklist. |
| Objective | Collect as many genuine archives as possible. There is no finite global stock or final collectible cap. |
| Ranking | Lifetime genuine finds determine rank. Every archive contributes equally; resets preserve the total. |
| Discovery | Valid clearing reveals archives in the pile or a protected machine tray. Scanner completion is not the discovery gate. |
| Economy | Intel funds equipment and expansion. Research and duplicate conversion are removed. |
| Progression | Production milestones and voluntary clearance promotions. Mandatory dossiers and random-file gates are removed. |

### Scope and identity

A hybrid factory tycoon in a fictional industrial archive warehouse. Use readable stylized industrial realism, R15 avatars, and a third-person camera. Target eight independent player plots. PC and touch are first-release platforms; controller support must pass before console release. No combat, pets, theft, trading, offline discoveries, or paid archive rolls at launch.

The long-term attraction is the next rare archive. Frequent equipment goals, visible pile clearing, production improvements, and social displays must keep the intervening search enjoyable. Long waits alone are not evidence of a good game.

## 1 Search and production

### The player loop

Clear ordinary paperwork, move it through a processing line, earn Intel, and reinvest in greater search capacity. A rare Confidential Archive is exposed during valid clearing. The find is credited automatically and then presented for an optional inspection animation. It never needs another roll, machine, or payment to become a collectible.

### Manual and automated discovery

Manual sorting and authorized automated extractors use the same discovery rule per eligible unit. Each newly cleared logical unit is sampled once, at extraction from the supply. A hand search reveals the archive at the pile; an automated extractor reveals it in a protected discovery tray. Scanners classify ordinary output for income; they do not determine whether an archive exists.

Prototype choice: discoveries are sampled during clearing rather than pre-placed at hidden world positions. Visual layers clear to expose a server-awarded archive. Do not imply that searching a particular corner improves odds. Physical hidden positions are a deferred mechanic requiring a separate producer decision.

### Capacity and income

Supply pile → manual sorter or extractor → bounded output buffer → player-routed conveyor → processor → secure output. One accepted clearing unit creates one ordinary output unit and one discovery opportunity. Archive rewards are additional collectibles and do not replace ordinary output. Intel is awarded once when ordinary output completes secure processing.

An extractor can clear only when its output buffer has capacity. Full downstream queues eventually halt clearing and new discovery opportunities. Manual sorting obeys the same storage limits and a capped server-approved input rate. Disconnecting or editing a belt never creates another opportunity from material already cleared.

### Pile behavior and ownership

Each plot has its own replenishing supply, presented as distinct visual layers and batches. Empty layers refresh without charging Intel or rerolling previously credited work. There is no shared resource competition and no global depletion. A visitor cannot clear, collect, edit, or change the owner’s odds. Archive ownership belongs to the plot owner, including finds made by their machinery.

### Simulation and visual limits

Simulate logical rates, queues, and eligibility on the server, initially at 5 Hz with elapsed time and fractional accumulators. Use deterministic graph order and bounded transfers. Catch-up after a stall is capped at two seconds per update; discarded elapsed production time is logged. No offline production in version 2 launch scope.

Clients animate representative papers, not one object per economic unit. Start with a 240 moving-paper client cap, including up to 120 on the owner plot and 30 per nearby visitor plot. Reduce distant detail before reducing authoritative simulation accuracy. These budgets require measurement.

## 2 Rarity and lifetime ranking

### One archive and one score

Each genuine server-awarded Confidential Archive increments lifetimeArchives by one in the same profile transaction as its reward ID and discovery state. All finds count equally, including a disclosed hard-guarantee find if the proposed guarantee is retained. There is no duplicate concept. An optional serial number or timestamp is provenance only and never changes value, odds, or rank.

### Provisional discovery model

Use one fixed probability across manual and automated clearing and all launch sectors: p = 0.00001 per eligible unit, or 0.001%. Never secretly lower p as production rises. Proposed protection: after 299,999 consecutive unsuccessful eligible units, unit 300,000 guarantees a find. Any genuine archive resets that counter. Preserve the counter across disconnects, sectors, edits, and promotion. Training does not affect it.

The hard guarantee is a proposed balance default, not a confirmed preference about pure randomness. Review it with the producer during M0. Display the actual enabled rule. Without it, expected units are 1/p. With threshold H, expected units are [1 − (1 − p)^H] / p, approximately 95,021 for the proposed values. Probability of at least one random success within n units is 1 − (1 − p)^n before the hard threshold.

| Sustained clearing | Mean gap with proposed guarantee | Maximum gap from zero |
| --- | --- | --- |
| 1 unit per second | About 26.4 hours | 83.3 hours |
| 10 units per second | About 2.64 hours | 8.33 hours |
| 30 units per second | About 52.8 minutes | 2.78 hours |
| 100 units per second | About 15.8 minutes | 50 minutes |

These are illustrative sustained-rate calculations, not session forecasts. Starter throughput must rise quickly: new players should not spend hours at one unit per second. Launch capacity must be bounded and tested so that late equipment does not make the only archive commonplace. If the model misses the desired experience, change the published balance before release; do not introduce hidden throughput penalties or new rarity tiers.

### Ranks and displays

| Lifetime archives | Proposed title |
| --- | --- |
| 0 | Trainee |
| 1 | Archive Finder |
| 5 | Investigator |
| 15 | Senior Investigator |
| 40 | Archive Specialist |
| 100 | Director of Archives |

Titles are configurable milestones, not caps. Counts continue above the highest title. Equal counts share standing. Show lifetime count, title, and next threshold. Start with a server board; defer cross-server rankings. Never sell ranked finds or titles.

## 3 Interactive tutorial and player experience

### Learn by playing

Use short contextual steps inside normal play. Highlight one target at a time and advance only after the server confirms the action. Support tap, hold, touch, and later controller input. Holding repeats at the same permitted rate for everyone. Instructions can be skipped, resumed after reconnect, and replayed from Help.

| Step | Player action and feedback |
| --- | --- |
| 1 Search | Clear paperwork at the starter pile; show the material disappearing and output entering the free lane. |
| 2 Earn | Process ordinary output; show Intel increasing and explain that paperwork pays for equipment. |
| 3 Automate | Buy the first extractor; immediately show autonomous clearing and its rated output. |
| 4 Discover | Expose a clearly labeled Demonstration Archive through the tutorial sequence; inspect it in the tray. |
| 5 Understand rank | Show the real archive counter and next title. Explain that demonstration finds do not increase rank. |
| 6 Choose a goal | Highlight a useful throughput upgrade, let the player complete a simple connection, then release guidance. |

### Training grant and pacing

Provide a free connected starter sorter, conveyor, and processor. After 30 valid starter clearing units and the first extractor purchase, award one Demonstration Archive. Save its tutorial flag with the grant. It is not a genuine Confidential Archive, never increments lifetimeArchives, grants no Intel, never enters leaderboards, and does not reset or advance discovery guarantees. Natural discoveries remain possible during the tutorial and count normally.

Initial targets: first interaction within 20 seconds, first automation within two minutes, and the demonstration within five minutes. Measure these targets rather than claiming them as results. Introduce controls before lore, and never require a store visit. Promotion and later rank thresholds are explained when relevant, not in an opening lecture.

### Reveal and collection

Once a genuine award is durably committed, show the archive emerging from the searched layer or machine tray, play a short cue, and update the permanent vault count. The player may inspect a skippable three-second reveal. Credit never depends on clicking the object or finishing the animation. If saving fails, retain a pending state and retry; never show an uncommitted award as safely saved.

Batch multiple pending reveals into an inbox without blocking search or editing. Replays are labeled and cannot award again. No disappearing finds, fake near misses, or false scarcity countdowns. Provide reduced motion, sound controls, large touch targets, high contrast, and concise text.

### Social presentation

Each plot has a vault counter and three cosmetic display positions showing the same archive class. Displays are representative; they do not require separate variants or one physical model per owned archive. Overhead text shows the owner’s rank and lifetime count. Genuine-find banners use cooldowns and aggregate bursts. Visitors are read-only, and players can mute announcements.

## 4 World construction and economy

### Bounded hybrid building

Reserve eight 100 by 100 stud plot envelopes around a compact hub. Begin with a 16 by 16 build grid at four studs per cell, leaving space for access lanes. Launch maximum: Ground, Upper, and Basement, initially 24 studs floor-to-floor subject to camera and asset testing. The prototype uses Ground only.

Purchase fixed production bays. Machines use designated slots; players route conveyors between ports on the grid. Allow straight and corner belts with 90-degree rotation. Reject cycles, occupied cells, invalid ports, out-of-bounds footprints, and blocked access lanes. Disconnected machines are allowed but show a clear inactive reason. No splitters or merges in M1; later merges require explicit bounded two-input ports.

Editing pauses affected flow. Moving equipment preserves inventory. Removing a belt returns its units to a bounded recovery queue; reject the edit if no safe capacity exists. Selling conveyors refunds their recorded Intel price once. Machines cannot be sold initially. Cross-floor transfer uses authored ports and bounded buffers after the prototype.

### One currency

Intel comes from ordinary processed output. It buys machinery, throughput upgrades, bays, floors, and clearance fees. No Research currency or archive consumption. Owning more archives does not stack uncapped production buffs. Production-led progress must remain useful during unlucky discovery streaks.

| Starter item | Intel price | Proposed effect |
| --- | --- | --- |
| Free starter lane | 0 | Manual clearing and processing at 1 unit per second |
| Extractor | 30 | Automatic clearing at 1 unit per second |
| Basic processor | 60 | Raises processing capacity to 10 units per second |
| Extractor tier 2 | 120 | Raises extractor capacity to 10 units per second |
| Extractor tier 3 | 600 | Raises extractor capacity to 30 units per second |
| Processor tier 2 | 350 | Raises processing capacity to 40 units per second |
| Conveyor segment | 5 | 10 units per second; upgrade costs 25 for 50 per second |

Prices are incremental per tier and provisional. The starter bay includes enough belt capacity for its first extractor; no paid connection is required to earn. Secure output pays one Intel per ordinary unit initially. Later sectors may increase Intel value and equipment capacity, but every eligible unit retains the same archive probability. Intel bonuses do not create extra search units.

### Active play and supply

Manual sorting remains optional after automation. Occasional optional analysis tasks may award modest Intel, never extra ranked archives or hidden luck. Supply and ordinary upgrades do not require a rare find. Unlock new sectors through production, so discovery scarcity cannot strand the player’s entire factory progression.

## 5 Clearance and saved progress

### Voluntary promotion

Proposed first promotion: 25,000 lifetime ordinary units processed, 10,000 spendable Intel, and a completed automation tutorial or equivalent validated actions. Proposed second: 250,000 lifetime units and 100,000 spendable Intel. Lifetime archive count is never a promotion requirement. These thresholds need simulated and real playtests.

Promotion opens a new sector and machine eligibility. The first grants +25% Intel per output unit; the second grants a total +50%, using 1 + 0.25 × clearanceIndex. It does not directly multiply archive probability. Show the full reset preview and require an explicit confirmation. On promotion, consume the fee, reset Intel to a 100 Intel rebuild grant, and restore the free starter lane. No automatic promotion or forced reset.

| State | Promotion | Disconnect and rejoin |
| --- | --- | --- |
| Lifetime archives and rank | Retain | Retain durable total |
| Discovery failure counter | Retain unchanged | Retain |
| Pending genuine rewards | Retain and finish safely | Reconcile without duplicate grant |
| Intel | Reset to 100 rebuild grant | Retain |
| Machines and belt layout | Reset to free starter lane | Retain |
| Bays and floors purchased | Reset; unlock eligibility retained | Retain |
| Clearance and sector eligibility | Retain and advance | Retain |
| Lifetime production and tutorial | Retain | Retain |
| Cosmetics and preferences | Retain | Retain |
| In-flight ordinary output | Clear after confirmation | Save bounded queues and fractions |

### Data integrity

Serialize profile mutations. A promotion operation ID prevents repeated grants and repeated advancement. Archive grants, lifetime total, failure counter, and operation identity must agree after recovery. Define the durable save boundary explicitly: updating an in-memory table alone is not a durable commit. Never promise completion of an archive award before the selected persistence strategy confirms it.

Use session locking, schema migrations, budget-aware autosaves, release and shutdown saves, bounded retry backoff, and separate test stores. A failed profile load produces a retry state, never a playable blank profile that can overwrite existing progress. Do not keep an unlimited receipt or archive-event log inside one profile; design bounded recent history and durable reconciliation before launch.

### Returning players

Show saved archive total, the next equipment goal, and the limiting production stage. No offline production or archive rolls at launch. Resume tutorial steps and pending presentations. Never reroll old search batches on reconnect, server restart, promotion, or sector change.

## 6 Architecture tools and updates

### Minimal and explicit architecture

| Server responsibility | Owned behavior |
| --- | --- |
| Player data | Session ownership, durable mutation strategy, migration, retry and recovery |
| Plot and build | Ownership, bounds, topology, inventory-preserving edit transactions |
| Production | Logical queues, extraction, processing, fractional units and backpressure |
| Discovery | One-time clearing eligibility, server RNG, guarantee, atomic archive grant |
| Progression | Intel purchases, rank derivation, sector access and voluntary promotion |
| Commerce and telemetry | Verified cosmetics, idempotent receipts, versioned metrics and errors |

Client controllers own input, placement previews, UI, pile visuals, audio, reveal playback, and tutorial hints. The server derives costs, rates, prerequisites, and rewards. Validate remote types, finite numbers, IDs, ownership, state, bounds, distance where relevant, and rate limits. Reject forged counts, NaN, infinity, repeated operation IDs, and parallel spending races.

### Tool roles

Roblox Studio is required for engine validation. VS Code, Git, and Rojo are the recommended file-based engineering workflow. Blender is recommended for custom modular machines; Substance is optional for selective materials. Higgsfield is optional for concepts and selected visual assets. Wally is optional for verified packages; pin dependencies and tool versions.

Use typed Luau with clear service and controller boundaries. Verify current package maintenance and source before adoption. Evaluate maintained profile infrastructure such as ProfileStore; do not default to ProfileService or archived Knit. Do not select a framework solely for prestige. Claude must verify actual integrations before claiming control of Studio or art tools.

### Deep modularity with practical limits

Stable versioned definitions cover machines, capacities, footprints, ports, prices, sectors, rank thresholds, cosmetics, and discovery configuration. New machines using supported behavior should primarily require data and assets. New routing, extraction, or transformation mechanics require code and tests. Keep balance rules separate from UI and visuals.

Validate config references, capacities, probability ranges, prerequisite reachability, and migration mappings before startup. Preserve earned archive totals through updates. Never quietly reset guarantees or lower odds to hide a bug. Document old-to-new IDs, compensation for removed purchases, and changes to publicly disclosed rules.

### Asset handoff

Maintain consistent scale, pivots, port locations, collision, texture budgets, and levels of detail. Use placeholders until the core loop passes. Build original warehouse assets and writing; do not copy another game’s assets, scripts, layout, or distinctive presentation.

## 7 Monetization validation and milestones

### Cosmetic first

Prototype and closed balance tests have no real-money products. Launch candidates are previewable machine skins, decorative plot treatments, and cosmetic display arrangements. Cosmetics do not change capacity, archive odds, count, or title. Hold-to-sort is free. Paid archives, luck, ranked grants, direct Intel sales, and paid production multipliers are outside launch scope.

Any future paid item affecting production or discovery needs a recorded producer decision and a fresh review of official platform rules, including indirect random-reward effects. Verify entitlements server-side; grant developer products idempotently using receipt identity and acknowledge only after safe fulfillment. Do not trust client completion events.

### Functional acceptance

Test manual and automated finds without a scanner gate; one eligibility credit per cleared unit; full-buffer backpressure; inventory conservation through edits; count and rank persistence; excluded training grants; exact guarantee boundary; no double grant after retries; simultaneous purchases; promotion retention; failed loads; reconnect; and touch placement with rotate and cancel. A natural find during tutorial must count normally.

### Balance and performance

Use an offline simulator with fixed seeds and at least 100,000 synthetic player runs per balance revision. Report median, p90, and p99 first-find waits and rank progress under evolving throughput, stalled lines, short sessions, and late equipment. Compare the proposed hard guarantee with pure randomness. Check that the only archive remains scarce at maximum intended capacity; do not tune for tiers that no longer exist.

Provisional load target: eight populated plots and 60 logical nodes per plot; p95 production update below 10 ms; at least 30 FPS on a named midrange phone and 60 FPS on a named desktop baseline. Record devices, settings, content, and network. These are targets, not results. Measure tutorial exits, first automation, find intervals, idle bottlenecks, promotion acceptance, and return cohorts without claiming guaranteed retention.

| Milestone | Deliverable and exit gate |
| --- | --- |
| M0 Specification | Verify tools; resolve blocking rules; record assumptions; simulate rarity and economy. |
| M1 First playable | One floor, one pile, manual sorting, extractor, routed belts, processor, tutorial, one archive class, rank, one promotion and persistence. Complete loop passes with placeholders. |
| M2 Usability | Touch controls, bottleneck UI, reveal inbox, accessibility and inventory-safe edits pass. |
| M3 Closed alpha | Up to three sectors and floors; eight-plot load, recovery and progression trials pass. |
| M4 Launch | Polished original assets, tutorial, cosmetic commerce, device checks and rollback plan pass. |

## 8 Decisions and Claude handoff

### Confirmed product direction

One rare Confidential Archive class; equal value per genuine find; lifetime-count ranks; clearing reveals archives; manual and automated discovery; a short interactive tutorial; modular production architecture; bounded hybrid plots; and no mandatory dossier or duplicate economy. The archive remains the rare reward throughout the game, rather than introducing rarer versions later.

### Proposed defaults to review during M0

Review the exact probability and hard-guarantee policy, acceptable early and late find intervals, maximum search capacity, rank thresholds and titles, promotion costs, and sector count. The GDD supplies concrete prototype defaults so work is reviewable. Claude must explain their consequences and obtain producer decisions on meaningful departures before implementation.

The most consequential open balance choice is pure randomness versus a disclosed work-based guarantee. It must not be silently decided by a coding assistant. Similarly, decide whether eventual late-game throughput is bounded by launch equipment or expanded only after scarcity simulations. No hidden odds reduction is permitted.

### Focused discovery questions

Claude should ask as many specific questions as needed across focused rounds, normally no more than five related questions in one round. Resolve game identity and current-milestone blockers first. Explain the recommendation, alternatives, and player impact. Propose routine technical defaults, record answers, avoid repeat questions, and continue independent authorized work while awaiting a decision.

### Use the paired documents

Attach this GDD and use Claude Master Prompt version 2.0 in the actual coding workspace. Keep the GDD, decision log, implementation plan, and balance configuration in the repository. Require an environment audit before scaffolding, then implement small reviewable milestones. Never generate the whole launch game as a single unverified code dump.

### Verification references

Verify these primary sources at implementation time. They support tooling and platform checks; the gameplay and numerical defaults above are design decisions, not claims established by these sources.

Roblox external tools: https://create.roblox.com/docs/projects/external-tools

Roblox art software: https://create.roblox.com/docs/art/overview-dcc

Roblox client and server security: https://create.roblox.com/docs/scripting/security/client-server-boundary

Roblox paid random items: https://create.roblox.com/docs/production/monetization/paid-random-items

ProfileStore: https://madstudioroblox.github.io/ProfileStore/

Maintenance notices: https://github.com/MadStudioRoblox/ProfileService and https://github.com/Sleitnick/Knit
