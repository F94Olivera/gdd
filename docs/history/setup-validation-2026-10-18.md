# Initial setup audit — 2026-10-18

**Document type:** historical installation/verification record, not an ongoing product specification. This is a **reorganized account of the results supplied by the developer**, not a claim that the current documentation generation reran commands or opened Studio. Keep this as an archive until pending manual checks are closed; record new verification dated separately rather than rewriting old results.

## Environment as reported

Apple Silicon macOS; Git 2.54.0; existing Roblox Studio, VS Code and Homebrew. Rokit **1.2.0** was installed via an inspected official installer. Versions pinned in `rokit.toml`: Rojo 7.7.1, Wally 0.3.2, Selene 0.32.0, StyLua 2.6.0, Luau LSP 1.70.1, Lune 0.11.0. Git LFS **3.8.0** was installed with Homebrew. VS Code extensions: Luau LSP 1.70.1 and StyLua extension 1.7.2. Rokit's path was added to `~/.zshrc`; Rojo plugin 7.7.1 installed to `~/Documents/Roblox/Plugins/RojoManagedPlugin.rbxm`. LFS was initialized with `git lfs install --local` (not global).

The initial environment apparently required trust configuration for official Rokit repositories and may require Rosetta for Intel-only binaries. Prefer normal `rokit install` trust flow in subsequent onboarding; do not routinely use `--no-trust-check`.

## Checks reported successful during setup

| Action | Historical reported outcome |
| --- | --- |
| `git init -b main` | Local repository created and first local commit made |
| Rokit install and `--version` for six managed tools | Successful |
| `wally install` | Successful; lockfile generated; no gameplay packages |
| `stylua src scripts tests` | Successful |
| `stylua --check src scripts tests` | Successful |
| `selene src` | Zero errors, warnings or parse failures |
| `lune run scripts/check.luau` | Local check, build and bootstrap smoke tests passed |
| `rojo build default.project.json --output build/game.rbxlx` | Successful; Lune deserialized built place and checked bootstrap class/locations |
| Open `build/game.rbxlx` in Studio | Successful; Rojo plugin visible |
| `rojo sourcemap default.project.json --output sourcemap.json` | Successful |
| `rojo serve --address 127.0.0.1` | Listening on port 34872; `/api/rojo` responded; Studio detected project GDD |
| Clean local `git clone --no-local`, install and check | Successful on **same machine with previously installed global toolchain** |
| Local `actionlint` 1.7.12 on workflow | No workflow syntax warnings reported |
| `git diff --cached --check` | Successful |

## Not verified / follow-up actions

- [ ] Confirm connected Rojo synchronization in the **actual Studio panel**. The setup automation could not assert final connection state due to UI accessibility errors.
- [ ] Edit a temporary comment in `src/server/Bootstrap.server.luau` in VS Code; verify appearance **and removal** in Studio's `ServerScriptService > Server > Bootstrap`.
- [ ] Run Studio `Play` and confirm `[Server] Bootstrap ready` and `[Client] Bootstrap ready` in Output.
- [ ] After authorized remote creation/push, confirm GitHub Actions actually runs and passes; `actionlint` is not a CI run.
- [ ] Repeat setup from scratch on **second developer's computer**. Same-Mac clean clone is not proof of a fresh workstation install.
- [ ] Verify Rojo/Studio synchronization safety for places containing valuable original art/Workspace elements before first such sync.

## Why this audit remains in `history/`

The audit helps debug onboarding and preserves evidence of what was verified versus assumed at the moment of initial setup. It should **not** be expanded as a second README or be required reading for every coding task. When all manual checks are completed, record a dated follow-up and leave this file archived (or remove it in a separate reviewed cleanup if the team prefers).
