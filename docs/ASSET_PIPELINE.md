# Art and asset pipeline — two-person collaboration

**State:** M0 source/ownership plan reconciled under D-018/E-013. Producer confirms
starting from zero, without previous scenes. No art sources/LFS entries found in
repo; generated build/game.rbxlx is not an authored scene. No export/upload/publish
or restore test is claimed. Final texture/geometry budgets follow first real M1
placeholder handoff and measured PC/touch constraints, before final art production.

## Goals and ownership

E-013 explicitly defers names/aliases and Roblox account/group ownership from M0.
The following are functional responsibilities, not invented personal assignments.
Before future asset publication, record actual creator/account/group, authorized
publisher, destination and verified permissions. Nothing in M0 authorizes upload.


- Engineering: Roblox Studio integration, Rojo mappings, gameplay contracts, collision/performance testing, stable game IDs and asset manifest.
- Art: Blender models and source scenes, Adobe Substance materials when justified, original textures, optimization and authored previews. ~~Higgsfield~~ Gemini Pro (NanoBanana) or other concept tools are optional and not runtime requirements (D-020, 2026-10-19).

> **Producer instruction (2026-10-19, verbatim):** *Scratch Higgsfield as one of our resource tools. You will be using Gemini Pro (NanoBanana) as a replacement. Please confirm you will be able to login to my Gemini account through your virtual browser and use it as an image/video generation tool whenever needed.*
>
> **Assistant status (2026-10-19):** not verified. The assistant has browser automation available in this session (Playwright and a Chrome extension that reuses the producer's logged-in Chrome tabs), so driving gemini.google.com is technically plausible, but no login or generation has been attempted. Per the Master Prompt rule «never claim to control art tools without a working integration», this stays *unverified* until a supervised test is recorded (ROADMAP M0.1-06). Points to settle in that test: Google 2FA/captcha behaviour, Google's automation terms, and commercial-use rights of generated images inside a Roblox experience. Generated images remain **reference material** until provenance and permitted use are reviewed (see «Content quality and policy»).
- Each asset has **one current editor/owner** and a documented handoff. A Git LFS pointer represents source versioning, **not** Roblox publication or inclusion in a place build.
- Use placeholder geometry until M1 game loop, scale and port contracts prove correct. Replacing a mesh must not require rewriting production rules.

## Initial folder recommendation

Add folders **only when real assets exist**. Suggested eventual organization:

```text
assets/
  source/
    blender/             # native .blend and referenced textures
    substance/           # authored material projects/exports
    audio/               # editable originals and licenses
  exports/
    models/              # selected .fbx/.glb/.obj/.rbxm exports
    textures/            # texture files at approved resolutions
    audio/               # approved import-ready audio
  references/             # only content with explicit use rights
  manifest.md             # stable IDs, ownership, version, permissions
```

Coordinate with existing `.gitattributes` and `.gitignore` before adding binary source formats. Git LFS is appropriate for tracked large binaries; **text** config, Rojo project JSON, asset metadata and notes belong in normal Git. Do not add generated renders, caches and Substance bake intermediates without a concrete reproducibility need.

## Asset handoff contract

For each modular machine, conveyor or decorative prop, record:

| Field | Required info |
| --- | --- |
| Stable logical ID | e.g. `extractor_basic`, independent of Roblox AssetId or mesh name |
| Owner / license | Creator, provenance, rights to use/modify/publish, third-party attribution |
| Dimensions and units | Roblox studs target; actual Blender units and applied transforms |
| Origin / pivot / facing | Placement pivot, front direction, rotation and 4-stud build-grid alignment |
| Machine attachment points | Named ports and local-space transform/flow direction; do not infer from rendered art |
| Collision | Target collision volume and walkable clearance; avoid decorative collision traps |
| Performance budget | Triangle complexity, texture counts/resolution, materials, LOD and reuse assumptions |
| Source / export | Git/LFS source path, import format/version, export settings and intended Roblox folder |
| Roblox publication | Owner group, asset type, asset ID, permissions, environment and approval date |
| Validation | Screenshot/video or studio record of placement, fit, collision, ports and streaming visibility |

Suggested naming convention: lowercase stable logical identifiers (`machine_extractor_basic`, `belt_straight_basic`, `archive_reveal_tray`), plus visual variants only if game design approves them. Model names need not equal business IDs; the manifest maps one to the other.

## Export/import process

1. Engineer specifies placeholder footprint, pivot, build-grid cells, throughput-related ports and bounding dimensions in a reviewed model contract.
2. Artist creates **original** geometry using consistent scale; maintains the .blend and approved material sources in Git/LFS.
3. Artist exports an agreed format supported by the current Studio importer (commonly FBX or glTF where suitable), with transforms applied and predictable pivots. Test exporter/importer compatibility on an actual example.
4. Engineer imports into a **test** Roblox experience, verifies collision, orientation, port locations, animations and device visual budgets. Record Studio-only modifications, if any.
5. After explicit approval, publish under the correct creator/group, document IDs and permissions, and integrate instances/definitions through the chosen Rojo/Studio scene pipeline. Avoid embedding uncatalogued dependencies on an artist's personal inventory.
6. Commit manifest/config updates with the related code and tests; keep original editable source. A build should identify which content still lives only in Studio/Roblox.

## Studio-only source preservation and restore gate

**Verified config audit (2026-10-18):** `default.project.json` maps
`src/server`→ServerScriptService.Server, `src/client`→StarterPlayerScripts.Client,
`src/shared`→ReplicatedStorage.Shared. Workspace only sets FilteringEnabled;
SoundService only RespectFilteringEnabled. There is no authored scene/Terrain path.
No mapping/ignore flags changed. File-backed roots are managed; don't edit their
scripts independently in Studio. Roots without `$path` preserve unknown instances
by default, but their mere presence in Studio does not version them or reproduce
them in `rojo build`. See [Rojo project format](https://rojo.space/docs/v7/project-format/).

[Rojo sync details](https://rojo.space/docs/v7/sync-details/) documents engine/plugin
limits for live binary data, Terrain/CSG and some properties. Exporting a model or
keeping AssetIds alone is not evidence that a clean machine can restore the place.

**Selected engineering workflow for first real content, not executed in M0:**

1. Engineering contributor audits managed tree and inventories all authored content
   before connecting Rojo to a nonempty place. Art retains Blender/Substance/native
   originals and referenced textures/licenses; original sources plus agreed exports
   enter Git/LFS with the asset handoff contract above. No required paid/concept tool.
2. Studio scene editor maintains one canonical full source place under a future
   `assets/source/studio/` location, with one current editor. Use binary `.rbxl` in
   LFS for full Terrain/CSG/content snapshot; text `.rbxmx` model exports in normal
   Git where suitable; binary `.rbxm` already has LFS rules. Save before potentially
   destructive sync/import and whenever handing ownership of a scene to the other role.
3. Current `.gitignore` ignores all `.rbxl/.rbxlx` and `.gitattributes` lacks `.rbxl`.
   When an actual source scene exists, include a **narrow** source-path ignore
   exception and `.rbxl` LFS rule in its reviewed handoff. Check `git check-ignore -v`
   and `git check-attr filter` then stage the real file. Do not force-add arbitrary
   autosaves/build outputs or broaden tracking now for empty folders.
4. Its manifest records source path/version/hash, editor, Studio version, associated
   code commit, exported model dependencies, Terrain/CSG coverage, and every external
   Roblox AssetId/creator/permission required. Luau inside a serialized source place
   is a backup copy: restore managed code from the corresponding Git commit, never
   accept Studio edits as a second canonical code branch. Place settings, secrets and
   DataStores are not silently included or reproduced by a file restore.
5. Before integrating the first real scene, another role or a clean workspace
   checks out Git + pulls LFS, opens the canonical source place locally, verifies
   named models/Terrain/collisions/ports and dependencies, then connects the audited
   Rojo tree to the intended target and checks both bootstraps. Record expected vs
   actual content, version/hash, screenshots/logs and any unavailable asset permission.
   This is a future local restore test, not publication or a production-store test.
6. Publish/upload only after ownership/permissions and explicit authorization are
   recorded. Keep editable sources after upload and record IDs in the manifest.
   Git LFS is versioning, not Roblox publication; generated `build/game.rbxlx` does
   not supersede the canonical authored source scene.

**M0 disposition:** no existing scenes need backup/migration (producer report E-013).
No asset folders/manifests were created. The prior bootstrap Rojo/Play round trip is
user-confirmed in setup-follow-up; it is not evidence for restoring future art.
A restore trial is not applicable to absent content; the first-content gate above
must pass in M1 before relying on any Studio-only scene. If a real pre-existing
scene is later discovered, stop sync/editing until it is inventoried and preserved.

## Content quality and policy

- Do not copy models, textures, distinctive compositions, audio, branded text, names, UI or scripts from a reference game. Inspiration from general industrial machine feedback/throughput presentation is acceptable; final designs must be original.
- Respect Roblox creator asset ownership, access permissions, music licenses and applicable platform requirements. Publicly accessible does not mean licensed for use.
- Favor shared materials, texture atlases where beneficial, LODs and client-side representative paper visuals instead of spawning one physical paper per economic unit.
- Treat generated concept art as reference only until provenance and permitted use are reviewed. Do not include secrets, personal credentials or private source material in asset metadata.

## First collaboration deliverable (suggested)

A single **prototype extractor + straight conveyor + processor + archive tray** placeholder set, with tested dimensions, pivots, ports, source/export files and one manifest entry per asset. Validate a clean import, Studio placement and the code-to-asset mapping before commissioning a full warehouse set.
