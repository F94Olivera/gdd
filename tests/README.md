# Tests

`lune run tests/smoke.luau` verifica el contrato mínimo del proyecto sin frameworks.
Lune no ejecuta el motor Roblox. Al agregar reglas puras, cubrirlas con asserts
bajo Lune; si necesitan APIs de Roblox, probarlas en Studio. No simular el motor.
Antes de integrar: Studio → Test → iniciar servidor con 2 clientes; verificar
Output, replicación, aislamiento y rechazo de solicitudes malformadas.

## Modelo mínimo de producción M0

Ejecutar `lune run tests/production.luau` o el check completo
`lune run scripts/check.luau`. El módulo puro está en
`scripts/models/Production.luau`, fuera del árbol Rojo y sin integración de gameplay.

Contrato experimental: `step(config, state, elapsedSeconds)` devuelve estado nuevo,
cantidades aceptadas/transportadas/procesadas y segundos simulados/descartados.
Tasas en unidades/segundo; capacidades y ocupación en unidades continuas, incluso
fracciones. Todos los parámetros son explícitos, finitos y no negativos; el límite
de paso debe ser positivo. No modifica las entradas. Las capacidades cero bloquean
el almacenamiento correspondiente; transporte cero representa una ruta detenida.

Cada paso procesa material existente, transporta al espacio liberado y acepta
entrada nueva al buffer de salida. El material recién llegado espera otro paso
para la siguiente etapa. No se acumula capacidad de trabajo no utilizada durante
atascos. El tiempo excedente al límite se descarta y se devuelve al llamador; no hay
reloj, scheduler ni recuperación automática de ese tiempo. El resultado depende
de la partición temporal: usar pasos pequeños y comparar convergencia antes de
extraer conclusiones de balance. No es un modelo de flujo continuo exacto.

Los siete casos originales cubren fracciones/orden/inmutabilidad, tiempo cero, saturación y
recuperación, capacidades cero/ruta detenida, catch-up limitado, conservación y
repetibilidad durante 2000 pasos con atascos, y rechazo de entradas inválidas.
Los números son fixtures arbitrarios, **no balance aprobado**. No hay RNG,
archivos, elegibilidad, Intel, identidades de unidades, grafos editables, sesiones,
upgrades ni persistencia. Las cantidades aceptadas todavía no constituyen eventos
de descubrimiento. Estos tests no completan T-001–T-006 ni el simulador de balance
sembrado de M0, y no demuestran comportamiento del motor Roblox.

## Refinamiento temporal M0 (2026-10-18)

La misma suite agrega tres casos de convergencia. Ver fixtures, soluciones
analíticas, métrica, tabla de errores y límites en
[`docs/BALANCE.md`, sección 8](../docs/BALANCE.md#8-verificación-del-paso-temporal-m0-2026-10-18).
El comando imprime `REF` y `REFINE` para reproducir las mediciones; diez casos en total.

Cada escenario parte vacío y cubre 20 s. Se comparan cinco pasos máximos
(0.5, 0.25, 0.125, 0.0625, 0.03125 s), más referencias de 1/1024 y 1/2048 s.
Se recortan pasos en observaciones y eventos compartidos; nunca se desplaza un
evento ni se descarta tiempo por el cap. Esta es una política del harness de tests,
no un scheduler agregado al modelo. No equivale a usar pasos uniformes sin cortes.

En **cada transición de cada ejecución**, incluidas ambas referencias, se verifican
capacidades, tasas, segundos simulados/descartados y balances por buffer y acumulados.
Se exige error máximo <= `8*h + 1e-8` unidades frente al límite analítico y reducción
por factor <= 0.6 en cada refinamiento. `1e-8` cubre redondeo en estos fixtures;
no admite pérdida sistemática de material. Los controles analíticos terminales y
las comprobaciones de bloqueo/recuperación usan esa misma tolerancia absoluta.
No se infiere convergencia universal ni se aprueba el tick propuesto de gameplay.

## Transporte limitante (2026-10-18)

Dos casos adicionales (12 en total) prueban transporte a 2/s con entrada y
procesamiento a 4/s, constante o detenido/reanudado. Misma línea, sin gameplay.
Ver [BALANCE, sección 9](../docs/BALANCE.md#9-transporte-limitante-y-detenido--m0-2026-10-18)
para derivación del oráculo, pasos, ventanas, tolerancias, mediciones y limitaciones.
`TRANSPORT` imprime errores por cantidad; `WINDOW` imprime errores absolutos y
de incrementos por ventana para que arranque y estado final no oculten transiciones.
No requieren Studio: el módulo está fuera del árbol Rojo. Lune prueba toda la
aritmética involucrada; estos resultados no verifican motor, red, touch ni carga.

## Inventario inicial y capacidad pequeña (2026-10-18)

Dos casos más (14 en total) verifican drenaje y buffers llenos con parada/reinicio,
K=1/16 y pasos 1/4 a 1/256 sobre 6 s. Observaciones cada .5 s no recortan ningún
paso. Ver [BALANCE, sección 10](../docs/BALANCE.md#10-inventario-inicial-y-downstream-pequeño--m0-2026-10-18)
para fórmulas discretas/fluidas independientes, resultados, ventanas y tolerancias.
`INITIAL` imprime errores abs/delta por componente y ventana. Se exige el perfil
analítico de errores, sin asumir reducción estricta: el caudal discreto es
min(2,K/h), y coincide con el fluido desde h=1/32 solo para estos fixtures.
Cada transición verifica además oráculo discreto, conservación con inventario
inicial, tasas, capacidades y tiempo. No cambia el contrato ni el alcance M0.

## Parciales y tasas distintas (2026-10-18)

Dos casos agrupados más (16 en total) completan la verificación pendiente de la
línea: llenado/parada/recuperación/drenaje y vaciado interior con b distinto de p.
`PARTIAL` muestra errores abs/delta O,Q,A,T,P por seis ventanas y el número de
transiciones. Se reutilizan `near`, `test` y `fields`; no se refactoriza la suite.
Ver [BALANCE §11](../docs/BALANCE.md#11-buffers-parciales-y-tasas-distintas--m0-2026-10-18)
para fixtures, derivación analítica discreta/fluida, particiones distintas,
resultados, tolerancias y evaluación de suficiencia. El contrato no cambia.
Todas las transiciones verifican inventario inicial, conservación, capacidades,
tasas y tiempo. Studio/multiplayer/touch no ejecutados: aritmética fuera de Rojo.


## Catálogo M1-01 (2026-10-20)

`lune run tests/catalog.luau` (incluido en el check) prueba `src/shared/Catalog.luau`:
valores aprobados con su decisión (D-011, D-012, D-014, D-016, D-018, D-022),
inmutabilidad en todos los niveles, fronteras de rango 0/1/4/5/14/15/39/40/99/100 y
un millón, rechazo de conteos inválidos (negativo, fracción, NaN, infinito, string)
y 25 definiciones rotas que `Catalog.validate` debe rechazar con un mensaje concreto.
El smoke comprueba que el módulo llega como `ModuleScript` a `ReplicatedStorage.Shared`.
Es aritmética pura: no prueba que Studio cargue el módulo (pendiente hasta instalarlo).

## Ledger de producción M1-02 (2026-10-20)

`lune run tests/productionLedger.luau` (incluido en el check) prueba
`src/server/ProductionLedger.luau`: paridad exacta con `Production.step` de M0 en
2000 casos pseudoaleatorios; dos líneas de referencia 30/50/40 a 5 Hz con buffers de
50 sostienen 60/s exactos, también con updates de catch-up de 2 s; frames irregulares
de 5 a 410 ms dan el mismo caudal; prioridad estable por ID bajo el tope compartido;
rechazo de una tercera línea máxima; el clearing manual comparte el tope; sin
acumulación tras un atasco; fracciones que sobreviven entre updates; tope de 600
provisionales con confirmación solo hacia adelante; y entradas inválidas. En cada
update verifica IDs contiguos sin repetición, conservación y capacidades.
Aritmética pura: no prueba el reloj ni la carga en Studio.

## Harness de balance autorizado

`lune run tests/balanceRunner.luau` prueba sesiones/reconexión sin catch-up,
eventos en fronteras no alineadas, conservación por transición, presupuesto global,
rechazo de tercera línea máxima declarada, entradas inválidas y tiempo descartado.
`lune run tests/discoveryExperiment.luau` prueba vector Park–Miller, garantía,
reset, continuidad en chunks y flujo natural común entre políticas.
Ambos están incluidos en `scripts/check.luau`. No agregan fixtures al modelo
Production ni prueban persistencia. Comandos/resultados y límites en BALANCE §12;
`tests/economyExperiment.luau` cubre economía condicionada, fracciones, reset,
reconexión, censura y aceleración de estado fijo. También se ejecuta en el check.
Resultados del simulador completo en BALANCE §§13–14; pacing aprobado D-015
y escenario E10 repetido. Tests offline pasan; la aceptación de motor/servicios no
se deduce de esos resultados. P-001–P-012 siguen pendientes de M1.
