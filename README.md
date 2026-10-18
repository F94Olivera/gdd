# GDD — base Roblox / Luau

Setup para dos desarrolladores, sin gameplay ni dependencias de ejecución.
Git es la fuente de verdad del código; Studio ejecuta el motor y edita contenido visual.

## Requisitos y versiones

macOS (validado en Apple Silicon), Git, Roblox Studio y VS Code instalados desde
sus sitios oficiales. Rokit **1.2.0**; las seis herramientas están fijadas en
`rokit.toml`: Rojo 7.7.1, Wally 0.3.2, Selene 0.32.0, StyLua 2.6.0,
Luau Language Server 1.70.1 y Lune 0.11.0. Git LFS local: 3.8.0.
Wally y algunas herramientas distribuyen binarios Intel: macOS puede requerir Rosetta.
No ejecutar `rokit update` sin revisar y validar los cambios de versión.

## Instalación desde un clon

1. Instalar Studio y VS Code manualmente si faltan. Instalar Git LFS con
   `brew install git-lfs` (requiere Homebrew).
2. Instalar Rokit con el instalador oficial, fijando su versión:

   ```sh
   curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh -o /tmp/rokit-install.sh
   # Revisar el script antes de ejecutarlo.
   (cd /tmp && bash rokit-install.sh 1.2.0)
   export PATH="$HOME/.rokit/bin:$PATH"
   ```

   Agregar ese `export` a `~/.zshrc` una sola vez. Abrir una terminal nueva y
   reiniciar VS Code si estaba abierto antes de configurar PATH.
3. Dentro del clon:

   ```sh
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

   Revisar/aceptar los repositorios oficiales que Rokit solicite confiar.
   No usar `--no-trust-check` habitualmente; se reserva para CI.
   Si Studio estaba abierto al instalar el plugin, reiniciarlo si no aparece.
   Luau LSP usa el ejecutable de Rokit y genera `sourcemap.json` automáticamente;
   la extensión descarga las definiciones Roblox actuales. Studio sigue siendo
   la verificación final de tipos/APIs del motor; no hay un typecheck Roblox en CI todavía.

## Comandos

```sh
rojo serve --address 127.0.0.1                 # servidor de sincronización, puerto 34872
rojo build default.project.json -o build/game.rbxlx # crear build/ antes si no existe
rojo sourcemap default.project.json -o sourcemap.json
stylua src scripts tests                     # aplicar formato
stylua --check src scripts tests             # comprobar formato
selene src                                  # lint Roblox
lune run scripts/check.luau                  # formato + lint + build + smoke tests
```

El check crea `build/`. Las tareas de VS Code también exponen Check, Format y Rojo serve.
Selene se ejecuta por CLI/CI, sin extensión adicional. No se incluyen paquetes de gameplay;
`wally.lock` está versionado. Cuando haya una dependencia justificada, agregar su realm
correcto y mapear `Packages`/`ServerPackages` en Rojo. Actualmente no son parte del árbol.

## Primera conexión y prueba de sincronización

1. Ejecutar el check y abrir `build/game.rbxlx` desde File → Open en Studio.
2. Ejecutar `rojo serve --address 127.0.0.1` desde el repositorio.
3. En Studio, usar Connect en el aviso de Rojo o abrir Plugins → Rojo → Connect,
   host `localhost`, puerto `34872`. Revisar los cambios antes de aceptar la sincronización.
4. Abrir `src/server/Bootstrap.server.luau` en VS Code, agregar un comentario temporal y guardar.
   Confirmar ese comentario en ServerScriptService → Server → Bootstrap en Studio; retirarlo
   y confirmar también su desaparición. Esto prueba el recorrido editor → disco → Rojo → Studio.
5. Usar Play y revisar Output: `[Server] Bootstrap ready` y `[Client] Bootstrap ready`.
   El place está vacío a propósito; no contiene mapa, piso ni spawn de gameplay.
6. Detener Play antes de continuar editando. Detener el servidor Rojo con Ctrl+C.

Rojo sincroniza los archivos al árbol administrado: no usar scripts de Studio como fuente
paralela. Antes de conectar a un place con contenido valioso, hacer una copia y revisar el diff.

## Arquitectura

- `src/server` → ServerScriptService.Server: bootstrap y futuros sistemas de autoridad.
- `src/client` → StarterPlayer.StarterPlayerScripts.Client: bootstrap, entrada y presentación.
- `src/shared` → ReplicatedStorage.Shared: módulos públicos, tipos y constantes.
- `scripts` y `tests`: tooling Lune fuera del place. Ver `tests/README.md`.

No se introducen servicios, contenedores DI, eventos remotos ni frameworks vacíos.
Al agregar remotos, el servidor valida tipo, rango, permisos, frecuencia y contexto;
recalcula los resultados sensibles. Nunca confiar en economía, inventario o daño del cliente.
Todo lo replicado es visible para el cliente. Secretos y credenciales fuera de Git y Shared.

## Workflow de equipo

Una rama por cambio, PR pequeño y revisión por la otra persona. Antes de integrar:
`lune run scripts/check.luau`, prueba local en Studio y, cuando exista interacción,
servidor con dos clientes. Coordinar cambios del mismo asset binario para evitar conflictos.
No publicar ni hacer push automáticamente. El repositorio se inicializa en `main`, sin remoto.
Al autorizar GitHub: crear repositorio privado, primer commit/push y proteger `main`
con revisión y check `check` obligatorio. La ejecución remota de Actions requiere ese push.
CI fija acciones por SHA, Rokit y herramientas; usa permisos mínimos y no publica.

## Qué se guarda dónde

| Elemento | Fuente de verdad / almacenamiento |
| --- | --- |
| Luau, árbol Rojo, configs, lockfile, CI, documentación | Git |
| FBX, Blender, GLB y modelos RBXM propios | Git LFS; reglas en `.gitattributes` |
| Modelos textuales RBXMX / JSON / OBJ | Git normal; mapearlos explícitamente cuando se incorporen |
| Build RBXLX, sourcemap y paquetes descargados | Generados e ignorados |
| Mapas, Terrain y escenas editadas solo en Studio | Todavía no tienen pipeline; exportar/versionar e incorporar al proyecto antes de depender de ellos |
| Meshes, imágenes, audio, animaciones publicados | Roblox, con IDs y permisos; conservar originales autorizados en Git/LFS |
| Experiencia/place publicado, permisos del grupo, monetización, secretos, DataStores | Roblox; configuración externa, no reconstruida por este repo |

Guardar un binario en LFS no lo publica en Roblox ni lo incorpora automáticamente al build.
No versionar builds completos como sustituto del código. Al sumar assets, definir primero
su ruta en Rojo, ownership, licencia y proceso de publicación. El proyecto actual reconstruye
solo la base de código; no se creó ni publicó una experiencia comercial.

## Fuentes oficiales

- [Rokit](https://github.com/rojo-rbx/rokit)
- [Rojo: instalación y plugin](https://rojo.space/docs/v7/getting-started/installation/)
- [Wally](https://github.com/UpliftGames/wally)
- [Selene](https://github.com/Kampfkarren/selene)
- [StyLua](https://github.com/JohnnyMorganz/StyLua)
- [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp)
- [Lune](https://github.com/lune-org/lune)
- [Git LFS](https://git-lfs.com/)
- [setup-rokit para Actions](https://github.com/paradoxum-games/setup-rokit)
