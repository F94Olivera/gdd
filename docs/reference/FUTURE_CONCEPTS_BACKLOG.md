<!-- Transcripción textual generada a partir del original; no editar a mano. Ver docs/reference/README.md. -->

# Find the Secret Archive — Future Concepts Backlog

## Feature backlog

| Find the Secret Archive future concepts |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Proposals only. The GDD and Claude prompt remain authoritative and unchanged. |  |  |  |  |  |  |  |  |  |
| Filter by review stage, recommendation or decision. Complexity is relative, not a time or cost quote. |  |  |  |  |  |  |  |  |  |
| ID | Potential feature | Suggested review stage | Recommendation | Complexity estimate | Player benefit | Add only when | Dependencies | Safeguards | Producer decision |
| F01 | Small manual-tool progression | Closed alpha experiment | Review first | Medium | Make early clearing feel more capable and physical. | A small tool test improves early play without delaying automation. | Stable manual clearing, touch input and tool animation. | Same archive odds per eligible unit; server-owned rates. | Proposed |
| F02 | Optional production assignments | Closed alpha experiment | Review first | Medium | Give short goals between rare archive finds. | Players understand production and voluntarily complete trial orders. | Authoritative processing counts and Intel rewards. | No archive consumption or ranked-find grants; no deadline penalty. | Proposed |
| F03 | One value-added paper product | Closed alpha experiment | Review first | Medium | Create a choice between raw throughput and Intel value. | One optional recipe adds an understandable choice without clogging the line. | Processing lineage, buffers and explainable capacity UI. | No second archive roll; no recounting the same input on boards. | Proposed |
| F04 | Small branching upgrade tree | After core loop validation | Review first | Medium | Let players choose an upgrade goal. | Players understand current upgrades and ask for meaningful alternatives. | Stable machine definitions, prerequisites and readable touch UI. | Start with a few branches; make previewed effects explicit. | Proposed |
| F05 | Blueprint save and rebuild | First post-launch update | Consider later | High | Reduce repetitive rebuilding after promotion. | Rebuild friction appears in playtests and players want to reuse layouts. | Stable layout schema, migrations, build transactions and pricing. | Blueprints grant no free machines; validate unlocks and cost at placement. | Proposed |
| F06 | Undo and redo for construction | After build reliability passes | Consider later | High | Make conveyor experimentation less punishing. | Build errors are a recurring usability problem after basic previews improve. | Reversible transactions and inventory conservation. | Cannot repeat refunds, duplicate material or reroll a discovery. | Proposed |
| F07 | Group copy and move | First post-launch update | Consider later | High | Make larger factories easier to organize. | Large layouts cause repetitive placement work on both PC and touch. | Stable footprints, ports, transaction rules and cost previews. | Validate the entire group; no partial charges or duplicate inventory. | Proposed |
| F08 | Configurable splitters and priority routing | After basic routing validation | Consider later | High | Allocate material between income and processing routes. | Simple lines are clear and branching adds a real production decision. | Acyclic graph validation, bounded queues and flow diagnostics. | Preserve one eligibility credit per unit; limit routing complexity. | Proposed |
| F09 | Visually distinct paper batches | After pile visuals are proven | Consider later | Medium | Make clearing successive batches feel different. | Players enjoy pile clearing but find repeated visuals monotonous. | Reliable replenishment and saved clearing state. | Visual theme does not imply different archive tiers or hidden luck. | Proposed |
| F10 | Additional sectors beyond launch scope | Content updates after launch | Consider later | Medium | Add fresh environments and supported machine goals. | Existing sectors are enjoyable and the content pipeline handles updates safely. | Versioned content definitions, asset budgets and migrations. | One archive class; publish balance changes; preserve earned totals. | Proposed |
| F11 | Discovery journal | First post-launch update | Consider later | Medium | Give each genuine find a personal history. | Players revisit displays and want to remember memorable discoveries. | Bounded history, timestamps and durable reward identity. | Dates and serials are provenance only; each archive remains worth one. | Proposed |
| F12 | Opt-in community exhibit | After social displays are used | Consider later | Medium | Celebrate player factories and archive milestones. | Players use visits and displays and want shared showcases. | Read-only plot visits, visibility preferences and moderation. | No theft, visitor interference or paid ranking advantage. | Proposed |
| F13 | Equal-start factory challenge | Later experimental release | Explore cautiously | High | Offer a competition where equipment starts equal. | Periodic boards work reliably and players ask for fair-start contests. | Separate challenge state, timer, ruleset and validated scores. | Separate from lifetime rank; no changes to the main collection. | Proposed |
| F14 | Cosmetic competition rewards | After leaderboard integrity is proven | Explore cautiously | Medium | Recognize accomplishments with display options. | Scoring, ties, eligibility and exploit correction have passed review. | Reliable finalization, moderation and reward delivery. | No archive grants, exclusive production power or spending-based rarity. | Proposed |
| F15 | Warehouse cosmetic events | Content updates after launch | Consider later | Medium | Refresh the warehouse atmosphere without changing the core loop. | Cosmetic pipeline is sustainable and players value customization. | Theme assets, mobile performance and clear entitlements. | No expiring archives, forced attendance or disguised odds changes. | Proposed |
| F16 | Electrical power networks | Later experimental release | Explore cautiously | Very high | Add a possible capacity-allocation and layout decision. | An isolated prototype is enjoyable and players can explain why a machine stalls. | Graph infrastructure, load allocation, clear status UI and device headroom. | Test a simple circuit first; no maintenance chores or paid energy. | Proposed |
| F17 | Water or coolant networks | Only after a successful power experiment | Low priority | Very high | Support a distinct optional production interaction. | It adds a decision power and buffers do not already provide. | Accepted utility design, fluid rules, readable ports and performance budget. | Skip if it merely duplicates electricity; never required for basic searching. | Proposed |
| F18 | Large upgrade-tree expansion | After a small tree is validated | Explore cautiously | High | Extend proven choices for experienced players. | Small branches are used, understood and support distinct strategies. | Upgrade telemetry, balance simulation and scalable mobile navigation. | Do not add hundreds of filler upgrades or erase owned upgrades. | Proposed |
| F19 | Offline Intel production | Later experimental release | Explore cautiously | High | Give returning players bounded ordinary-currency progress. | Players request it and balance plus leaderboard treatment can be explained. | Trusted elapsed time, caps, recovery and competition-policy review. | No offline archive rolls; decide score eligibility before implementation. | Proposed |

## Decision guide

| How to use this feature backlog |  |
| --- | --- |
| Rule | Meaning |
| Authority | This workbook is a separate idea register. It changes neither the Master GDD v2.1 nor the Claude Master Prompt v2.1. |
| Starting status | Every listed item is Proposed. A suggestion or later review stage is not permission to implement. |
| Producer decision | Edit the amber decision cells on Feature backlog. Only the producer can authorize a prototype or release scope. |
| Promotion to scope | Before implementation, record the decision, define acceptance criteria, and explicitly revise the implementation scope or GDD. |
| Core design | One rare Confidential Archive class. Every genuine find adds one to lifetime total. No tier, variant or duplicate-scoring system. |
| Baseline work | Tutorial, saving, security, performance, machine feedback, existing launch floors/sectors and approved core leaderboards remain baseline work, not optional backlog items. |
| Review first | Consider a small trial after the core loop works. This is a recommendation, not an approved sprint or delivery date. |
| Consider later | Review when the stated player need appears and dependencies are ready. |
| Explore cautiously | High scope or balance risk. Use an isolated prototype and allow rejection. |
| Low priority | No commitment. Skip unless it solves a distinct demonstrated problem. |
| Complexity estimates | Relative qualitative judgments based on system interactions. They are not developer estimates, costs or promised schedules. |
| Stage definitions | Closed alpha follows a working prototype. Post-launch and experimental stages are conditional review points, not deadlines. |
| Evaluation | For a candidate, define the problem, test a small version, observe use and confusion, check mobile performance and saving, then approve, revise or reject. |
| Evidence needed | Useful gates may come from observed playtests, player feedback and telemetry. No success rates or retention claims are assumed. |
| Claude instruction | Read as optional ideas. Do not implement any Proposed, Investigate or Deferred feature. A prototype approval authorizes only that prototype. |
| Origin | Producer discussions and the uploaded gameplay references. Timed visual findings are recorded in Master GDD v2.1 section 11. Other entries are proposed workflow or content extensions. |

