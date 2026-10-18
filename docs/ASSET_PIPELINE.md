# Art and asset pipeline — two-person collaboration

**State:** workflow proposal for M0. Asset naming, texture budgets and final manifest format require the first actual vertical-slice art handoff; nothing here claims that game art has been exported, uploaded or published.

## Goals and ownership

- Engineering: Roblox Studio integration, Rojo mappings, gameplay contracts, collision/performance testing, stable game IDs and asset manifest.
- Art: Blender models and source scenes, Adobe Substance materials when justified, original textures, optimization and authored previews. Higgsfield or other concept tools are optional and not runtime requirements.
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

**Critical gap:** the initial Rojo project reconstructs the **code foundation**, not necessarily Terrain, authored Workspace maps, Studio-built scenes or externally published assets. Before the commercial game depends on any of these, choose and test a backup/export/versioning workflow and record who can restore it from a clean computer. Do not rely on `.rbxlx` build output as a substitute for source control.

## Content quality and policy

- Do not copy models, textures, distinctive compositions, audio, branded text, names, UI or scripts from a reference game. Inspiration from general industrial machine feedback/throughput presentation is acceptable; final designs must be original.
- Respect Roblox creator asset ownership, access permissions, music licenses and applicable platform requirements. Publicly accessible does not mean licensed for use.
- Favor shared materials, texture atlases where beneficial, LODs and client-side representative paper visuals instead of spawning one physical paper per economic unit.
- Treat generated concept art as reference only until provenance and permitted use are reviewed. Do not include secrets, personal credentials or private source material in asset metadata.

## First collaboration deliverable (suggested)

A single **prototype extractor + straight conveyor + processor + archive tray** placeholder set, with tested dimensions, pivots, ports, source/export files and one manifest entry per asset. Validate a clean import, Studio placement and the code-to-asset mapping before commissioning a full warehouse set.
