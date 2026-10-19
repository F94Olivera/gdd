# Contraste con las fuentes originales — 2026-10-19

**Tipo de documento:** registro histórico de diagnóstico, no especificación vigente.
Compara los tres archivos originales entregados por el productor contra lo que el
asistente anterior (Codex) produjo en `AGENTS.md`, `README.md` y `docs/`. No modifica
reglas de producto ni aprueba números. Las acciones derivadas están en
[ROADMAP → M0.1](../ROADMAP.md#m01--revalidación-contra-las-fuentes-originales-abierto-2026-10-19).

## Fuentes y método

| Archivo (carpeta `~/Downloads/Find the Secret Archive`) | SHA-256 | Metadatos |
| --- | --- | --- |
| `Find_the_Secret_Archive_Master_GDD_v2.docx` | `a0da3515…34be` | Encabezado interno: **Version 2.0**, 15 Oct 2026; 9 páginas, 3591 palabras, 8 secciones numeradas |
| `Find_the_Secret_Archive_Claude_Master_Prompt_v2.docx` | `b529da6f…65bf` | Encabezado interno: **Version 2.0**; 3 páginas, 1310 palabras |
| `Find_the_Secret_Archive_Future_Concepts_Backlog.xlsx` | `39f22529…99ec` | Hojas *Feature backlog* (F01–F19) y *Decision guide*; cita «Master GDD v2.1 section 11» |

Método: extracción de texto de los tres archivos, lectura completa, comparación
regla por regla con `docs/GDD.md`, `DECISIONS.md`, `ARCHITECTURE.md`, `ROADMAP.md`,
`BALANCE.md`, `TEST_PLAN.md`, `ASSET_PIPELINE.md`, `AGENTS.md`, `README.md`, el
historial de Git y los parámetros reales de `scripts/`. No se ejecutó Studio ni se
reprodujeron las simulaciones; solo se revisó código y documentos.

## 0. Hallazgo previo: versión del GDD

El repositorio cita en todas partes «Master GDD **v2.1**», «12-page GDD» y el backlog
cita «v2.1 section 11». El archivo entregado dice **v2.0**, tiene 9 páginas y 8
secciones; no existe una sección 11. Dos lecturas posibles:

1. Existe un v2.1 posterior (el backlog, modificado a las 20:35 del 15-10, es
   posterior al GDD de las 18:21 y ya lo cita) que el productor no entregó en esta
   carpeta. En ese caso varios puntos marcados abajo como «no trazables» podrían
   estar en v2.1 y este diagnóstico debe repetirse contra ese archivo.
2. No existe v2.1 y Codex etiquetó mal la versión. En ese caso el contenido no
   trazable es elaboración del asistente presentada como regla del GDD.

**Bloqueante para un veredicto definitivo:** el productor debe confirmar cuál es el
archivo canónico (M0.1-01). Todo lo que sigue se contrasta contra **v2.0**.

## 1. Reglas del GDD v2.0 correctamente reflejadas en el repo

| Regla v2.0 | Dónde está en el repo | Estado |
| --- | --- | --- |
| Una clase de Confidential Archive, +1 exacto, sin tiers/variantes/duplicados/checklist | AGENTS §2, GDD.md §1, D-001 | ✅ |
| Elegibilidad una vez al clearing (manual o extractor); scanner no es puerta | GDD.md §2, D-002, ARCHITECTURE «Core production flow» | ✅ |
| Salida ordinaria sigue pagándose aunque haya hallazgo | GDD.md §2, BALANCE §1, D-017 paso 4 | ✅ |
| p = 0.00001 fijo, sin reducción oculta por caudal | GDD.md §3, D-011, `scripts/*` usan 0.00001 | ✅ |
| Contador de garantía sobrevive desconexión/sector/edición/promoción; demo no lo toca | GDD.md §3, D-011, T-003/T-012 | ✅ |
| Títulos 0/1/5/15/40/100 | D-016, BALANCE §3 | ✅ (aprobado explícitamente) |
| Tutorial 6 pasos; demo tras 30 unidades + primer extractor; demo sin crédito | GDD.md §4, D-007 | ✅ |
| Objetivos 20 s / 2 min / 5 min como hipótesis a medir | GDD.md §4, ROADMAP tabla de targets | ✅ |
| Hold-to-sort gratis, misma tasa para todos | GDD.md §4, D-007 | ✅ |
| Reveal solo tras commit durable; inbox de reveals; replay no otorga | GDD.md §4, ARCHITECTURE D-017 pasos 5–7 | ✅ |
| Ocho parcelas 100×100, grilla 16×16 a 4 studs | D-018, GDD.md §5 | ✅ |
| Cintas rectas/esquina 90°; rechazar ciclos/puertos/solapes/límites/carriles | GDD.md §5, T-006 | ✅ |
| Sin splitters/merges en M1 | GDD.md §5 | ✅ |
| Mover conserva inventario; quitar cinta → cola de recuperación acotada o rechazo | GDD.md §5, T-005 | ✅ |
| Vender cinta reembolsa precio registrado una vez; máquinas no se venden | GDD.md §5 | ✅ |
| Intel única moneda; 1 Intel por unidad procesada | GDD.md §5, BALANCE §2 | ✅ |
| Precios 0/30/60/120/600/350/5(+25) y capacidades 1/10/30, 10/40, 10/50 | BALANCE §2, D-014/D-018 | ✅ idénticos al GDD |
| Promoción voluntaria por producción + Intel, nunca por hallazgo; preview y confirmación | GDD.md §6, D-008/D-014 | ✅ |
| Tabla de retención en promoción y reconexión (10 filas) | GDD.md §6 | ✅ equivalente |
| Reset a 100 Intel de rebuild y línea starter gratuita | GDD.md §6, D-014 | ✅ |
| 5 Hz, catch-up 2 s, 240/120/30 papeles visuales | GDD.md §7, BALANCE §4 | ✅ |
| Carga: 8 parcelas × 60 nodos, p95 < 10 ms, 30/60 FPS en dispositivos nombrados | ROADMAP targets, T-016/T-017 | ✅ |
| Simulador offline ≥100 000 corridas, mediana/p90/p99, garantía vs puro | BALANCE §§12–14 (100 000 por escenario/política) | ✅ cumple el requisito |
| Lista de aceptación funcional §7 del GDD | TEST_PLAN T-001…T-015, P-008 | ✅ cobertura completa |
| Evaluar ProfileStore, no ProfileService/Knit por costumbre | ARCHITECTURE D-017 (revisión con SHA fijado) | ✅ |
| Serializar mutaciones, operation IDs, carga fallida → estado de reintento | ARCHITECTURE, T-007/T-010 | ✅ |
| Historial acotado dentro del perfil | ARCHITECTURE outbox 32, high-water mark | ✅ |
| Cosméticos primero; sin productos pagos en prototipo; sin pay-for-luck | GDD.md §9 | ✅ |
| Sin combate/mascotas/robo/trading/offline/archivos pagos | AGENTS §2, D-009 | ✅ |
| R15, tercera persona, PC+touch, controller antes de consola | GDD.md §1 | ✅ |
| No copiar assets/layout de otros juegos | ASSET_PIPELINE «Content quality» | ✅ |

## 2. Decisiones del productor que superan al GDD v2.0 (registradas correctamente)

| Tema | GDD v2.0 | Repo | Evaluación |
| --- | --- | --- | --- |
| Garantía H | 300 000 propuesto, a revisar en M0 | D-011: 200 000 obligatorio | ✅ El GDD pedía exactamente esta decisión; queda citada la aprobación |
| Primera promoción | 25 000 unidades / 10 000 Intel propuesto | D-014: 100 000 / 50 000 | ✅ Alternativas medidas (E6 vs E10) antes de decidir |
| Pisos en lanzamiento | «Launch maximum: Ground, Upper, Basement»; prototipo solo Ground | D-018: Ground en M1 **y lanzamiento inicial** | ✅ Decisión explícita que reduce alcance; GDD.md lo dice |
| Starter + primer extractor | «Free connected starter sorter/conveyor/processor»; extractor 1/s | D-013: el extractor **sustituye** el clearing manual en la línea gratuita | ✅ El GDD era ambiguo; el productor eligió |
| Cap de caudal | «Launch capacity must be bounded and tested» sin número | D-012: 60 unidades/s por fábrica, 2 líneas máximas | ✅ |
| Persistencia | «Evaluate ProfileStore» | D-017: DataStore nativo + adaptador acotado | ✅ Selección documentada con fuentes |

## 3. Contenido del repo **no trazable** al GDD v2.0 ni al Master Prompt v2.0

| Ítem del repo | Etiquetado como | Lo que dice v2.0 | Riesgo |
| --- | --- | --- | --- |
| D-010 «Core global boards: archives, papers cleared, Intel earned; UTC daily/weekly/monthly/all-time» | «Accepted (GDD v2.1)» | §2: «Start with a server board; defer cross-server rankings.» Nada sobre categorías de producción/Intel ni periodos UTC | **Alto**: una regla de producto marcada como aprobada por el GDD sin respaldo visible |
| GDD.md §8 completo (tabla de 5 métricas, semana lunes, countdown UTC, «fastest first archive», refresco 5 min) | Resumen del GDD | Ausente en v2.0 | Alto (mismo caso) |
| D-004 «independent production/earnings boards supplement competition» | «Accepted (GDD v2.1)» | Solo «Ranking: lifetime genuine finds determine rank» | Medio |
| AGENTS §2 «Production/earnings leaderboards are separate competition categories» | Invariante de producto | Ausente en v2.0 | Medio (deriva de lo anterior) |
| E-011/Q-010 «competition presentation/reward wording unavailable» y D-019 «sin premios por clasificación» | Omisión del original resuelta | v2.0 no menciona premios de competición; la «omisión» no existe en v2.0 | Bajo: D-019 sigue siendo decisión válida del productor, pero su premisa es dudosa |
| «12-page GDD» (GDD.md línea 4) | Dato | 9 páginas | Bajo, pero refuerza la duda de versión |

Si v2.1 existe y contiene estas secciones, todo lo anterior se cierra. Si no, D-004
y D-010 deben re-etiquetarse como propuesta del asistente y ratificarse (o
rechazarse) con una decisión D-0xx explícita. No se cambia nada aquí.

## 4. Detalles del GDD v2.0 omitidos o debilitados en `docs/GDD.md`

| Regla v2.0 | Estado en repo | Impacto |
| --- | --- | --- |
| §5 «Promotion opens a new sector and machine eligibility» | GDD.md §5: «no additional sector or throughput is unlocked by the first promotion in M1» (D-018) | **Medio**: con Ground-only, el repo deja la primera promoción solo con +25 %. El GDD define promoción = nuevo sector. «Sector» y «piso» se usan como sinónimos en el repo; el GDD los separa. AGENTS lista «sector count» como bloqueante; D-018 resuelve pisos, no sectores. Ver Q-012 |
| §3 «vault counter and three cosmetic display positions»; «overhead text shows rank and lifetime count»; «banners use cooldowns and aggregate bursts» | Solo «muted banners for visitors» | Bajo-medio: afecta contratos de assets M1-09 y UI M2 |
| §2 «optional serial number or timestamp is provenance only» | No aparece | Bajo (relacionado con backlog F11) |
| §3 «Introduce controls before lore, never require a store visit; explain promotion/ranks when relevant» | No aparece | Bajo (tutorial M1-11) |
| §4 «Owning more archives does not stack uncapped production buffs» | Implícito («no archive probability boost») | Bajo |
| §6 «Validate config references, capacities, probability ranges, prerequisite reachability, migration mappings before startup» | Parcial en ARCHITECTURE «Configuration and rollout» y M1-01 | Bajo |
| §6 «Claude must verify actual integrations before claiming control of Studio or art tools» | No hay inventario de Blender/Substance/Higgsfield instalados o verificados | Bajo-medio; ahora relevante por el cambio a Gemini (D-020) |
| §8 «Keep the GDD, decision log, implementation plan, and balance configuration in the repository» | E-005: el productor dijo que no hacía falta conservar los originales | Medio: hoy el productor declara esos archivos fuente de verdad y no están en el repo ni referenciados por hash. Ver Q-013 |

## 5. Master Prompt v2.0 vs `AGENTS.md` y proceso

| Requisito del prompt | Repo | Estado |
| --- | --- | --- |
| Inspeccionar repo/herramientas antes de reclamar acceso; no fingir Studio/Blender/Higgsfield | AGENTS §1/§5; history/setup-* distinguen confirmado por el desarrollador vs asistente | ✅ |
| Inventario de entorno, contradicciones, dependencias mínimas con revisión de fuente | README baseline; wally sin dependencias; ProfileStore revisado | ✅ |
| Preguntas en rondas ≤5, registrar respuestas, no repetir | DECISIONS Q-001…Q-010 con estado | ✅ |
| Simulador sembrado, mediana/p90/p99, comparar puro vs garantía, rareza a capacidad máxima | BALANCE §§12–14 | ✅ |
| Distinguir inspección / unit test / Studio / multiplayer / dispositivo en cada reporte | TEST_PLAN «Test layers», ROADMAP DoD | ✅ |
| M1 = un piso, una pila, starter manual, extractor, cintas, procesador, un archivo, rango, tutorial, una promoción, persistencia | ROADMAP M1-01…M1-12 | ✅ |
| «Reprocessing or editing never creates a new search» | D-006, T-001/T-005 | ✅ |
| Typed Luau, servicios/controladores claros, Git + Rojo, dependencias fijadas | AGENTS §4, rokit.toml | ✅ |
| Observación: idioma | Docs mezclan inglés y español sin criterio | Cosmético; no bloquea |

## 6. Backlog F01–F19 vs repo

Las 19 entradas están «Proposed». El repo no implementa ninguna y difiere explícitamente
power/water (F16/F17), recetas (F03), árboles (F04/F18), splitters (F08), herramientas
manuales (F01), encargos (F02) y offline Intel (F19) en GDD.md §9 y Q-008. ✅
Observación menor: el repo no cita los IDs F01–F19, así que un pedido futuro de alcance
no es trazable al backlog. Propuesto en M0.1-08.

## 7. Checklist M0 del ROADMAP, ítem por ítem

| Línea | Ítem | Veredicto |
| --- | --- | --- |
| 22 | Rojo live sync confirmado por el desarrollador | ✅ Correcto; evidencia del usuario bien separada |
| 23 | Output `[Server]/[Client] Bootstrap ready` | ✅ |
| 24 | Remoto, rama `master`, run de CI enlazado | ✅ |
| 25 | `lune run scripts/check.luau` local | ✅ |
| 26 | «Original Master GDD v2.1 reviewed against docs/GDD.md» | ⚠️ **Mal interpretado**: versión mal citada (v2.0 entregado), 9 páginas no 12, y §8 de GDD.md no trazable. Tachado en ROADMAP; corregir en M0.1-01/-03 |
| 38 | Reconciliar starter y reglas de competición (E-011) | ⚠️ Parcial: la parte starter es correcta; la de competición parte de una omisión que v2.0 no tiene. Tachado parcial; M0.1-03 |
| 39 | Especificación del simulador | ✅ |
| 40 | D-013 starter | ✅ decisión del productor |
| 41 | D-019 premios | ✅ como decisión; premisa en M0.1-03 |
| 42 | Simulador sembrado | ✅ cumple el GDD (≥100 000, percentiles, control puro) |
| 43 | D-011/D-012 | ✅ |
| 44 | D-015 pacing | ✅ con playtests pendientes |
| 45 | D-014/D-016 | ✅ |
| 46 | D-017 | ✅ |
| 47 | D-018 Ground | ✅ como pisos; sectores abiertos (Q-012) |
| 48 | ASSET_PIPELINE / E-013 | ✅; falta inventario de herramientas de arte (M0.1-06) |

**Entorno de esta revisión:** el repositorio fue clonado el 2026-10-19 a las 02:00 y
esta estación no tiene Rokit, Rojo, Lune, Git LFS, el plugin Rojo ni la línea de PATH
que documenta el README. Por eso `lune run scripts/check.luau` **no se pudo ejecutar**
en esta sesión (solo `git diff --check`, que pasó). Las verificaciones de
history/setup-* corresponden a otro entorno; ver M0.1-10.

**Veredicto global:** el núcleo del producto (archivo único, elegibilidad al clearing,
p/H, precios, títulos, tutorial, promoción, persistencia, simulador) está bien
transcrito y las desviaciones son decisiones explícitas del productor. El problema
real es de **trazabilidad**: una versión del GDD mal citada y un bloque de competición
global (D-004/D-010/GDD.md §8) que no se puede respaldar con el archivo entregado,
más la ambigüedad sector/piso. Nada de esto requiere tocar código: `src/` solo tiene
los dos bootstraps y `scripts/` usa los valores aprobados.

## 9. Revisión del código M0 contra los documentos (2026-10-19)

**Alcance:** lectura completa de `scripts/models/*` (Production, BalanceRunner,
DiscoveryExperiment, EconomyExperiment, BalanceMetrics), `scripts/*.luau`,
`tests/*.luau`, `src/*` y `scripts/check.luau`. **Revisión estática**: Lune no está
instalado en esta estación, así que ningún test ni simulación se ejecutó aquí
(ver M0.1-10). Los números analíticos de BALANCE §1 y §12 sí se recomputaron con
Python: E[N]=86466.607012 unidades, 13.53 % de corridas alcanzan H, mediana
geométrica 69 315 unidades (simulada 69 319), 60/s → 1155 s. Coinciden.

| Afirmación documental | Código que la respalda | Resultado |
| --- | --- | --- |
| Production: downstream-first, dos buffers acotados, catch-up descartado, entradas inmutables, validación finita/no negativa (BALANCE §§8–11, tests/README) | `Production.step` líneas 42–75; `nonnegative`; `discardedSeconds = elapsed - dt` | ✅ |
| 16 casos Production, fixtures (5,3), eventos 4.375/9.625, pasos 0.5…1/32, referencias 1/1024 y 1/2048, tolerancia `8h+1e-8` y factor 0.6; §9 pasos 1/16…1/2048 y envolvente `16h`; §10 pasos 1/4…1/256; §11 h=.07…; `3h`/`6h` | `tests/production.luau` líneas 168–297, 360–483, 586, 785, 911–912 | ✅ constantes idénticas a lo documentado |
| p=0.00001 fijo; garantía: tras 199 999 fallos la siguiente unidad otorga; reset a 0; demo excluido (D-011, T-003) | `DiscoveryExperiment.advance`: `forced = unit + 200000 - failures`; reset `failures = 0`; el experimento nunca emite demos | ✅ frontera exacta; test `failures=199999 → 1 unidad → 1 hallazgo` |
| La garantía no consume draws; ambas políticas ven la misma secuencia natural (BALANCE §12) | `advance` solo re-sortea cuando `nextNatural == event`; test de «paired stream» | ✅ y estadísticamente correcto por falta de memoria de la geométrica |
| Park–Miller 16807 mod 2^31−1, productos < 2^53, geométrica inversa `floor(log(1-u)/log(1-p))+1` | `uniform`, `gap`; vector de referencia 16807, 282475249, … en el test | ✅ |
| Cap global 60/s manual+automático, sin bancar, hasta 2 líneas máximas, tercera rechazada (D-012) | Runner: `budget = 60*simulated`, reparto por ID estable, `assert(maximumExtractors <= 2)`; Economy: `budget = 60*dt`, `#lines <= 2`; test 3×40/s → 120 en 2 s | ✅ |
| Ausencia: cero producción, inventario conservado, sin catch-up (D-011, BALANCE §5) | Runner `if not online then continue`; Economy salta a la próxima sesión sin pasos | ✅ test S4 = control 900 s |
| Primer extractor sustituye el manual, no suma (D-013) | Economy: `extractor1` no cambia `clearingRate`; `automatic = true` | ✅ test `accepted == 40` en 40 s |
| Precios 30/60/5/120/350/25/600 incrementales; total maquinaria 2380 (BALANCE §2/§13) | `policy()` líneas 42–55; suma 2380 | ✅ |
| Promoción: `processed` de por vida ≥ umbral, Intel ≥ fee, consentimiento scriptado, reset a starter + 100, multiplicador 1.25, inventario descartado contabilizado, `accepted` acumulado conservado (D-014) | Economy líneas 177–207; asserts de conservación de material y moneda | ✅ |
| Elegibilidad `floor(accepted+1e-8)`, nunca por paso; fracciones sobreviven promoción | `BalanceMetrics.whole`; test de snapshots vs corrida completa | ✅ |
| Percentiles nearest-rank sobre toda la cohorte, censura como infinito, banda DKW 99 % ±0.005148 | `BalanceMetrics.quantiles`; asserts `< 0.005148` en seeded/steady | ✅ |
| 100 000 corridas por escenario/política, semilla maestra 20261018, derivación documentada | `COUNT = 100000`, `MASTER = 20261018`, `seedFor` | ✅ |
| Fast-forward solo en estado fijo sin decisiones pendientes y equivalente a la corrida sin acelerar | Economy líneas 285–310; test `fastForward=false` vs acelerado | ✅ |
| Procedencia: revisión Git, dirty, versión Lune, hashes de fuentes | `economyBalance` `sourceHashes`; `balance.luau` JSON canónico | ✅ |
| `check.luau` = stylua, selene, rojo build, 5 suites (README/CI) | `scripts/check.luau`; `ci.yml` | ✅ |
| AGENTS §4: `--!strict`, sin dependencias, scripts/tests fuera del árbol Rojo, `src/` intacto | Todos los `.luau` empiezan con `--!strict`; `wally.toml` vacío; `default.project.json` solo mapea `src/*`; `src/` = 2 bootstraps de 3 líneas | ✅ |

**Observaciones de bajo riesgo (no violan reglas; seguimiento en M0.1-11):**

1. `selene` solo analiza `src/`; `scripts/` y `tests/` (2 800 líneas) no pasan lint,
   solo formato. Probablemente por el std `roblox` frente a `@lune/*`; conviene un
   `selene.toml` o std separado para Lune en vez de excluirlos.
2. `economyScenarios.base()` usa por defecto la promoción **no aprobada** 25 000/10 000
   (E6); la aprobada (E10, 100 000/50 000) es una variante. Está documentado, pero
   un default no aprobado es una trampa para reutilización futura.
3. `seededBalance.luau` duplica `timeAt` y `quantiles` en lugar de usar
   `BalanceMetrics`; su `timeAt` carece de la tolerancia `1e-8` y del `max(0, …)`.
   Riesgo numérico despreciable, pero contradice «módulos pequeños y componibles».
4. La segunda línea del experimento cuesta 95 Intel (30+60+5) sin coste de bahía,
   aunque el GDD §4 dice «purchase fixed production bays». Está declarado como
   hipótesis en BALANCE §13; el precio de bahía sigue sin número en ningún documento.
5. El comentario de ROADMAP «seven Lune tests» describe el primer incremento; la suite
   actual tiene 16 casos (correctamente contado en BALANCE/tests README).

**Veredicto del código:** lo implementado es exactamente lo que ROADMAP M0 y BALANCE
§§8–14 afirman, ni más ni menos: un harness offline con modelo de producción,
RNG experimental, economía scriptada y métricas, sin gameplay, sin runtime, sin
persistencia y sin tocar `src/`. No se encontró ninguna discrepancia entre reglas
aprobadas (D-011–D-014) y constantes del código. Lo que falta es ejecutarlo en esta
máquina para convertir esta lectura en evidencia (M0.1-10).

## 10. Reinstalación del toolchain y evidencia ejecutada (2026-10-19, M0.1-10)

Autorizado por el productor en este chat («instalar Rokit, Rojo, Lune y Git LFS en
esta máquina y correr `lune run scripts/check.luau`»). Mac Apple Silicon (arm64),
repo recién clonado sin herramientas. Pasos ejecutados por el asistente:

| Paso | Resultado |
| --- | --- |
| `rokit-1.2.0-macos-aarch64.zip` descargado del release oficial `v1.2.0` (2025-09-30); SHA-256 `eb8e6b4f8026db2b80ad0887c50f342958ecdbacbdeda2fd6028b3c4f774a3ee` = digest publicado por la API de GitHub | ✅ |
| `rokit self-install` → `~/.rokit/bin/rokit 1.2.0`; añadió `. "$HOME/.rokit/env"` a `~/.zshenv`; se añadió además la línea del README a `~/.zshrc` | ✅ |
| `brew install git-lfs` → 3.8.0; `git lfs install --local` en el repo | ✅ |
| `rokit trust` explícito de rojo-rbx/rojo, UpliftGames/wally, Kampfkarren/selene, JohnnyMorganz/StyLua, JohnnyMorganz/luau-lsp, lune-org/lune (sin `--no-trust-check`), luego `rokit install` | ✅ Rojo 7.7.1, Wally 0.3.2, Selene 0.32.0, StyLua 2.6.0, Luau LSP 1.70.1, Lune 0.11.0 |
| `wally install` | ✅ 0 paquetes, lockfile intacto |
| `rojo plugin install` | ✅ tras crear `~/Documents/Roblox/Plugins` (no existía: Studio nunca corrió aquí) |
| `lune run scripts/check.luau` | ✅ «All checks passed»: stylua, selene, rojo build, smoke, 16 tests Production, runner, discovery, economía; 1.9 s |
| `lune run scripts/balance.luau` ×2 | ✅ `deterministic.json` byte-idéntico (`aff26900…38d0`); tabla S1–S6 idéntica a BALANCE §12 |
| `lune run scripts/balanceSensitivity.luau` | ✅ deltas A: 4.03125 base, 8.375 E6/E10, 9.15625 E12/E13; secuencia de compras estable (igual a §§13–14) |
| `lune run scripts/seededBalance.luau` (12 escenarios × 2 políticas × 100 000) | ✅ 2.8 s; media garantía 86468.72151, control 100002.01759, 13 535 corridas en H; S6 mediana 1155.5833 s, p90/p99 3333.3167 s; censura S1 99 402, S2 84 432 (= §12) |
| `lune run scripts/steadyBalance.luau` | ✅ 60/s primer hallazgo mediana 1155.4833 s, p90/p99 3333.3167 s; 1/s mediana 69 329 unidades (19.2581 h) (= §13) |
| `lune run scripts/economyBalance.luau` (13 escenarios × 2 × 100 000) | ✅ 36 s; E1 primer archivo online 1459.4427 / 3637.4260 s; E10 1459.3260 / 3803.3396 s; E10 promoción 1971.84375 s; rangos 5/15/40/100 medianas 2.1032/6.1011/16.1200/40.1405 h (= §§13–14) |
| Replays individuales `economyBalance E1-baseline 1` y `seededBalance S6-cap 1` | ✅ |

**Conclusión:** la lectura estática de §9 queda convertida en evidencia ejecutada en
esta máquina; ningún resultado difiere de lo documentado. **No verificado aquí:**
Roblox Studio no está instalado (`/Applications/RobloxStudio.app` no existe), por lo
que la conexión live de Rojo, la sincronización de edición/borrado y el Output de
Play siguen siendo evidencia del entorno del 2026-10-18 (M0.1-12). Las salidas viven
en `build/` (ignorado) y no se commitean.
