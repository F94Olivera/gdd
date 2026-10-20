# Decisions, assumptions and open questions

**Purpose:** durable record of **producer-approved** decisions, with explicit status. A proposal is not approval. Never convert an assistant suggestion into a locked product rule without an actual producer response.

## Decision protocol

For each new decision record: `ID`, date, `Status` (`Accepted`, `Proposed`, `Open`, `Superseded`), context, alternatives considered, **producer approval** (quote/link when available), affected GDD section, implementation consequences and any migration/review trigger. Do not backdate producer approvals. If a future decision supersedes an older entry, add a new entry and mark the old ID superseded rather than deleting history.

## Approved product baseline from Master GDD v2.0 (2026-10-15)

These are **GDD-approved direction**, not new user approvals during this documentation pass. Until 2026-10-20 this table said «GDD v2.1»; the delivered and only GDD is v2.0 (E-014). D-004 and D-010 are not in v2.0; D-021 ratifies them as producer decisions.

| ID | Status | Decision / scope |
| --- | --- | --- |
| D-001 | Accepted (GDD v2.0) | One genuine Confidential Archive class. Equal credit +1 per genuine find; count has no finite cap. |
| D-002 | Accepted (GDD v2.0) | Discovery eligibility at **fresh clearing**, manual or automated, never gated by scanning/processing. |
| D-003 | Accepted (GDD v2.0) | Intel is the sole production currency; no Research currency, dossier requirement, duplicate conversion or archive-consuming unlocks. |
| D-004 | Accepted (producer, D-021; not in GDD v2.0) | Lifetime archive count determines permanent title; independent production/earnings boards supplement competition. |
| D-005 | Accepted (GDD v2.0) | Eight independent bounded plots; PC and touch launch targets; Ground-only in M1. |
| D-006 | Accepted (GDD v2.0) | Bounded queues and backpressure; no re-rolling old material after editing, reconnect or promotion. |
| D-007 | Accepted (GDD v2.0) | Interactive, skippable, resumable tutorial with unranked Demonstration Archive. Hold-to-clear free. |
| D-008 | Accepted (GDD v2.0) | Voluntary promotions based on ordinary production + Intel; preserve archives and discovery counter. |
| D-009 | Accepted (GDD v2.0) | No combat, pets, theft, trading, offline finds, paid archives or pay-to-luck in launch scope. |
| D-010 | Accepted (producer, D-021; not in GDD v2.0) | Core global boards: genuine archives, fresh papers cleared and production Intel earned, each over UTC daily/weekly/monthly/all-time; secondary boards gated separately. |

## Producer decisions — 2026-10-18

### D-011 — Fixed discovery probability with mandatory work guarantee

- Status: Accepted; resolves Q-001. Supersedes the original proposed H=300000 and the open pure-random/guarantee choice; preserves D-001/D-002/D-006/D-007.
- Producer approval: attached text supplied in this chat, “Decisión: implementar un sistema de probabilidad fija con garantía obligatoria”; “Probabilidad base: 0,001%”; “la garantía permanece en 200.000 documentos.” This entry preserves the decision without requiring the local attachment path.
- Rule: each newly accepted manual or automatic clearing has one opportunity. With 199999 consecutive failures, the next eligible document guarantees exactly one genuine archive; otherwise use p=0.00001. Any genuine find resets failures to zero. First and subsequent finds use identical rules; no shortening after unlucky streaks.
- Probability never changes with upgrades, promotion, sectors, archive count or production speed. Counter survives sessions, disconnects, layout edits and promotions. Demonstration Archive affects neither genuine count nor counter. No production, opportunities or counter progress while offline; blocked clearing generates none.
- Server owns RNG, counter and awards; commits must be consistent and idempotent across save failures/reconnects. Explain the work guarantee clearly; no hidden dynamic odds. Ordinary output/payment remains additional under existing rules.
- Alternatives: pure random and the prior 300000 proposal are superseded as launch policies; pure random may remain an explicitly labelled analytical control.
- Impact: GDD §3; BALANCE §§1/5; future Discovery and persistence contracts. Requires H−1/H, reset, demo exclusion, retention and durable retry tests. Q-007 still owns the unresolved durable protocol. No runtime or saved profiles changed here; future parameter changes require an explicit decision and versioned configuration/migration review.

### D-012 — Launch total throughput cap and reference factory

- Status: Accepted; resolves Q-003.
- Producer approval: same supplied attachment, “capacidad máxima sostenible de 60 documentos elegibles por segundo por jugador/fábrica para el lanzamiento”; “Este máximo ... comprende toda la extracción manual y automática combinada”.
- Rule: total manual + automatic eligible clearing is capped at 60 documents/s per player/factory, across every machine, floor and sector. At most two maximum-capacity extractor lines at launch; other configurations must also obey the global cap. Expose restrictions in construction rules and UI, with no hidden production/probability reductions.
- Approved reference: two independent lines, each extractor Tier 3=30/s, upgraded conveyor=50/s, processor Tier 2=40/s, sustained effective throughput=30/s if supply and bounded buffers permit. This approves these reference capacities, not prices, buffer sizes, extra sectors or arbitrary routing.
- Bottlenecks/backpressure govern real output; logical quantities remain separate from visual papers. Parameters/limits belong in versioned configuration when implemented.
- Alternatives: uncapped scaling and the exploratory 100/s launch candidate are superseded. Later expansions need an explicit decision/configuration revision.
- Impact: GDD §5; BALANCE §§2/5; architecture/build validation and eventual combined manual/automatic budget tests. Aggregate cap enforcement and allocation under simultaneous sources need an engineering contract before implementation. No change to Production or its two-buffer contract here.
- Economy: the attachment uses 1 Intel/processed unit for its 216000 Intel/hour steady-state calculation before multipliers; prices, expansion costs and promotion requirements remain provisional and require simulation. No inference of approved Q-004/Q-005/Q-006 values.
- Acceptance: use p=0.00001, H=200000 and total cap=60/s for M0/design and initial launch. Simulate progression, interrupted sessions, stalls and first-find distributions before claiming validated public pacing. This does not close M0 or authorize simulator/gameplay implementation in this documentation slice.

### D-013 — Primer extractor sustituye el clearing manual de la línea gratuita

- Date: 2026-10-18
- Status: Accepted; resuelve la parte starter de Q-010.
- Producer approval: respuesta explícita “Aprobar sustitución en la línea gratuita” a la propuesta de sustitución, conexión incluida a 1/s y mejoras posteriores de cinta/procesador.
- Rule: el primer extractor sustituye el clearing manual en esa línea; no suma ambos caudales. Usa la conexión gratuita a 1/s. Permite comprar mejoras posteriores de cinta/procesador.
- Impact: escenario económico offline y futuro starter M1. No aprueba el precio propuesto de 30 Intel para runtime, los demás precios, paquetes de segunda línea, rangos ni economía de promoción. No resuelve las restricciones adicionales de presentación/premios de competición pendientes en Q-010.
- Acceptance: antes/después de comprar el primer extractor el clearing nominal continúa a 1/s; coste solo con Intel disponible; el inventario conserva su elegibilidad y pago ordinario.

### D-014 — Economía inicial M1 y primera promoción

- Date: 2026-10-18
- Status: Accepted; resuelve economía inicial y parte M1 de Q-005.
- Producer approval: “Precios originales y promoción a 100.000 procesados +50.000 Intel”, en respuesta a las alternativas medidas del paso 2.
- Rule: precios incrementales originales de BALANCE §2 como candidato inicial M1; primera promoción voluntaria con 100000 unidades ordinarias procesadas de por vida, 50000 Intel disponibles y tutorial/equivalente. Reset a starter gratuito +100 Intel, multiplicador total 1.25.
- Alternatives: precios ×2/×5 y primera promoción 25k/10k no elegidos. E10 es el escenario de referencia aprobado; tasas/buffers/sesiones/demoras y paquete conectado de segunda línea conservan sus estados de autoridad propios.
- Retention: archivos/rango/contador de fallos y fracciones de elegibilidad acumuladas, tutorial, estadísticas y premios pendientes sobreviven. Preview explicita fee, Intel sobrante reseteado e inventario descartado antes del consentimiento.
- Impact: BALANCE §§2–3/14, GDD §§5–6, futura configuración M1 versionada. No autoriza gameplay ni segunda promoción (250k/100k y 1.50 permanecen fuera de M1).
- Acceptance: repetir E10 con 100000 semillas por política, validar asequibilidad sin suerte, conservación/reset/retención y pacing D-015; playtests pendientes.

### D-015 — Objetivos de pacing de referencia M0

- Date: 2026-10-18
- Status: Accepted; resuelve Q-002 para M0, sujeto a validar en playtests.
- Producer approval: “Aprobar estos objetivos de referencia; confirmar después con playtests.”
- Rule: primer archivo con progresión ideal y una promoción: mediana <=37 min y p90/p99 <=75 min **online** desde primera unidad elegible. Referencias sostenidas aceptadas: 60/s mediana ~19.3 min y p90/p99 ~55.6 min; 1/s manual mediana ~19.26 h y p90/p99 ~55.56 h.
- Limits: ausencia aumenta calendario; no promesa de hallazgo genuino en tutorial. La única garantía sigue siendo H por trabajo (D-011), nunca tiempo calendario. Sesiones/demoras del harness son hipótesis, no un SLA ni validación de retención real.
- Acceptance: volver a contrastar las cohortes afectadas contra estos objetivos, publicar censura/bandas y validar después construcción/input reales sin cambiar p/H por inferencia.

### D-016 — Títulos permanentes M1

- Date: 2026-10-18
- Status: Accepted; resuelve Q-004.
- Producer approval: “Aprobar umbrales y títulos propuestos.”
- Rule: 0 Trainee, 1 Archive Finder, 5 Investigator, 15 Senior Investigator, 40 Archive Specialist, 100 Director of Archives. Solo lifetime genuino; sin límite de hallazgos posterior a 100, sin consumo ni efecto de rankings periódicos.
- Impact: BALANCE §3 y GDD §3; futura configuración/UI M1. No premios de competición ni multiplicador de suerte.
- Acceptance: mostrar pacing medido en el escenario elegido E10, no atribuirle las mediciones de precios ×2 presentadas como alternativa. Tests de fronteras de rango se implementarán con la configuración M1.

### D-017 — Estrategia de guardado y frontera de confirmación

- Date: 2026-10-18
- Status: Accepted; resuelve Q-007 como estrategia M0.
- Producer approval: respuestas explícitas “Aprobar adaptador nativo acotado (recomendado).” y “Aprobar frontera y protocolo propuestos (recomendado).”
- Recommendation: DataStore estándar nativo, un perfil/key, cola serial, UpdateAsync/CAS y fencing de sesión; sin dependencia externa. ProfileStore revisado en SHA45c9847: requiere endurecer reconstrucción de datos corruptos y confirmar snapshot guardado. ProfileService sin soporte para proyectos nuevos.
- Contract: ARCHITECTURE sección Persistence and durable awards; TEST_PLAN P-001–P-012. Checkpoint objetivo5s, datos provisionales acotados/etiquetados; hallazgo/compra/promoción fuerzan commit. Resultado natural privado preplanificado/persistido antes de aceptar unidades; grant/cursor/counter/ordinario/outbox en un commit, reveal solo tras ack. Pérdida de respuesta se reconcilia sin repetir +1.
- Approved boundary: tecnología y frontera de aceptación/UX, incluida posible pérdida de trabajo provisional ante crash y pausa visible durante problemas de guardado. No pérdida de awards confirmados dentro del modelo de fallo documentado.
- Scope: diseño M0, sin implementación, paquetes ni acceso DataStores. Los casos de fallo son aceptación futura, no tests ejecutados ni prueba de durabilidad operativa. M1 debe probarlos antes de habilitar descubrimientos/persistencia jugables.

### D-018 — Alcance inicial Ground, dimensiones y capacidades

- Date: 2026-10-18
- Status: Accepted; resuelve Q-006 para lanzamiento inicial.
- Producer approval: “Aprobar Ground y estas dimensiones/capacidades (recomendado).”
- Rule: Ground solamente en M1 y lanzamiento; Upper/Basement quedan para expansión con decisión separada. Ocho parcelas con envolvente100×100 studs; grilla construible16×16 celdas de4 studs (64×64), sin confundirla con toda la envolvente.
- Initial capacities: extractor1→10→30/s, procesador10→40/s y cinta10→50/s. Starter gratuito conectado a1/s, primer extractor sustituye manual D-013. Hasta dos líneas máximas y cap60/s D-012 intactos.
- Limits: dimensiones sujetas a fit/cámara/touch con placeholders; no buffers, paquete de segunda línea o coste geométrico aprobado. Las capacidades intermedias antes propuestas quedan aceptadas; no hay caudal o suerte adicional por sectores.
- Impact: GDD§5, BALANCE§2, ROADMAP y contratos de assets M1. Validar routing de dos líneas dentro de grilla; no integrar modelo offline al runtime en M0.

### D-019 — Competición sin premios por clasificación al lanzamiento

- Date: 2026-10-18
- Status: Accepted; resuelve resto de Q-010.
- Producer approval: “Aprobar reglas actuales y sin premios por clasificación al lanzamiento.”
- Premise note (2026-10-20): D-010 no venía del GDD; D-021 la ratifica como decisión del productor. Esta decisión no cambia.
- Rule: mantener D-010 y GDD§8: títulos permanentes separados de standing por categoría/periodo, sin beneficio pagado. Sin premios materiales, pagos ni insignias de ganador por clasificación al lanzamiento. No inventar premios para recuperar texto del original.
- Impact: globales siguen gate M3/M4; M1 solo counters/local UI. Sin tareas extra de premios, otra moneda o cambios en rango.

### D-020 — Higgsfield descartado; Gemini Pro (NanoBanana) como herramienta de concepto

- Date: 2026-10-19
- Status: Accepted (decisión de herramienta); integración **no verificada**.
- Producer approval: texto literal del productor: «Scratch Higgsfield as one of our resource tools. You will be using Gemini Pro (NanoBanana) as a replacement. Please confirm you will be able to login to my Gemini account through your virtual browser and use it as an image/video generation tool whenever needed.»
- Rule: Higgsfield deja de figurar como herramienta opcional de concepto (GDD v2.0 §6 «Tool roles»). Gemini Pro (NanoBanana) ocupa ese rol para imagen/video de concepto. Sigue siendo herramienta de referencia, no dependencia de runtime ni fuente de assets finales sin revisión de procedencia/licencia (ASSET_PIPELINE «Content quality»).
- Assistant status: el asistente dispone de automatización de navegador en esta sesión (Playwright y extensión de Chrome), pero **no ha probado** iniciar sesión en Gemini ni generar una imagen. No se afirma control de la herramienta hasta una prueba supervisada registrada (M0.1-06). Riesgos a revisar en esa prueba: 2FA/captcha de la cuenta Google, términos de uso de automatización, y derechos de uso comercial de las imágenes generadas dentro de Roblox.
- Impact: ASSET_PIPELINE «Goals and ownership»; ROADMAP M0.1-06. Sin cambios de producto, balance ni código.

### D-021 — Ratificación de la competición global como decisión del productor

- Date: 2026-10-20
- Status: Accepted; cierra M0.1-03. No cambia ninguna regla: corrige su origen.
- Context: D-004, D-010, GDD.md §8 y el invariante de AGENTS §2 («Production/earnings leaderboards are separate competition categories») figuraban como «Accepted (GDD v2.1)». El GDD v2.0 no los contiene; dice «Start with a server board; defer cross-server rankings» (§2 *Ranks and displays*). D-019 ya había aprobado «reglas actuales», pero sobre la premisa equivocada de que venían del original.
- Producer approval: a la pregunta de M0.1-03 respondió «Ratificar como están (Recomendado)», frente a volver al board de servidor de v2.0 o dejar solo un ranking global de archivos.
- Rule: se mantienen D-004, D-010 y GDD.md §8 tal como están (archivos genuinos, documentos limpiados e Intel de producción; periodos UTC diario/semanal con inicio lunes/mensual/histórico; secundarios *documents processed* y *fastest first archive* con gate propio; sin premios por D-019). Su origen pasa a ser **decisión del productor D-021**, no el GDD. Supersede, solo para esta área, el «defer cross-server rankings» de v2.0.
- Impact: tabla D-001–D-010, GDD.md §8, AGENTS §2. Los boards globales siguen siendo gate M3/M4; M1 solo registra contadores y estadísticas locales. Sin código.

### D-022 — Un solo sector al lanzamiento inicial; la primera promoción no abre sector

- Date: 2026-10-20
- Status: Accepted; resuelve Q-012 y cierra M0.1-04.
- Context: GDD v2.0 §5 dice «Promotion opens a new sector and machine eligibility», §4 «Later sectors may increase Intel value and equipment capacity» y el hito M3 «Up to three sectors and floors». D-018 dejó el lanzamiento inicial en Ground solamente, pero resolvía pisos, no sectores; AGENTS §3 listaba «sector count» como bloqueante.
- Producer approval: «Diferir sectores (Recomendado)», frente a tratar sector como sinónimo de piso o dividir Ground en sectores dentro de M1.
- Rule: M1 y el lanzamiento inicial tienen **un único sector** (la parcela Ground). La primera promoción D-014 otorga el nivel de clearance 1 y el multiplicador total 1.25× de Intel ordinario, con su reset; **no** abre un sector nuevo ni elegibilidad de máquinas nuevas. Sectores adicionales y su elegibilidad de máquinas llegan con la expansión (Upper/Basement de D-018, backlog F10) y requieren otra decisión con sus valores. La probabilidad de archivo nunca depende del sector (D-011).
- Impact: GDD.md §§5–6, ROADMAP M1-08 (preview de promoción sin sector nuevo), AGENTS §3. El estado guardado conserva el nivel de clearance para que una expansión futura pueda mapearlo sin migración destructiva. Sin código ni balance nuevo.

### E-015 — Reparto de roles: Alan en 3D, el productor en código e integración

- Date: 2026-10-20
- Status: Accepted; cierra el punto abierto 1 de [RESPONSE.md](RESPONSE.md).
- Producer statement: «Alan se ocupa de los diseños y ya lo esta haciendo»; «Alan = 3d model creator, yo = coder»; «alan hace todo lo que tenga que ver con 3d y usar blender + adobe substance. el mismo lo aprueba, yo solo lo integro a este repo».
- Rule: **Alan** es el contribuidor de arte. Hace todo el trabajo 3D en Blender y Adobe Substance y aprueba la calidad visual de sus propios assets. **El productor** escribe el código e integra los assets al repo y a Studio, con ayuda del asistente. La propuesta de Codex de ejecutar el arte con scripts no se adopta. Los asistentes no juzgan la calidad visual.
- Integration check: al integrar, el productor valida solo el contrato técnico de OBJECTS.md (escala, pivotes, puertos `_Att`, presupuesto, colisión). Si algo no cumple, vuelve a Alan; el asistente no corrige la geometría.
- Impact: ASSET_PIPELINE «Goals and ownership» y M0.1-06. Alan no necesita hacer el setup del repo. Las cuentas y permisos de Roblox siguen diferidos (E-013).

### E-016 — Autorización de M1-01

- Date: 2026-10-20
- Status: Accepted (scope only)
- Producer request: «podes empezar con M1-01 y en caso que sea chico podes agarrar mas tareas. despues instalamos roblox studio».
- Impact: cierra M0.1 en lo que depende del repo y autoriza M1-01: catálogo versionado y tipos en `src/shared/Catalog.luau` con tests en Lune. Sin servicios, remotes, dependencias ni gameplay. Las tareas siguientes de M1 solo se encadenan si son chicas; una tarea que requiera un número sin aprobar (bahías, buffers) se detiene y pregunta.
- Not done: Studio sigue sin instalarse, así que la carga del módulo en el motor no está verificada.

### E-013 — Identidades diferidas y contenido desde cero

- Date: 2026-10-18
- Status: Accepted (scope and producer-reported facts).
- Producer response: responsables “no importa”; titular/publicador Roblox “tampoco importa”; contenido previo “no hay escenas, vamos a hacer todo de cero y me vas a ayudar mas adelante”.
- Impact: nombres/alias y titular Roblox no son requisitos del cierre M0 por decisión explícita. Responsabilidades funcionales ingeniería/arte se conservan en ASSET_PIPELINE. No inventar titular, grupo, cuenta ni permisos verificados.
- Verified locally: no fuentes de arte ni entradas LFS; solo build/game.rbxlx generado. Reported by producer: no escenas previas y trabajo desde cero. No prueba de restauración Studio de contenido que todavía no existe.
- Future gate: titular/destino/permisos deberán identificarse/verificarse antes de publicar/importar assets donde corresponda; publicación sigue requiriendo autorización específica. Fuentes reales y restauración de primera escena se validarán cuando existan, según ASSET_PIPELINE. No crear carpeta/manifiesto vacío ni encargar arte final ahora.

### E-014 — GDD canónico v2.0 y originales transcriptos en el repo

- Date: 2026-10-20
- Status: Accepted; resuelve Q-011 y Q-013. Supersede E-005.
- Producer approval: a «¿Existe un v2.1?» respondió «No existe, es v2.0». Sobre conservar los originales: «fijate si esto ya no esta hecho en algun documento .md […] en caso que no, fijate de sumarlo en alguno de los que tenemos o si no tiene nada que ver con ninguno, crea uno nuevo».
- Rule: el GDD canónico es *Master GDD v2.0* (15 Oct 2026). Toda cita a «v2.1», «12-page» o «section 11» en documentos del repo era un error de etiqueta y se corrige a v2.0; las del backlog original se conservan porque son texto de la fuente. Ningún documento `.md` contenía el texto de los originales, así que se crea `docs/reference/` con transcripciones textuales y el SHA-256 de cada archivo, sin subir binarios.
- Impact: AGENTS §1, README «Authority order», GDD/ARCHITECTURE/BALANCE/ROADMAP encabezados y tabla D-001–D-010. D-004 y D-010 no aparecen en v2.0; su re-trazado es M0.1-03. Sin cambios de reglas de producto, código ni balance.

## Engineering baseline for M0 (from existing validated repo setup)

| ID | Status | Decision / rationale |
| --- | --- | --- |
| E-001 | Accepted as current setup | Single Git monorepo, Rojo-managed Luau source, Roblox Studio for runtime/visuals, VS Code for editing. |
| E-002 | Accepted as current setup | `src/server`, `src/client`, `src/shared`; pinned Rokit toolchain and existing Lune/Selene/StyLua check. |
| E-003 | Accepted as current scope constraint | No external Node.js API, SQL database, Docker, compulsory dependency-injection framework or unrequested packages in M0. |
| E-004 | Accepted as team workflow | Small reviewable changes with checks; no unattended push, Studio publishing or asset upload. |

### E-005 — Original reference file retention

- Date: 2026-10-18
- Status: Superseded by E-014 (2026-10-20). The «v2.1» below is the earlier mislabel of the delivered v2.0 file.
- Context: the original Master GDD v2.1, companion Claude prompt and future-concepts workbook were supplied and inspected during the repository review.
- Producer decision: "olvidate de los archivos originales, no importa" in this chat, followed by authorization to continue the roadmap reconciliation.
- Impact: retaining, copying or linking the original files in the repository is not an M0 requirement. Continue with the working repository documentation and explicit producer decisions; no new gameplay or balance approval follows from supplying the files. The working GDD remains a summary, not a verbatim conversion.
- Alternatives: retain originals in the repository or document their external location; neither is required by the producer.
- Required review: incorporate identified summary omissions separately without changing product rules. No runtime or persistence migration.

### E-006 — First isolated M0 code increment

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "Implementemos primero un modelo offline mínimo de producción con tasas, buffers limitados y backpressure, con tests en Lune, sin integrarlo todavía al gameplay. Los valores de prueba no son balance aprobado."
- Impact: authorize the isolated continuous-quantity model and offline tests; keep M0 and all open product/balance choices unchanged. This does not authorize gameplay integration or offline player production.
- Implementation choice: fixed two-buffer line, downstream-first steps, explicit parameters and reported discarded catch-up time. These are experiment semantics, not approved gameplay timing.
- Alternatives deferred: arbitrary graphs, discrete unit eligibility, discovery, economy and full seeded balance scenarios.
- Required review: conservation, capacity/rate bounds, stalls/recovery, determinism and invalid inputs in Lune. No persistent state or migration.

### E-007 — Temporal convergence verification of the M0 model

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "verificar la convergencia del modelo al reducir el paso temporal, antes de ampliar escenarios o integrarlo al gameplay."
- Impact: three deterministic Lune fixtures (stable flow, bottleneck, blocking/recovery), shared horizon/events, conservation and buffer checks on every transition, measured error and documented tolerances. All values remain experimental fixtures.
- Implementation: compare step halvings with independent fluid solutions and two fine numerical references; retain the existing downstream-first model. Results and limits are in `BALANCE.md` section 8.
- Deferred: RNG, discoveries, economy, graphs and gameplay integration. No balance, gameplay tick or open product choice is approved. No M0/M1 gate changes.

### E-008 — Transport bottleneck verification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "verificar el modelo cuando el transporte es el cuello de botella, antes de ampliar topología o integrar gameplay."
- Impact: two deterministic Lune scenarios on the existing two-buffer line, independent analytic oracles, per-component and per-window refinement including transition increments. Results in `BALANCE.md` section 9.
- All numbers remain experimental fixtures. No gameplay, balance, RNG, economy, graph or milestone gate approval. Existing model semantics retained after verification.

### E-009 — Nonempty buffers and small downstream verification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "verificar la misma línea de dos buffers con estados iniciales no vacíos y capacidad downstream pequeña, antes de ampliar topología o integrar gameplay."
- Impact: two deterministic Lune fixtures, independent discrete/fluid oracles, component/window errors and conservation including initial inventory. Results and limitations in `BALANCE.md` section 10.
- Existing downstream-first contract retained; no defect found within this scope. Values are experimental, not approved balance. No RNG, discovery, economy, topology, dependencies or gameplay added; M0 remains open and product decisions remain pending.

### E-010 — Complete partial-buffer line verification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "Completá en una sola entrega la verificación pendiente de esta línea de dos buffers: estados inicialmente parciales, tasas de transporte y procesamiento distintas, llenado/vaciado interior y detención/recuperación."
- Impact: two grouped offline fixtures with independent analytic discrete/fluid oracles, component/window errors and conservation at every transition; results in `BALANCE.md` section 11. Existing model contract retained.
- All numbers remain experimental. No RNG, discoveries, economy, graphs, dependencies or gameplay authorized. M0 remains open; no milestone gate or pending product decision changes.

### E-011 — Documentary M0 reconciliation and simulator specification

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: "Prepará una especificación revisable del primer simulador offline de balance"; "sin implementar todavía el simulador"; "M0 sigue abierto".
- Impact: GDD §§4/8 reconcile available starter and competition rules; BALANCE §5 owns the reviewable specification and proposed deterministic first slice. No new balance or experiment semantics approved.
- Evidence: ROADMAP records the prior original-GDD review: free connected sorter/conveyor/processor at 1 unit/s and included first-extractor connection capacity. Exact connection scope and additional competition presentation/reward wording are unavailable (Q-010). E-005 removes file retention requirements, not this evidence gap.
- Alternatives: invent missing details or preserve their unresolved status; use the latter. No code, fixtures, contract, dependencies, gameplay or migration changes.
- Required review: documentation consistency and local checks; later implementation requires separate scope.

### E-012 — Autorización del simulador completo offline y cierre secuencial de M0

- Date: 2026-10-18
- Status: Accepted (scope only)
- Producer request: “Este pedido autoriza implementar el simulador offline necesario, incluyendo modelos experimentales de economía y descubrimiento. No autoriza trasladarlos al runtime.”
- Impact: supersede los límites de autorización de E-011 para implementar el harness; primero verificar runner determinista, después economía/descubrimiento con pruebas incrementales. D-011/D-012 permanecen aprobadas; los demás números siguen siendo hipótesis.
- Gates: completar/verificar cada uno de los cinco pasos antes del siguiente, commit y push normal a rama/remoto verificados y comprobar CI. Autorizados aquí; sin force-push, merge, publicación ni DataStores.
- Restrictions: no dependencias ni cambio de Production/contrato sin consulta previa. Resolver decisiones de producto con respuesta explícita; silencio no es aprobación.
- Current: runner y descubrimiento experimental verificados localmente; Q-010 starter resuelta por D-013; runner/economía/descubrimiento implementados y corridas documentadas en BALANCE §13. Sin aprobación implícita de precios, pacing, rangos o promoción.

## Open producer choices — do not silently implement

| ID | Status | Question / alternatives | Why it matters |
| --- | --- | --- | --- |
| Q-001 | **Resolved — D-011** | Fixed p=0.00001 with mandatory H=200000 work guarantee, identical first/subsequent rules. | Prior pure-random / H=300000 alternatives superseded |
| Q-002 | **Resolved — D-015** | Target median, p90 and p99 time-to-first archive; expected sustained waits at starter/mid/endgame; acceptable session length? | Early retention and avoiding trivial late-game rarity |
| Q-003 | **Resolved — D-012** | Total 60 eligible documents/s per player/factory, manual + automatic across all floors/sectors. | At most two maximum-capacity lines; visible global restriction |
| Q-004 | **Resolved — D-016** | Accept/revise rank thresholds and names (0/1/5/15/40/100)? | UI and long-run status progression |
| Q-005 | **M1 resolved — D-014** | First: 100k processed/50k Intel, grant100, total1.25. Second promotion remains unapproved/outside M1. | Economy, save resets and migrations |
| Q-006 | **Resolved — D-018** | Initial launch Ground only; dimensions/capacities approved; Upper/Basement expansion separately. | Asset and load budgets |
| Q-007 | **Resolved strategy — D-017; M1 tests pending** | Native UpdateAsync, serial queue/session fencing, bounded 5s checkpoint target, private natural plan, atomic cursor/grant/outbox and ack before reveal. | Preventing duplicate/lost rare awards |
| Q-008 | Open — before broader content | Optional assignments (F02), manual tools (F01), value-added paper (F03), splitter/merger routing (F08)? Any other backlog F-ID also needs its own decision. | New gameplay mechanics require explicit scope authorization |
| Q-009 | **M0 resolved scope — E-013** | Functional responsibilities and source-preservation workflow; no existing scenes. Names/Roblox owner deferred by producer; verify before future publication. Final budgets after first placeholder handoff/measurements. | Reproducibility and two-person work |
| Q-010 | **Resolved — D-013/D-019** | Starter replacement on free1/s lane; documented competition rules and no classification prizes at launch. | The prior review identifies omissions without preserving their full wording; do not invent prizes or additive throughput. |
| Q-011 | **Resolved — E-014** (no existe v2.1) | ¿Cuál es el GDD canónico? El archivo entregado el 2026-10-19 es *Master GDD v2.0* (9 páginas, 8 secciones); el repo y el backlog citan «v2.1». ¿Existe v2.1? | Toda la trazabilidad de D-001–D-010 y de GDD.md depende de esto. Ver [contraste](history/source-contrast-2026-10-19.md). |
| Q-012 | **Resolved — D-022** (un sector al lanzamiento; la promoción 1 no abre sector) | «Sector» vs «piso»: GDD v2.0 §5 dice que la promoción abre un nuevo sector y elegibilidad de máquinas; GDD.md §5 dice que la primera promoción en M1 no desbloquea sector ni caudal. ¿Cuántos sectores hay en lanzamiento y qué abre la primera promoción? | AGENTS §3 lista «sector count» como bloqueante; D-018 resolvió pisos, no sectores. Afecta M1-08 y preview de promoción. |
| Q-013 | **Resolved — E-014** (transcripciones en `docs/reference/`) | ¿Entran los tres originales (o su texto) al repo bajo `docs/reference/` con hash? GDD §8 pide conservar el GDD en el repositorio; E-005 lo marcó como no requerido. | Sin el original en el repo, las revisiones futuras no pueden trazar reglas. |

## Remaining scope gates

D-011–D-022/E-013–E-015 resolve the blocking M0 and M0.1 product/strategy choices. The completed
exit-gate audit and ordered M1 tasks are in ROADMAP; M1 has not been authorized. M1 still needs
separate authorization and measured acceptance; later promotion/expansions/new
mechanics remain unapproved. Roblox ownership/permissions and final art budgets are
future asset/publication gates, explicitly deferred by E-013, not invented approvals.

## Decision entry template

```markdown
### D-021 — <short title>
- Date: YYYY-MM-DD
- Status: Proposed | Accepted | Superseded
- Context: ...
- Alternatives: ...
- Producer decision and reference: ...
- Impact: ...
- Required tests/migrations: ...
- Supersedes: ...
```
