# Find the Secret Archive

**Status:** M0 — specification and technical foundation. No gameplay is implemented yet.

Find the Secret Archive is a Roblox factory tycoon set in a fictional industrial archive warehouse. Players manually clear paperwork, process ordinary documents for **Intel**, build production lines, and occasionally uncover a genuine **Confidential Archive**. Every genuine archive has the same collectible value and adds exactly **one** to the permanent archive count.

This repository is the **single monorepo** for the Roblox codebase, configurations, automated tests, documentation, and project-owned art sources. Roblox Studio is the runtime and visual editor; Git is the source of truth for code and managed configuration. There is no external Node.js backend, separate API, database server, or mandatory Roblox framework at this stage.

## Current technical baseline

The following versions were reported and locally validated during the initial setup on an Apple Silicon Mac on 2026-10-18. These are **project pins**, not claims that newer versions do not exist. The actual tool source of truth is `rokit.toml`.

| Tool | Version | Purpose |
| --- | --- | --- |
| Rokit | 1.2.0 | Toolchain manager |
| Rojo | 7.7.1 | File-to-Studio synchronization and builds |
| Wally | 0.3.2 | Optional package manager; no gameplay packages yet |
| Selene | 0.32.0 | Luau linting |
| StyLua | 2.6.0 | Luau formatting |
| Luau Language Server | 1.70.1 | Editor analysis |
| Lune | 0.11.0 | Local tooling and offline tests |
| Git LFS | 3.8.0 | Large binary art sources |

Also required: Roblox Studio, Git, and VS Code. Blender and Adobe Substance are art-pipeline tools, not game runtime dependencies. Keep the existing working setup; do **not** reinstall merely because this README changed.

## Start working (already installed)

From the repository root:

```sh
rokit install
wally install
lune run scripts/check.luau
rojo serve --address 127.0.0.1
```

Then open the project in Roblox Studio and connect the **Rojo** plugin to `localhost:34872`. Verify the intended target before accepting a sync. Use `Play` and inspect Output. Rojo sync and Studio Play must be verified manually: a successful CLI check is not an engine test.

Useful commands:

```sh
rojo build default.project.json --output build/game.rbxlx
rojo sourcemap default.project.json --output sourcemap.json
stylua --check src scripts tests
stylua src scripts tests
selene src
lune run scripts/check.luau
```

The build directory must exist before invoking Rojo directly if the command does not create it; the project check is expected to prepare it. `build/`, downloaded packages, and generated sourcemaps are not committed. If an individual tool command differs from the checked-in scripts or project configuration, use the repository configuration and update this README in the same change.

The check also runs the isolated M0 production-model tests. Run them alone with
`lune run tests/production.luau`; see [the model contract](tests/README.md). Its
fixture values are not approved balance, and it is not connected to gameplay.

El harness experimental autorizado funciona fuera del runtime:
`lune run scripts/balance.luau` exporta S1–S6 deterministas y
`lune run scripts/seededBalance.luau` ejecuta 100000 corridas por escenario/política.
Salidas ignoradas bajo `build/balance/`; supuestos, resultados y pendientes en
[BALANCE §12](docs/BALANCE.md#12-avance-del-simulador-autorizado--2026-10-18).
`lune run scripts/economyBalance.luau` modela compras/sesiones/promoción y
`lune run scripts/steadyBalance.luau` contrasta caudales sostenidos.
Resultados, parámetros y límites en [BALANCE §13](docs/BALANCE.md#13-simulador-m0-completo-offline--paso-1-2026-10-18).
La economía y el pacing siguen pendientes de aprobación del productor.

### First clone on another developer's computer

Install Roblox Studio, VS Code, Git, Git LFS and **Rokit 1.2.0** first, from their official sources; if using Homebrew on macOS, Git LFS can be installed with `brew install git-lfs`. Once, add `export PATH="$HOME/.rokit/bin:$PATH"` to the shell profile (`~/.zshrc` for default zsh), then restart the terminal/VS Code. Some Intel-only tool binaries may require Rosetta on Apple Silicon.

```sh
git clone https://github.com/F94Olivera/gdd.git
cd gdd
git lfs install --local
git lfs pull
rokit install
wally install
rojo plugin install
code --install-extension JohnnyMorganz.luau-lsp
code --install-extension JohnnyMorganz.stylua
lune run scripts/check.luau
code .
```

The integration branch is `master`. Review/accept normal Rokit source trust requests. Do not bypass Rokit's trust checks in normal local use. Restart Studio if the Rojo plugin is not visible. Complete the live Rojo sync/Play tests on **each** machine, not only CLI checks.

## Repository layout

```text
.
├── README.md
├── AGENTS.md
├── default.project.json       # existing Rojo mapping (do not replace blindly)
├── rokit.toml                 # pinned development tools
├── wally.toml / wally.lock    # package manifest and resolved versions
├── src/
│   ├── server/               # authoritative runtime and bootstrap
│   ├── client/               # UI, input, visual feedback and bootstrap
│   └── shared/               # public types, configuration and pure logic
├── scripts/                  # Lune/check tooling (not part of the place)
├── tests/                    # offline tests and simulation fixtures
├── assets/                   # introduced only as the pipeline is established
└── docs/
    ├── GDD.md
    ├── ARCHITECTURE.md
    ├── DECISIONS.md
    ├── ROADMAP.md
    ├── BALANCE.md
    ├── TEST_PLAN.md
    ├── ASSET_PIPELINE.md
    └── history/               # dated setup audits and historical notes
```

Paths listed for future systems are **planned**, not a claim they already exist. Preserve the existing `src/server/Bootstrap.server.luau`, `src/client/Bootstrap.client.luau`, `src/shared/`, and Rojo mappings until a reviewed implementation changes them.

## Documentation and decision authority

| Document | Read it for |
| --- | --- |
| [GDD](docs/GDD.md) | Game identity, approved rules, scope and player experience |
| [Decisions](docs/DECISIONS.md) | Later producer decisions, open questions and superseded assumptions |
| [Architecture](docs/ARCHITECTURE.md) | System boundaries, contracts, persistence, security and source layout |
| [Roadmap](docs/ROADMAP.md) | M0–M4 deliverables, sequencing and acceptance gates |
| [Balance](docs/BALANCE.md) | Proposed numeric tuning, models and metrics; not yet locked |
| [Test plan](docs/TEST_PLAN.md) | What must be tested in Lune, Studio, multiplayer and devices |
| [Asset pipeline](docs/ASSET_PIPELINE.md) | Two-person art handoff, licensing, LFS, Studio publication |
| [AGENTS](AGENTS.md) | Non-negotiable instructions for Codex and other coding agents |

**Authority order:** later explicitly approved producer decisions in `docs/DECISIONS.md` > original *Master GDD v2.1* (2026-10-15) > this repository's working `docs/GDD.md` summary > implementation details and proposals. The original GDD and the companion *Claude Master Prompt v2.1* were supplied separately: preserve access to those originals and reconcile `docs/GDD.md` before claiming it is a full verbatim conversion. `AGENTS.md` governs implementation process and does not override product rules.

## Team and release rules

- Two contributors: small focused branches, pull requests, review by the other contributor, and checks before merge.
- One owner per asset or serialized Studio scene during an edit; coordinate binary work to avoid impossible merges.
- Use `lune run scripts/check.luau` plus a relevant Studio Play check before a PR. Include multiplayer/touch checks when affected.
- Do not publish an experience, upload an asset, create a remote, push code, or change live DataStores without explicit approval.
- A GitHub Actions definition may exist, but its remote execution remains unverified until a remote is set up and the workflow runs.
- Use original assets and copy; protect customer/player data; keep credentials outside Git and `ReplicatedStorage`.

See [the initial setup audit](docs/history/setup-validation-2026-10-18.md) for what was actually validated and what remains manual. Source-controlled code is not the same as a fully reconstructible Roblox experience: Studio-only Terrain/places, uploaded asset IDs and permissions, and published experience settings need a separate documented pipeline.

## Official technical references

- [Roblox external tools](https://create.roblox.com/docs/projects/external-tools), [client/server security](https://create.roblox.com/docs/scripting/security/client-server-boundary), and [DataStores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Rokit](https://github.com/rojo-rbx/rokit), [Rojo](https://rojo.space/docs/v7/getting-started/installation/), [Wally](https://github.com/UpliftGames/wally), [Lune](https://github.com/lune-org/lune)
- [Selene](https://github.com/Kampfkarren/selene), [StyLua](https://github.com/JohnnyMorganz/StyLua), [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp), [Git LFS](https://git-lfs.com/)

References are documentation links, not proof that a particular integration was tested on the second developer's machine.
