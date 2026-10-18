# Validación del setup — 2026-10-18

## Entorno y cambios fuera del repositorio

macOS Apple Silicon. Git 2.54.0, Homebrew, VS Code y Roblox Studio ya existían.
Se instaló Rokit 1.2.0 mediante su instalador oficial (revisado previamente),
las seis herramientas de `rokit.toml`, Git LFS 3.8.0 mediante Homebrew y las
extensiones JohnnyMorganz.luau-lsp 1.70.1 / JohnnyMorganz.stylua 1.7.2.
Se agregó `~/.rokit/bin` al PATH en `~/.zshrc`. Se instaló el plugin Rojo 7.7.1
mediante `rojo plugin install`, en `~/Documents/Roblox/Plugins/RojoManagedPlugin.rbxm`.
LFS se habilitó con `git lfs install --local`: no se modificó la configuración Git global.
No se instalaron aplicaciones nuevas, no se creó remoto ni se publicó contenido.

## Comandos ejecutados y resultados

- `git init -b main`: repositorio inicializado y primer commit local creado.
- Instalador oficial `bash /tmp/gdd-rokit-install.sh 1.2.0`: correcto.
- `brew install git-lfs`, `git lfs install --local`: correctos.
- `rokit install --no-trust-check` para la instalación inicial revisada, luego
  `rokit trust` para los seis repositorios oficiales y `rokit install`: correctos.
- `--version` de Rokit, Rojo, Wally, Selene, StyLua, Luau LSP y Lune: correcto.
- `wally install`: correcto; lockfile generado, sin dependencias de gameplay.
- `stylua src scripts tests` y `stylua --check src scripts tests`: correctos.
- `selene src`: 0 errores, 0 advertencias y 0 errores de parseo.
- `lune run scripts/check.luau`: correcto; build y smoke checks aprobados.
- `rojo build default.project.json --output build/game.rbxlx`: correcto.
  Lune pudo deserializar el place y comprobar las clases y ubicaciones de ambos bootstraps.
- Studio abrió el build local correctamente; plugin 7.7.1 visible en el menú Plugins.
- `rojo sourcemap default.project.json --output sourcemap.json`: correcto.
- `rojo serve --address 127.0.0.1`: escuchó en 34872 y respondió a `/api/rojo`.
  Studio mostró el aviso de proyecto GDD detectado.
- Clon limpio local mediante `git clone --no-local`, seguido de instalación,
  Wally y `lune run scripts/check.luau`: correcto, sin cambios en archivos versionados.
  Usa el toolchain ya instalado de este Mac; no equivale a una prueba en otro Mac vacío.
- `actionlint` 1.7.12 (binario oficial descargado solo en `/tmp`): workflow sin errores.
- `git diff --cached --check`: correcto.

## Pendientes explícitos

1. Confirmar sesión de sincronización conectada en el panel Rojo de Studio.
   El aviso desapareció tras intentar Connect, pero no se pudo comprobar el estado final:
   la automatización UI devolvió `noWindowsAvailable` / `AXError.invalidUIElement`.
2. Guardar un comentario temporal desde VS Code y comprobar su llegada y retirada en Studio.
   No se considera aprobado por el simple hecho de que `serve` responda.
3. Ejecutar Play y revisar ambos mensajes de bootstrap en Output.
4. Ejecutar Actions en GitHub después de autorizar el remoto y el primer push.
   La configuración fue validada localmente; no hubo ejecución remota.
5. Repetir onboarding en el equipo del segundo desarrollador. El clon local pasó,
   pero no se probó una instalación independiente ni el editor Luau LSP de ese equipo.

El procedimiento manual exacto está en `README.md`. No se implementó gameplay.
