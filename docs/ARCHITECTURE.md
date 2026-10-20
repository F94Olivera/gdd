# Architecture — Find the Secret Archive

**State:** M0 baseline complete, including approved D-017 save strategy. Future gameplay modules and service durability are not implemented or verified. Parent specification: Master GDD v2.0 ([transcription](reference/MASTER_GDD_v2.0.md)) and the approved decisions log.

## Architecture principles

One Git monorepo; one Roblox experience architecture; **no external backend in M0/M1**. Server-authoritative economy, clearing, rarity, building, progression and persistence. Client-authoritative **presentation only**. Pure, deterministic simulation components must be runnable with Lune wherever Roblox APIs are not required. Introduce files and abstractions when a feature requires them; do not create placeholder services just to fill folders.

## Existing layout versus intended expansion

Existing runtime roots as described by the initial setup:

```text
src/server/Bootstrap.server.luau  -> ServerScriptService.Server
src/client/Bootstrap.client.luau  -> StarterPlayer.StarterPlayerScripts.Client
src/shared/                     -> ReplicatedStorage.Shared
scripts/                         -> local tooling, outside the Roblox place
tests/                           -> offline tests, outside the Roblox place
```

Potential M1 layout **after** features are approved (not a scaffolding instruction):

```text
src/
  server/
    Bootstrap.server.luau
    services/
      PlayerDataService.luau
      PlotService.luau
      BuildService.luau
      ProductionService.luau
      DiscoveryService.luau
      EconomyService.luau
      ProgressionService.luau
      TutorialService.luau
      StatsService.luau
      LeaderboardService.luau          # global publishing follows M3 gate
    network/                            # validated remote handlers, when needed
  client/
    Bootstrap.client.luau
    controllers/                        # input, placement, tutorial, reveal
    ui/                                 # components and status screens
    visuals/                            # bounded paper/warehouse effects
  shared/
    config/                             # versioned public definitions
    types/                              # stable public contracts
    simulation/                         # pure graph/rates/queue arithmetic
    util/                               # small reusable pure helpers
scripts/                                # tooling and reproducible simulations
tests/                                  # seeded simulations and fixtures
assets/                                 # source assets and exports as defined by pipeline
```

**M1-01 (2026-10-20):** the versioned definitions live in a single module, `src/shared/Catalog.luau` (types, frozen data, `validate`, `rankFor`), instead of separate `config/` and `types/` folders. It has no `require` dependencies, so the same file loads in Lune and as a Roblox `ModuleScript`. Split it only when a second consumer needs part of it.

**M1-02 (2026-10-20):** `src/server/ProductionLedger.luau` is the pure authoritative step: lines sorted by ID consume a fresh `60 × dt` budget each 0.2 s tick (no banking), elapsed time beyond 2 s is discarded and reported, whole eligible unit IDs come from `floor(accepted + 1e-8)` over one global cursor, and clearing stops once accepted-but-unconfirmed work reaches 600 (D-017). Its per-line step repeats the M0 `Production.step` formula and a test keeps both identical, because runtime modules cannot require `scripts/`. It takes its limits as data (`Catalog.productionLimits`) instead of requiring the catalog, so no runtime module depends on require-by-string.

**M1-03 (2026-10-20):** `src/server/PlotGraph.luau` validates a whole candidate belt set on every edit (bounds, fixed footprints, blocked cells, port alignment, cycles, own-bay routing) and returns either a new state or an error code, never a half-applied one. Belts store no units (D-023); line status per bay (`connected`, `no_belt`, `dangling`) and the slowest belt's rate feed the production ledger's transport rate.

This is not an Express-style controller/service/repository mapping. **Services own authoritative domain behavior**, client controllers orchestrate UX, and `shared/simulation` holds engine-free domain calculations. Persistence adapters should live behind `PlayerDataService` (separate `repositories/` only if concrete duplication justifies it).

## Ownership of domain boundaries

| Owner | Responsibilities | Never trusts |
| --- | --- | --- |
| PlayerData | Session locking, migrations, profile loading, budgets, durable operations, reconciliation | A client-provided balance or progress |
| Plot + Build | Eight-plot ownership, slots/ports/grid topology, safe equipment edits, inventory conservation | Client-declared placement, inventory, ownership |
| Production | Logical input units, queues, processing rates, backpressure, fractional accumulation, fixed-step/capped catch-up | Visual paper objects or client-reported throughput |
| Discovery | Once-per-eligible-unit roll, server RNG, mandatory H=200000 guarantee (D-011), unique reward operation IDs and pending commitments | Client randomness, discovered archive count |
| Economy + Progression | Intel credit/spending, machine eligibility, permanent count-derived rank, sector access and voluntary promotion | Client prices, permissions or rank |
| Tutorial | Server-confirmed step completion; separate unranked demonstration reward | UI animation as proof of completion |
| Stats | One-time authoritative event semantics and versioned period counters | Client timings/scores and repeated events |
| Leaderboard | Idempotent, budget-aware global projections of committed stats; reconciliation | Uncommitted local counters or stale snapshots |
| Client controllers | UI, input, previews, motion, sounds, visual layers, discovery inbox | None of the gameplay authority |

Do not create `CommerceService` or a receipt pipeline until a later milestone makes purchases necessary.

## Core production flow

```text
plot supply (fresh logical units)
    -> manual sort OR authorized extractor
    -> ONE clearing eligibility event (+ potential archive award)
    -> bounded ordinary-output buffer
    -> player-connected conveyors (validated directed graph)
    -> processor
    -> secure output (+ one production Intel award)
```

A genuine archive reward is **additional** to ordinary output. Each fresh unit receives discovery eligibility **exactly once**. The scanner/process stage never gates the existence of an archive; reprocessing, moving belts and reconnects cannot regenerate clearing events.

Approved launch design D-012 caps **combined manual/automatic fresh clearing at
60 units/s per player/factory across all floors and sectors**. At most two maximum
extractor lines, reference rates 30 clearing / 50 transport / 40 processing per line.
Build rules and UI must expose the restriction. Before implementation, define the
shared budget accounting/allocation across simultaneous sources, without banking
blocked work or silently reducing odds. This is a future server/build contract,
not a change to the isolated two-buffer Production module. Use versioned parameters.

### Simulation contract

- Initial target: **5 Hz** server production update, elapsed-time accounting, fractional unit accumulators and stable traversal order.
- Cap each update's catch-up to **2 seconds** and log discarded production time (GDD proposed defaults).
- Buffer/output capacities are finite; a full downstream stage propagates backpressure and eventually halts extraction.
- One logical unit is not represented by one Roblox Part. Client budget starts at **240 representative moving papers** across nearby plots (including max 120 owner and 30 per nearby visitor plot), to be validated on target devices.
- Production engine should accept pure data/state and return deterministic state transitions/events for seeded offline tests. Server adapters manage the clock, Roblox instances, remotes and save operations.
- Graph validation: designated machine footprints, 4-stud grid, typed ports, no cycles, blocked lanes, bounds, safe edit previews and transactional recovery of in-flight content.

## Server-to-client API design (when implemented)

No remotes are required by this documentation-only change. When introducing them, define typed intent messages (e.g. `RequestManualClear`, `RequestBuild`, `RequestPurchase`, `RequestPromotion`) and server-originated snapshots/notifications. Request payloads contain **intent and identifiers**, not derived prices, completion times, drop results, or raw user profile tables.

For each message document the schema, caller permissions, idempotency key, rate limit, validation errors and lifecycle. Validate finite numeric values, table size, IDs, ownership, proximity if relevant and legal state transitions. Enforce one owner of every state transition. Do not expose arbitrary instance paths or privileged operations.

## Persistence and durable awards

### Estrategia aprobada M0 — D-017 (paso 3)

Revisión de fuentes realizada 2026-10-18. D-017 aprueba **DataStore estándar
nativo + adaptador acotado de PlayerData**, con un perfil/key por jugador,
`UpdateAsync`, cola serial y sesión con fencing (época monotónica). No backend
externo, paquetes, implementación de persistencia ni llamadas a servicios en M0.

| Alternativa | Evidencia actual | Evaluación para este proyecto |
| --- | --- | --- |
| Nativo Roblox | API y guía oficial de perfiles/colas/bloqueos vigente | Recomendado: control explícito de validación, CAS y no sobrescritura; exige implementar y probar locks/retries en M1. No copiar sin revisar todo el ejemplo oficial. |
| ProfileStore | Repo no archivado, Apache-2.0; HEAD `45c9847cbcf1fc260369c50eb335aba7c35aecdd`, último commit 2025-07-31 | Sucesor disponible, sin evidencia de actividad reciente posterior. `Save()` es asíncrono; ack requiere comprobar snapshot. Corrupción puede reconstruirse dentro del wrapper antes de `OnOverwrite`; no cumple nuestra política tal cual. Alternativa solo con copia fijada/endurecida y revisión del diff. |
| ProfileService | README del autor declara fin de soporte y deriva proyectos nuevos a ProfileStore; último push 2024-10-13 | Descartado para proyecto nuevo; no elegir por costumbre. |

ProfileStore: la API GitHub mostró cero avisos públicos de seguridad; no equivale
a auditoría ni ausencia de vulnerabilidades. No hay SECURITY.md. PR #22 propone
corregir copia de buffers por referencia; usar solo datos JSON no resuelve el
comportamiento de reconstrucción de perfiles corruptos. No se ejecutó código ajeno.
La fuente se inspeccionó localmente solo bajo `build/research/` ignorado, sin instalarla.

Fuentes primarias:

- [Roblox: perfiles, atomicidad de tabla, cola por key y session lock](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing).
- [Roblox: UpdateAsync y restricciones del callback](https://create.roblox.com/docs/cloud-services/data-stores), [errores/límites](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits), [caché/versiones](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching).
- [ProfileStore fuente fijada](https://github.com/MadStudioRoblox/ProfileStore/blob/45c9847cbcf1fc260369c50eb335aba7c35aecdd/ProfileStore.luau): `UpdateAsync` interno ~517–595 reconstruye datos malformados; `RegisterOverwrite` ~430 notifica; `Save` ~1172 inicia otra tarea. `LastSavedData`/`OnAfterSave` ~877/924 identifican snapshot observado, no basta recibir una señal genérica.
- [ProfileStore API fijada](https://github.com/MadStudioRoblox/ProfileStore/blob/45c9847cbcf1fc260369c50eb335aba7c35aecdd/docs/api.md), [historial](https://github.com/MadStudioRoblox/ProfileStore/commits/main/), [seguridad](https://github.com/MadStudioRoblox/ProfileStore/security), [PR #22](https://github.com/MadStudioRoblox/ProfileStore/pull/22).
- [ProfileService: declaración del autor](https://github.com/MadStudioRoblox/ProfileService#readme).

### Frontera de durabilidad aprobada (D-017)

Una mutación es **confirmada** solo al verificar el registro que la contiene en
backend, por retorno exitoso de `UpdateAsync` con el ID esperado, o reconciliación
posterior sin caché. Una tabla local, animación, timeout o señal de guardado no
prueban persistencia. Un error de escritura puede haber ocurrido después del commit.

Se aprueba confirmación en lotes con objetivo de **5 segundos online**; 300 unidades
máximas provisionales por perfil a 60/s, un lote sellado en vuelo y otro de trabajo
acotado, máximo 600 provisionales totales. El pipeline puede calcular/previsualizar
trabajo mientras guarda; unidades/Intel/contador se reconocen como aceptados y
confirmados al commit. UI distingue progreso provisional de guardado. Un crash puede
descartar provisional, nunca un archivo confirmado. Hallazgo, compra y promoción
fuerzan flush; no mostrar revelación o éxito final antes del ack.

Si un lote no se confirma al siguiente intervalo de 5s, o se llena el límite,
pausar nueva producción/mutaciones con estado visible de guardado pendiente,
conservar candidato inmutable y reintentar. No bancar tiempo ni producir offline.
Los 5s son objetivo/umbral de pausa, **no garantía de respuesta del servicio**.
Backoff propuesto1/2/4/8/15s con jitter y límite60s por intento de reconciliación;
si sigue incierto, mantener no jugable y ofrecer reintentar carga/reingreso, sin
inventar éxito ni liberar prematuramente una escritura en vuelo. Nunca seguir
mutando después de perder lease; los retries viejos conservan su fence original.
Un hallazgo pendiente congela simulación y mutaciones del perfil hasta reconciliar;
procesamiento posterior se retoma desde el snapshot correcto, sin pago duplicado.
Se debe volver a medir pacing en M1 por esta latencia, ausente del simulador actual.

A 5s se presupuestan hasta12 checkpoints/min/jugador activo: 8 jugadores ->96/min,
antes de cargas, flushes y retries. Esto es cálculo, no prueba de servicio. Aplicar
presupuestos reales de lectura/escritura y tamaño serializado; escalonar perfiles,
no aumentar límites de plataforma ni guardar por documento. Colas/reintentos acotados
con backoff/jitter y sin adelantar operaciones. No fiarse solo de presupuesto por
servidor: también existe límite global de experiencia. Outbox/backpressure debe
seguir funcionando ante throttling prolongado.

### Perfil y protocolo idempotente aprobados para implementación M1

Estado privado servidor, versionado y serializable JSON: `schemaVersion`,
`balanceVersion`, `profileGeneration` inmutable, `sessionEpoch`, `sessionToken`,
`leaseUntil`, `commitSeq`, `lastMutationId`, `eligibleCursor`, fracción pendiente,
`discoveryFailureCounter`, `nextNaturalEligibleId`, `lifetimeArchives`, Intel,
layout/colas, producción/stats, tutorial/promoción, outbox y ack de presentación.
No publicar futuros resultados/RNG en ReplicatedStorage. Rank se deriva del total.

1. **Cargar y poseer.** `UpdateAsync` valida estructura completa/versión y adquiere
   token/época de sesión atómicamente. Perfil nuevo solo si backend devuelve **nil
   confirmado**, jamás por excepción, corrupción o versión desconocida. Registro
   inválido se deja intacto y sin perfil jugable. Lease propuesta120s, renovación
   objetivo30s (checkpoints pueden renovar); stop antes de perder autoridad. Una
   nueva época se adquiere únicamente al liberar o expirar lease en backend; cada
   escritura exige token/época vigentes. Probar relojes sesgados y servidor viejo:
   un fence anterior nunca puede confirmar otra operación.
2. **Preparar azar sin rerolls.** No intentar serializar `Random` ni guardar el RNG
   de Lune como runtime. Propuesta: persistir una distancia geométrica privada hasta
   la próxima oportunidad natural (`nextNaturalEligibleId`), equivalente a p fijo
   por unidad. La garantía H se evalúa aparte y no consume otra distancia natural.
   Inicializar ese plan en el perfil antes de permitir clearing; no otorga nada ni
   avanza contador offline. Se revisará/muestreará con RNG servidor en M1, validando
   extremos numéricos y misma distribución del harness. No hay coordenadas de mundo.
3. **Candidato.** IDs de unidades son `(generation, eligibleCursor+n)`; orden estable
   entre fuentes. Fracciones no se redondean por lote. Todo material previo al
   cursor ya fue evaluado. Preparar snapshot completo e inmutable con IDs/resultado
   y estado ordinario asociado. Callback de UpdateAsync no genera RNG, no emite
   eventos ni hace yield; solo comprueba precondiciones y devuelve ese candidato.
4. **Commit.** Mutación `(generation, epoch, commitSeq+1)` exige `commitSeq` anterior
   exacto y lease/token vigentes. Para un hallazgo, una única escritura incluye
   aceptación de la unidad, +1 lifetime, reset de fallos, **salida ordinaria todavía
   pagable**, stats de ocurrencia y entrada outbox con `awardId=generation:unitId`.
   Si se consumió el próximo natural, elegir y guardar su sucesor en este mismo
   snapshot **antes de permitir nuevas unidades**. Si fue garantía previa al natural,
   conservar su posición. No continuar clearing atravesando un hallazgo sin ese commit.
5. **Ack o estado desconocido.** Verificar generación, mutationId/seq y contenido
   esperado en el retorno. Si error/timeout, leer con `UseCache=false` o reintentar
   CAS inmutable de forma serial. Si ya está el mismo commit, confirmar sin sumar;
   si sigue el anterior, reintentar; si hay versión/época incompatible, parar y
   recargar con autoridad. No revertir por un timeout ni reemplazar snapshot nuevo
   por retry viejo. Una lectura de reconciliación jamás habilita escribir sin lock.
6. **Recuperar y revelar.** Crash antes de commit: no hubo aceptación/grant confirmado;
   restaurar checkpoint. El próximo hallazgo ya estaba planificado durablemente:
   al recorrer de nuevo esos IDs el resultado no se sortea otra vez. Si el natural
   siguiente fue solo propuesto en memoria y se perdió, ninguna unidad posterior
   pudo aceptarse con él; puede muestrearse al rehacer el candidato. Crash después
   de commit: cargar cursor/contador/count/outbox y reenviar la revelación del mismo
   awardId, sin +1 adicional. Presentar/repetir animación nunca concede propiedad.
7. **Bounded outbox y promociones.** Propuesta32 entradas sin presentar; no borrar
   para hacer espacio: pausar antes de un hallazgo sin cupo y avisar. Ack cliente
   validado solo retira presentación mediante otro commit; lifetime no cambia. IDs
   antiguos con unitId<=cursor nunca vuelven a concederse aunque la outbox ya no
   los recuerde: el cursor durable es la prueba permanente del prefijo procesado.
   Compras/promoción se serializan con nonce/época y secuencia de comando, resultado
   y high-water mark durables: replays viejos se rechazan sin gastar ni resetear.
   No usar solo historial circular con expiración. Demo se excluye del protocolo de
   awards genuinos; promoción preserva cursor/fracción/plan/fallos/count/outbox.
8. **Salida y recuperación operativa.** Intentar flush final antes de liberar; shutdown
   best-effort no es prueba de commit. Límite de espera/retries deja estado recuperable,
   no inventa éxito ni perfil blanco. Migraciones verifican invariantes antes de
   escribir; rollback de código no puede resetear IDs/contadores. Restaurar un backup
   viejo no es operación rutinaria: reconciliar premios confirmados posteriores antes
   de hacerlo; versionado de Roblox no reemplaza protocolo ni backup explícito.

Este protocolo es diseño, **no implementación ni garantía operativa ya probada**.
M0 acepta estrategia/fallos/criterios; M1 debe demostrar todas las fronteras en un
fake store con fallo y en experiencia/stores de prueba separados. Producción no
se toca, Studio API access no se habilita. Casos de aceptación: TEST_PLAN P-001–P-012.
D-017 aprueba solución nativa y frontera/UX/protocolo; no concede una certificación
de durabilidad ya implementada. Q-007 queda resuelta para M0; verificación M1 pendiente.

## Global boards / statistics

Permanent **archive title** = function of lifetime genuine archive total. Separately, `StatsService` records archives found, fresh documents cleared, production Intel earned, and optional validated secondary categories. Period buckets use UTC day, Monday week, month and all-time with server event occurrence timestamps. Test grants, demonstrations, refunds and rebuild grants are excluded as appropriate. In M1 ship authoritative counters and local UI; global board publication begins after its M3 reliability gate. Use idempotent **absolute scores**, reconcile stale/failing snapshots and avoid per-document DataStore writes.

## Configuration and rollout

Use stable IDs and explicit schema/balance versioning for machine specs, tiers, capacities, prices, rank thresholds, sectors, art identifiers and discovery policy. Make supported content extensible by data + assets; genuinely new mechanics require code/tests. Maintain a migration/rollback plan for changes to player-owned state; preserve earned archives and counter. Do not couple simulation to a particular UI hierarchy or artist asset name.

## Open architecture decisions

- Implement and verify D-017 in M1; strategy Q-007 is approved, service evidence still pending.
- Verify proposed cursor/plan/outbox/lease protocol under D-011 in M1; no durable-reward success claimed yet.
- Define bounded queue recovery and exact event identity for throughput accounting.
- Confirm when a leaderboard projection can be reconciled without trusting stale writes.
- Validate Studio-only scene/asset workflows before considering the experience reproducible.

## Platform implementation references

- [Roblox: secure client/server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Roblox: DataStores and Studio API-access isolation](https://create.roblox.com/docs/cloud-services/data-stores)
- [Roblox: DataStores versus MemoryStores](https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores)

A Studio test environment must never be configured to write to the production DataStore by accident; use a separate test experience/store boundary. Any persistence abstraction adopted during M1 must be reviewed against current documented Roblox behavior.
