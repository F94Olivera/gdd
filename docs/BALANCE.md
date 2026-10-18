# Balance and simulation specification

**Version:** working specification from Master GDD v2.1, updated by producer decisions D-011–D-019 on 2026-10-18.
**Approval state:** p/H/cap/reference capacities (D-011/D-012), starter substitution
(D-013), original prices/first promotion (D-014), pacing targets (D-015) and permanent
titles (D-016) are approved. D-018 approves intermediate machinery rates and Ground/dimensions. Buffers,
session/delay, second-line bundle and geometry assumptions remain experimental. Offline evidence in §§12–14 is not runtime or playtest verification.

## 1. Approved discovery and analytical reference

| Parameter | Approved rule | Source |
| --- | --- | --- |
| Probability per fresh eligible clearing | p=0.00001 (0.001%) | D-011 |
| Work guarantee | After 199999 consecutive failures, next eligible unit guarantees one genuine archive (H=200000) | D-011 |
| First/subsequent finds | Same p/H; no decreasing H after unlucky streaks | D-011 |
| Probability modifiers | None for source, upgrades, promotions, sector, archive count or throughput | D-011 |
| Counter | Genuine find resets to zero; persists through sessions/disconnects/layout edits/promotions; demo has no effect | D-011 |
| Blocked/offline | No accepted clearing means no opportunity; no offline production/counter progress | D-011 |
| Ranked reward | Exactly +1 per genuine find, with ordinary output/payment additional | D-001/D-002 |

Pure random is a **counterfactual control only**, with E[N]=1/p=100000.
For the approved guarantee, N=min(geometric(p),H):

```text
E[N] = (1 - (1 - p)^H) / p
```

At p=1e-5, H=200000: **E[N]=86466.607012**, maximum **200000**
eligible units from zero failures. The prior H=300000 proposal is superseded.
These are analytical calculations, not simulator/player-session measurements.

| Sustained eligible throughput | Mean time | Work cap expressed as time at that constant rate |
| --- | --- | --- |
| 1/s | ~24.02 hours | ~55.56 hours |
| 10/s | ~2.402 hours | ~5.556 hours |
| 30/s | ~48.04 minutes | ~1 h 51 min 7 s |
| 60/s (approved total launch cap) | ~24 min 1 s | ~55 min 33 s |

At 60/s, steady output is 3600/min or 216000/hour. At 1 Intel per processed
unit, this is 216000 Intel/hour before multipliers, assuming equal sustained
secure processing. Startup, finite queues, building time, blockages and absence
change actual rates/waits. The guarantee is not a maximum calendar wait. No fake
rewards, hidden nerfs or additional archive rarity tiers may conceal slow pacing.

## 2. Initial M1 economy — D-014

**Base ordinary income**: secure processing pays one Intel per original ordinary output unit before approved clearance multipliers. A genuine archive is additional and does not change this ordinary payment.

| Upgrade / item | Approved incremental Intel cost | Capacity/effect (D-012/D-018) |
| --- | ---: | --- |
| Free starter lane | 0 | 1 manual cleared unit/sec with connected output |
| Extractor | 30 | 1 automatically cleared unit/sec |
| Basic processor | 60 | 10 processed units/sec |
| Extractor tier 2 | 120 | Increases extractor to 10 units/sec |
| Extractor tier 3 | 600 | Increases extractor to 30 units/sec |
| Processor tier 2 | 350 | Increases processor to 40 units/sec |
| Belt segment | 5 | 10 transported units/sec |
| Belt upgrade | 25 | Increases belt to 50 units/sec |

Original prices are **approved as the initial M1 candidate by D-014**; ×2/×5 are experimental alternatives, not selected. D-012 approves the reference capacities: extractor Tier 3 30/s, upgraded conveyor 50/s and processor Tier 2 40/s; two such lines sustain 60/s total when unblocked. The global cap includes all manual/automatic clearing. Intermediate rates are approved by D-018 (starter baseline: GDD §4). Treat belt cost as per segment; machine upgrades as incremental prices. No off-by-one rounding exploits or extra archive-roll units from faster processors.

## 3. Initial M1 progression — D-014/D-016

| Clearance level | Requirements/status | Ordinary Intel multiplier | Reset and retention |
| --- | --- | --- | --- |
| 0 | Starter | 1.00× | No reset |
| 1 (approved D-014) | 100,000 lifetime ordinary units processed, 50,000 spendable Intel, completed tutorial/equivalent | 1.25× | Reset spendable Intel to 100 and restore free lane; preserve archive total/counter |
| 2 (unapproved, outside M1) | 250,000 lifetime ordinary units processed, 100,000 spendable Intel | 1.50× total | Same voluntary reset policy |

Only the first total multiplier 1.25 is approved. Formula `1 + 0.25 * clearanceIndex` remains a later-promotion proposal. Do not add another currency or use lifetime archive count as an unlock requirement. Promotions are confirmed explicitly by the player and idempotent on server.

| Lifetime archives | Approved permanent title (D-016) |
| ---: | --- |
| 0 | Trainee |
| 1 | Archive Finder |
| 5 | Investigator |
| 15 | Senior Investigator |
| 40 | Archive Specialist |
| 100 | Director of Archives |

These are milestone titles, not archive count caps. **Thresholds and titles approved by D-016.**

## 4. Load, tick and visual budgets

| Parameter | Proposed value | Caveat |
| --- | --- | --- |
| Server production updates | 5 Hz | Use elapsed-time fractional accumulators |
| Max catch-up time per update | 2 seconds | Record discarded elapsed time |
| Maximum moving paper visuals per client | 240 | Representative visuals, not one per unit |
| Owner plot visual sub-budget | 120 | Device-dependent |
| Nearby other plot sub-budget | 30 per plot | Adaptive LOD |
| Production graph load target | 8 plots × 60 nodes | Requires realistic playtest |
| p95 production tick | under 10 ms | Not benchmarked |
| Mobile / desktop | 30 / 60 FPS | Must name and record tested devices |

## 5. Simulation harness required during M0

**Especificación de referencia — 2026-10-18.** El pedido posterior del productor
autoriza el simulador completo offline, incluida economía y descubrimiento.
El avance ejecutado y sus límites están en §12; los límites del «primer slice»
siguientes describen la secuencia original, no restringen esa autorización posterior.
Esta sección es la única especificación del harness; §§8–11 conservan evidencia
histórica del modelo, no nuevos requisitos de fixtures. “Offline” significa una
herramienta local, nunca producción del jugador mientras está desconectado.

### Alcance y estados de autoridad

- **Reglas aprobadas:** clearing fresco como única elegibilidad, buffers limitados,
  backpressure, pago ordinario independiente de un hallazgo, sin producción durante
  ausencia, promociones sin requisito aleatorio y garantía obligatoria con contador
  persistente. p=0.00001, H=200000 y cap global=60/s están aprobados. Fuentes:
  GDD §§2–8 y DECISIONS D-001–D-012.
- **Hipótesis:** números no aprobados de §§2–4, duraciones/sesiones/buffers y políticas de
  compra de esta sección. Cada candidato debe identificarlas; no son defaults de gameplay.
- **Productor pendiente:** Q-006/Q-007, segunda promoción Q-005 y parte competición Q-010. Q-002/Q-004 y primera promoción Q-005 resueltas por D-014–D-016. Pure-random solo como control contrafactual, no política candidata.
  El primer slice propuesto abajo no necesita resolver rareza ni economía.

### Entradas y contrato del experimento

Cada manifiesto versionado debe incluir `scenarioId`, `modelVersion`,
`balanceVersion`, revisión Git y estado dirty, versión de Lune, unidades,
horizonte calendario, paso máximo h, límite de catch-up, observaciones y eventos.
Tasas en unidades/s y capacidades/ocupaciones en unidades; tiempos en segundos.
Todos los valores finitos, tasas/capacidades no negativas, h y cap positivos;
ocupaciones iniciales dentro de capacidad. Rechazar IDs duplicados, ventanas
solapadas, eventos fuera de horizonte y cambios que dejen inventario sin capacidad.

| Entrada | Definición requerida |
| --- | --- |
| Línea y tasas | Primera versión: solo salida → transporte → procesamiento, usando el contrato actual de Production; c,b,p constantes por tramo, estado inicial O,Q y capacidades explícitas. Topologías arbitrarias quedan para otro alcance. |
| Sesiones | Intervalos online [inicio,fin), actividad manual dentro de ellos y calendario completo. Fuera de sesión no ejecutar pasos ni producir; conservar O,Q al regresar, sin catch-up de la ausencia. No equivale a persistencia real. |
| Bloqueos | Intervalos con transporte o procesamiento en cero; distinguirlos de ausencia, falta de actividad y catch-up descartado. No recuperar trabajo perdido ni acumular capacidad de servicio. |
| Upgrades | Lista de eventos programados con tasas/capacidades antes/después, sin reducción destructiva. En primer slice son cambios exógenos, nunca compras simuladas. |
| Economía futura | Precios incrementales de §2, Intel inicial, pago por unidad procesada y política ordenada de compras/ahorro, prerrequisitos, demora de decisión y coste de conexión explícitos. Reportar compra imposible; no inyectar Intel para desbloquearla. Fuera del primer slice. |
| Descubrimiento futuro | p=0.00001, garantía H=200000 (control pure-random etiquetado aparte), contador inicial, regla de unidades enteras y tratamiento de fracciones. Ningún roll por transporte/procesamiento o inventario inicial. Fuera del primer slice. |
| Promoción futura | Evento voluntario condicionado a producción/Intel, fee, grant y reset propuestos de §3; registrar descarte confirmado de inventario y retención del contador. Fuera del primer slice. |

Orden propuesto del harness: cerrar el tramo anterior, aplicar límites de sesión,
aplicar eventos de configuración en orden estable por ID y observar el estado.
Los eventos coincidentes deben tener orden registrado y no contradecirse. Cortar
pasos en eventos, observaciones y fin de sesión; tasa nueva desde el evento. El
harness conserva downstream-first, cantidades fraccionarias y tiempo descartado
del contrato actual. No modificar Production ni interpretar accepted como un
hallazgo o una identidad de unidad. En una fase futura, documentar conversión de
accepted acumulado a elegibilidad entera sin redondeos por paso antes de usar RNG.

### Escenarios representativos propuestos

Valores siguientes: **fixtures de exploración**, no objetivos aprobados. Usar
O=Q=0, capacidades (5,3), h=1/32 s y cap=2 s salvo variante declarada. El h es
experimental, no el tick de gameplay. No añadir estos casos a la suite existente
hasta implementar el harness autorizado; no hacen falta más pruebas vecinas de la línea.

| ID | Sesión/horizonte y eventos | Pregunta que debe responder |
| --- | --- | --- |
| S1 starter | 600 s online, c=b=p=1 | Caudal efectivo frente al starter nominal, retardo de arranque y backlog; no presume compra ni capacidad adicional del extractor. |
| S2 progresión exógena | 1200 s online; (c,b,p)=(1,10,10), c=10 en 120 s, c=30 en 300 s, p=40 en 600 s, b=50 en 900 s | Separar demanda nominal, cuello de transporte/procesamiento y efecto marginal de cada cambio. Tiempos de upgrade arbitrarios, no asequibilidad medida. |
| S3 interrupción | S2 con b=0 en [200,260), p=0 en [400,460) | Tiempo bloqueado, inventario retenido y recuperación sin trabajo acumulado. |
| S4 sesiones cortas | Horizonte 86400 s; online [0,300), [3600,3900), [82800,83100); c=b=p=1 | Comparar 900 s online con S1 extendido a 900 s; ninguna producción en las ausencias. |
| S5 sensibilidad | S2 con capacidades (1,1), (5,3), (50,30); repetir h/2 | Efecto de buffers y discretización; no confundir K/h con balance real (§10). |
| S6 techo aprobado, posterior | 3600 s online; dos líneas independientes con (c,b,p)=(30,50,40) cada una; buffers experimentales (50,30) por línea | Verificar 60/s agregados sin bloqueo y backpressure por línea. Dos instancias de la línea, no grafo nuevo; presupuesto compartido manual/automático requiere contrato aparte. |

La fase posterior compara S1–S6 con compras condicionadas (en vez de upgrades
exógenos), ausencia, bloqueo, reconexión y promoción explícita. Incluir pruebas del
cap agregado: demanda manual + automática >60/s y configuraciones alternativas;
rechazar una tercera línea máxima sin cambiar p. El reparto entre fuentes y
contabilidad del presupuesto requieren contrato explícito antes de implementar. No sumar manual y
extractor ni fijar conexión del primer extractor hasta resolver Q-010. Añadir al
manifiesto un horizonte suficientemente largo para medir colas de rareza; no
extrapolar percentiles a partir de 600 s ni asumir caudal pico permanente.

### Métricas y resultados reproducibles

Primer slice: A,T,P acumulados; O,Q; conservación; tiempo solicitado/simulado/
descartado y calendario/online/manual activo separados. Caudal nominal y medido
por sesión/tramo: A/segundos online y P/segundos online; publicar denominadores.
Registrar déficit c*dt−accepted, tiempo con aceptación inferior a demanda (c>0),
ocupación media ponderada por tiempo, máxima y fracción de tiempo lleno por buffer.
Etiquetar paradas programadas separadamente; no llamar “bloqueo” a c=0 ni ausencia.
Comparar escenario base y variante por ventana, no solo estado final.

Fase futura: tiempos de primera automatización/compra útil, saldo y compras
inalcanzables sin suerte; primer hallazgo, gaps posteriores, unidades elegibles,
contador, hallazgos y títulos según umbrales candidatos. Reportar mediana/p90/p99
en tiempo calendario, online y actividad manual (esta última no incluye clearing
automático), desde el primer clearing aceptado. Separar primera búsqueda de gaps
sostenidos y declarar censura: si un percentil no se observa dentro del horizonte,
reportar “no alcanzado”, fracción sin hallazgo y denominador; nunca calcularlo solo
sobre quienes encontraron. Publicar incertidumbre/método estadístico y no presentar
la garantía por unidades como límite de tiempo real.

Artefactos previstos: manifiesto completo legible por máquina, serie temporal por
observación/evento, resumen por escenario y, en fase aleatoria, agregados y datos
por corrida. Orden estable, unidades y precisión explícitas, sin timestamps variables
en archivos comparados. Registrar comando exacto, revisión/configuración y esquema
de salida. No hay aún comando del simulador ni artefactos de resultados: no inventarlos.

Primer slice determinista: semilla `no aplicable`; repetir debe producir archivos
idénticos en el mismo entorno. Fase RNG futura: fijar algoritmo y versión, semilla
maestra y derivación por (escenario, cohorte, índice de corrida), sin RNG global ni
reloj; guardar la lista de semillas y permitir repetir una corrida. Comparar ambas
políticas con las mismas secuencias naturales; un hallazgo garantizado no debe
consumir aleatoriedad extra que desplace la comparación. No usar Random de Roblox
en el harness Lune. Selección de algoritmo e implementación requieren otro slice.

Por versión candidata y escenario/política aleatoria: al menos **100000 corridas**
(objetivo GDD), tamaño muestral y horizonte publicados. Contrastar distribución
geométrica y truncada con §1, incluyendo contador 199999 → garantía en siguiente unidad, reset a cero y mismas
reglas para primer/siguientes hallazgos. No hay mediciones nuevas en esta revisión;
la aprobación de p/H proviene de D-011.

### Primer slice implementable y aceptación propuesta

**Próxima implementación para revisión, no realizada aquí:** runner Lune local,
manifiestos S1–S5 y exportación determinista de producción/sesiones/eventos/métricas,
reutilizando Production sin cambiar su contrato. Sin RNG, descubrimientos, economía,
grafos, dependencias, runtime ni nuevas fixtures de convergencia. Ubicaciones propuestas:
`scripts/` para runner y entradas; salida generada bajo `build/`; tests del runner
solo para semántica nueva de sesiones/eventos/exportación. No crear esos archivos ahora.

1. Entradas inválidas fallan antes de emitir resultados; manifiesto completo permite
   repetir exactamente cada ejecución y su orden de eventos.
2. Cada transición conserva O_anterior+A=O_nuevo+T y Q_anterior+T=Q_nuevo+P,
   capacidades, límites de tasa y dt solicitado=simulado+descartado. Tolerancia
   absoluta propuesta 1e-6 unidades por corrida de hasta 1200 s en S1–S5;
   justificarla con error observado y escala, sin reutilizar automáticamente 1e-8
   de los fixtures cortos. No admite pérdida sistemática ni inventario negativo.
3. Ausencias producen cero A,T,P y cero tiempo simulado/descartado; el inventario
   se conserva. S4 coincide con su control online de 900 s a igual partición activa.
4. Eventos ocurren en su frontera exacta; no hay servicio acumulado en bloqueos.
   Métricas derivadas cuadran con series y denominadores; todo descarte es visible.
5. Repetir entradas produce salida idéntica. Sensibilidad h/h2 se publica por tramo;
   diferencias se explican con orden/capacidad (§§8–11), sin afirmar una cota universal.
   Una diferencia sin explicación impide usar el escenario para decidir balance.
6. Pasan check local y diff check. El informe declara herramientas y límites, sin
   afirmar validación Studio, rendimiento de ocho plots o balance aprobado.

Ese slice **no completa** el simulador sembrado ni cierra M0. Fases posteriores
necesitan autorización separada para economía/elegibilidad/RNG y validación de
sus contratos; después, resultados reales permiten resolver Q-002 y validar el
pacing de D-011/D-012, sin reabrir decisiones aprobadas por defecto.

## 6. Revision log (initial)

| Revision | Date | Source | Result |
| --- | --- | --- | --- |
| `GDD-2.1-proposal` | 2026-10-15 | Original Master GDD v2.1 | Hypotheses transcribed; no simulation conducted as part of this documentation task |
| `producer-2026-10-18-D011-D012` | 2026-10-18 | Explicit producer attachment, recorded in DECISIONS | Approved p/H and launch cap/reference capacities; analytical checks only, no seeded simulation |

## 7. Producer sign-off required

Q-001 and Q-003 are resolved by D-011/D-012. D-014–D-016 resolve initial M1 prices/promotion, experience targets and titles explicitly. Later promotion remains outside M1; Q-006/Q-007 and remaining asset/competition choices still require resolution.

## 8. Verificación del paso temporal M0 (2026-10-18)

**Medición experimental, no balance aprobado.** Modelo: `scripts/models/Production.luau`,
orden downstream-first conservado. Reproducción: `lune run tests/production.luau`
con Lune 0.11.0. No RNG, descubrimientos, economía, grafos ni gameplay.

Fixtures: estado inicial vacío; horizonte 20 s; capacidades `(output, processing)=(5,3)`.
Tasas `(clearing, transport, processing)` en unidades/s:

| Escenario | Tasas y eventos |
| --- | --- |
| Flujo estable | `(2,4,4)`, constantes |
| Cuello de botella | `(4,3,2)`, constantes |
| Bloqueo/recuperación | `(4,3,2)`; procesamiento 0 en `[4.375,9.625)` s y 2 después |

Se observa cada 0.5 s, además de 4.375, 9.625 y 9.75 s (43 observaciones).
Todos los pasos se cortan en esos tiempos, incluidos los eventos que no coinciden
con la grilla gruesa. El nuevo valor de tasa rige desde el evento, nunca antes.
El cap se iguala a h; no hay tiempo descartado. Se controla conservación local y
acumulada, no negatividad, capacidades y límites de tasas en cada transición,
incluidas las referencias finas. Los siete tests anteriores se conservan.

**Referencia independiente:** límite fluido con residencia cero, utilizado solo como
oráculo matemático de estos fixtures. Flujo estable: `A=T=P=2*t`, `O=Q=0`.
Para el cuello: `P=2*t`, `Q=min(t,3)`, `O=t` hasta t=3 y
`O=min(2*t-3,5)` después; `T=P+Q`, `A=P+Q+O`.
En el bloqueo ambos buffers ya están llenos: usar esas mismas fórmulas con tiempo
activo `t-clamp(t-4.375,0,5.25)`. Esto no postula tiempos de viaje de gameplay.

**Error:** máximo absoluto sobre las cinco cantidades `(A,T,P,O,Q)` y las 43
observaciones, en unidades. Además se comparan ejecuciones consecutivas y una
referencia numérica h=1/1024 s, contrastada con h=1/2048 s y con el límite analítico.
En los tres escenarios se observó la misma envolvente máxima:

| Paso máximo h (s) | Error al límite analítico | Error a referencia 1/1024 | Diferencia al paso anterior |
| ---: | ---: | ---: | ---: |
| 0.5 | 2 | 1.996093750 | — |
| 0.25 | 1 | 0.996093750 | 1 |
| 0.125 | 0.5 | 0.496093750 | 0.5 |
| 0.0625 | 0.25 | 0.246093750 | 0.25 |
| 0.03125 | 0.125 | 0.121093750 | 0.125 |

La separación entre referencias es 0.001953125 unidades en cada escenario;
sus errores al límite son 0.00390625 y 0.001953125. Por eso la referencia fina no
se presenta como exacta. Los errores máximos coinciden porque el retardo inicial
común domina la norma; esto no significa que las trayectorias sean iguales.

**Tolerancias:** comparación algebraica/conservación absoluta de `1e-8` unidades
para redondeo de estos tamaños y horizontes. Para refinamiento se exige `E(h)<=8*h+1e-8`:
envolvente conservadora de dos pasos de retardo por la tasa máxima del fixture
(4 unidades/s), no una cota demostrada para cualquier configuración. Se exige además
`E(h/2)<=0.6*E(h)+1e-8`: margen explícito frente al factor 0.5 esperado de error
lineal; no basta aprobar solo una tolerancia final amplia. Las referencias también
se comprueban contra la envolvente analítica correspondiente.

**Orden y limitaciones:** en flujo estable, al final `O=Q=2*h`, `T=40-2*h`,
`P=40-4*h`, `A=40`; el cuello también termina con `P=40-4*h`, `O=5`, `Q=3`.
El orden impide atravesar dos etapas en un paso, pero permite reutilizar espacio
liberado aguas abajo durante ese paso. Produce un retardo artificial que desaparece
al reducir h; no representa una latencia física fija. Los tres fixtures muestran
convergencia de primer orden en puntos compartidos, sin defecto que requiera cambiar
el modelo. La recuperación comprueba 0.25 unidades procesadas y aceptadas entre
9.625 y 9.75 s, sin trabajo acumulado durante el bloqueo.

No hay prueba general para cualquier tasa/capacidad, pasos grandes, estados iniciales,
eventos entre observaciones, tasas variables continuas, horizontes largos ni otro
orden de actualización. Capacidades cero y tiempo descartado mantienen sus tests
anteriores, pero quedan fuera de este experimento de convergencia. Cambiar el
muestreo también cambia la partición y puede cambiar el error. No se selecciona
un paso de producción ni se valida el 5 Hz propuesto. El siguiente incremento seguro
es contrastar otros regímenes de esta misma línea (por ejemplo transporte limitante)
con oráculos independientes antes de ampliar topología o integrar gameplay.

## 9. Transporte limitante y detenido — M0 (2026-10-18)

**Fixtures experimentales; no balance aprobado.** Misma línea de dos buffers,
capacidades `(5,3)`, inicio vacío y horizonte 20 s. Tasas `(c,b,p)=(4,2,4)`.
Segundo escenario: transporte cero en `[11/8,37/8)` s, luego vuelve a 2/s;
el procesador sigue funcionando durante la detención.

**Oráculo independiente**, obtenido por balance de flujo continuo con residencia
cero: como `p>b`, el procesamiento absorbe todo el transporte, `Q=0`.
Definir `d=0` para transporte constante y `d=clamp(t-11/8,0,26/8)`
para transporte detenido. Entonces `T=P=2*(t-d)`,
`O=min(4*t-T,5)=min(2*t+2*d,5)` y `A=T+O`.
Antes de llenar salida, entran 4/s; después solo se repone lo transportado.
Sin detención, O se llena en 2.5 s. Con detención, O(11/8)=11/4;
las 9/4 unidades libres se llenan a 4/s en 9/16 s: saturación en 31/16 s.
Al reanudar, O sigue lleno porque c>b. El oráculo no llama al modelo ni usa
una ejecución fina como verdad.

**Muestreo y aceptación:** tiempos comunes cada 1/8 s desde 0 hasta 20,
más vecinos a 1/16 s de detención, ambas saturaciones y recuperación
(ver `transportTimes` en el test). Eventos incluidos explícitamente, tasa nueva
aplicada desde el evento. Pasos máximos `1/16,1/32,1/64,1/128,1/256,1/1024,1/2048` s;
todos dividen el menor intervalo observado. Se descartó durante el desarrollo
usar pasos mayores: los cortes de observación los igualaban artificialmente.
El horizonte, eventos y observaciones son idénticos en todas las ejecuciones;
no se descarta tiempo ni se añade un scheduler al módulo.

Para cada componente O,Q,A,T,P se verifica su error absoluto máximo por ventana
Y el error de su incremento respecto al comienzo de esa ventana. Ventanas:
arranque `[0,1.3125]`, detención `[1.375,2.125]`, saturación constante
`[2.4375,2.625]`, bloqueo `[3,4.5625]`, recuperación `[4.625,5.125]`,
régimen posterior `[6,20]`. Se usan todas en ambos escenarios; el nombre indica
el evento del escenario correspondiente. Los incrementos cancelan el desfase
acumulado anterior: un error de recuperación no puede quedar oculto por el
arranque o por el estado terminal. `WINDOW` imprime los 60 errores por ejecución
(cinco componentes × seis ventanas × absoluto/incremento).

Máximos absolutos sobre todas las observaciones, **en ambos escenarios**:

| h (s) | O | Q | A | T | P |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 0.0625 | 0.125 | 0.125 | 0.125 | 0.125 | 0.25 |
| 0.03125 | 0.0625 | 0.0625 | 0.0625 | 0.0625 | 0.125 |
| 0.015625 | 0.03125 | 0.03125 | 0.03125 | 0.03125 | 0.0625 |
| 0.0078125 | 0.015625 | 0.015625 | 0.015625 | 0.015625 | 0.03125 |
| 0.00390625 | 0.0078125 | 0.0078125 | 0.0078125 | 0.0078125 | 0.015625 |
| 0.0009765625 | 0.001953125 | 0.001953125 | 0.001953125 | 0.001953125 | 0.00390625 |
| 0.00048828125 | 0.0009765625 | 0.0009765625 | 0.0009765625 | 0.0009765625 | 0.001953125 |

Resultados de transición, expresados como múltiplos de h, orden `(O,Q,A,T,P)`:

| Escenario/ventana | Error absoluto | Error de incremento |
| --- | --- | --- |
| Constante / saturación | `(2,2,2,2,4)` | `(2,0,2,0,0)` |
| Detenido / detención y llenado | `(2,2,2,2,4)` | `(2,2,2,0,2)` |
| Detenido / recuperación | `(0,2,2,2,4)` | `(0,2,0,0,2)` |
| Detenido / bloqueo | `(0,0,2,2,2)` | `(0,0,0,0,0)` |

Los errores no nulos se redujeron exactamente con h; los ceros permanecieron cero.
Cada componente y ventana exige `E_n <= 1.2*(h_n/h_anterior)*E_anterior+1e-8`,
incluidos los pasos finos (salto de factor 4 a 1/1024). No basta que baje el máximo
global. Además se exige envolvente absoluta `8*h+1e-8` y de incrementos
`16*h+1e-8`: margen conservador de dos etapas a tasa máxima 4/s y resta de dos
errores para incrementos; son criterios de estos fixtures, no cotas universales.
La comprobación de reducción es más estricta que esa envolvente. La tolerancia
algebraica `1e-8` cubre redondeo, sin autorizar pérdidas sistemáticas.

Todas las transiciones, en las 14 ejecuciones, verifican conservación por buffer
y acumulada, tasas no negativas y acotadas, capacidades y tiempo simulado.
También se verifica transporte nulo durante toda la detención, admisión nula
una vez llena salida, drenaje de Q y ausencia de trabajo bancado: entre 4.625 y
5.125 se transporta y acepta exactamente 1 unidad, procesándose `1-2*h`;
durante la detención se procesa el remanente `2*h` del buffer Q.

**Conclusión limitada:** convergencia observada de primer orden en estas cantidades
y puntos. Sin defecto encontrado que requiera modificar `Production.luau`.
El retardo downstream-first produce Q residual y desfases de arranque/reinicio;
no representa latencia física. No se prueban tasas arbitrarias, capacidades pequeñas
comparadas con h, estados iniciales no vacíos, eventos sin alinear, errores entre
observaciones ni un teorema de convergencia. Las invariantes sí se comprueban en
cada paso. No hay Roblox runtime involucrado ni aprobación del tick de gameplay.
Siguiente incremento seguro: estados iniciales no vacíos y capacidad downstream
pequeña en esta misma línea, con oráculos independientes, antes de grafos.

## 10. Inventario inicial y downstream pequeño — M0 (2026-10-18)

**Fixtures experimentales, no balance aprobado.** Se conserva el contrato de
`Production.step`, sin cambios al módulo. Dos tests nuevos, 14 ejecuciones:

| Fixture | O inicial | Q inicial/capacidad K | Capacidad O | (c,b,p) | Eventos |
| --- | ---: | ---: | ---: | --- | --- |
| Drenaje | 1 | 1/16 | 2 | (0,2,2) | ninguno |
| Llenos | 1 | 1/16 | 1 | (4,2,2) | p=0 en [2,4), después p=2 |

Horizonte 6 s, observaciones 0,0.5,…,6; pasos uniformes
1/4,1/8,1/16,1/32,1/64,1/128,1/256 s. Todas las observaciones y eventos
pertenecen a todas las grillas. Un assert impide recortar pasos: cada refinamiento
cambia realmente la partición. Los eventos rigen desde su instante; no hay tiempo
descartado. No se agrega scheduler al modelo.

### Derivación independiente

Definir v=min(2h,K), s=v/h. Mientras Q está lleno y hay inventario O,
procesar libera v y transportar repone v; por inducción Q permanece K.
Esto deriva la recurrencia discreta sin ejecutar el módulo como oráculo.
En estos pasos 1/v es entero: O se vacía exactamente tras N=1/v pasos,
en t_d=N*h=1/s. Después Q se drena a 2/s, con último paso parcial en cantidad.
Para el drenaje, en puntos de la grilla:

- T=min(s*t,1), O=1-T, A=0.
- P=T+clamp(2*(t-t_d),0,K), Q=K+T-P.

El límite fluido tiene s=2, t_d=1/2 y acaba de drenar Q en 17/32 s.
El drenaje discreto termina en la primera grilla en o después de t_d+K/2;
la fórmula se evalúa solo en grilla, no inventa interpolación entre pasos.

En el fixture lleno, c=4 repone lo transportado; O=1 y Q=K siempre.
Durante la detención p=0 no se libera espacio: P=T=A=0 por transición.
Con a=t-clamp(t-2,0,2), los acumulados son A=T=P=s*a.
El fluido usa s=2. La recuperación comienza inmediatamente, sin trabajo bancado.

**El orden importa:** con Q=K y h=1/4, procesar da 1/16, transportar repone
1/16. En fluido pasan 1/2 unidades durante ese intervalo. No se puede sustituir
la composición por un mínimo de tasas constantes: K/h limita el caudal discreto.
Transportar antes de procesar encontraría cero espacio y daría T=0 en ese paso.
No se supone que los límites conmutan ni se impone convergencia monótona de errores.

### Mediciones y aceptación

`INITIAL` imprime, para cada paso/fixture, errores absolutos e incrementales de
O,Q,A,T,P en seis ventanas: inicial [0,.5], cola de drenaje [.5,1],
antes de parada [1,2], parada [2,4], reinicio [4,4.5], tardía [4.5,6].
Son las mismas ventanas para ambos fixtures; sus nombres no implican eventos en
el drenaje. Cada incremento resta el valor al inicio de su propia ventana,
cancelando errores previos. Se contrastan los 60 errores de cada ejecución con
los predichos por las dos fórmulas, no solamente con una envolvente global.

Máximos absolutos sobre observaciones, orden (O,Q,A,T,P):

| h | s | Drenaje | Llenos |
| ---: | ---: | --- | --- |
| 1/4 | .25 | (.875,.0625,0,.875,.875) | (0,0,7,7,7) |
| 1/8 | .5 | (.75,.0625,0,.75,.75) | (0,0,6,6,6) |
| 1/16 | 1 | (.5,.0625,0,.5,.5) | (0,0,4,4,4) |
| 1/32 hasta 1/256 | 2 | (0,0,0,0,0) | (0,0,0,0,0) |

Ejemplo que separa transiciones: drenaje h=1/4, ventana [.5,1], errores
absolutos (.875,.0625,0,.875,.875), incrementales (.125,.0625,0,.125,.0625).
En llenos, parada [2,4] mantiene error acumulado A/T/P de 3.5 con h=1/4,
pero error incremental cero. Reinicio [4,4.5] da error incremental .875
para A/T/P, independientemente de ese desfase anterior. Q del drenaje mantiene
error .0625 para varios pasos gruesos: no hay reducción estricta por componente.
Las fórmulas y la salida completa permiten reproducir todas las ventanas.

Se acepta diferencia absoluta <1e-8 unidades frente a las identidades y fórmulas,
no error <1e-8 frente al fluido para pasos gruesos. Los fixtures son diádicos,
horizonte corto y cantidades <=8; esa tolerancia es margen de redondeo, no una
licencia para pérdida sistemática. Coincidencia exacta observada con el oráculo
discreto en **cada transición** y con el fluido desde h=1/32 en estos fixtures.
Se comprueban en cada transición de cada ejecución: cantidades no negativas,
tasas por tiempo simulado, capacidades, tiempo simulado=h, descartado=0,
conservación local O_anterior+A=O_nuevo+T y Q_anterior+T=Q_nuevo+P,
y acumulada O=1+A-T, Q=K+T-P, O+Q+P=1+K+A.
El test anterior de catch-up sigue cubriendo descarte positivo.

**Limitaciones:** no es un teorema general de convergencia; el llenado inicial
Q=K y b=p hacen resoluble el caso y eliminan el retardo de arranque de los tests
vacíos. No se verifican estados iniciales arbitrarios, b distinto de p, eventos
fuera de grilla ni error fluido entre observaciones; sí conservación y oráculo
discreto en todas las transiciones. Ningún defecto encontrado exige cambiar
`Production.luau`. No hay integración Roblox; Studio/multiplayer/touch no se
requieren para esta aritmética offline ni fueron ejecutados. M0 sigue abierto.
Siguiente incremento seguro: Q inicialmente parcial con b distinto de p y
transiciones de llenado/vaciado interiores, todavía en esta línea y con oráculo
independiente antes de ampliar topología.

## 11. Buffers parciales y tasas distintas — M0 (2026-10-18)

**Fixtures experimentales, sin aprobación de balance.** Se agregan dos casos
agrupados; los 14 anteriores se conservan. No cambió `Production.luau` ni su
contrato downstream-first. Reproducción: `lune run tests/production.luau`, Lune
0.11.0; `PARTIAL` imprime cada componente/ventana y número de transiciones.

| Fixture | O,Q iniciales | Capacidades O,Q | c,b,p | Evento |
| --- | --- | --- | --- | --- |
| Llenado/parada/recuperación/drenaje | 2,.5 | 3,1 | 0,3,1 | p=0 en [.4,.9) |
| Vaciado interior y cola | .8,1 | 3,2 | 0,1,3 | sin evento externo |

Horizonte común 4 s, pasos máximos .07,.035,.0175,.00875 s. Las 21
observaciones explícitas incluyen vecinos de llenado (.24,.26), vaciado
(.48,.5,.52), fin de suministro (.8,.82), parada y recuperación (.4,.9).
Los cortes en observaciones/eventos son comunes; el resto de cada intervalo
usa h y un remanente, sin igualar las particiones. Se verificaron respectivamente
67,121,238,467 transiciones por fixture. La tasa nueva rige desde el evento.
No se descarta tiempo ni se agrega scheduler al modelo.

### Oráculos independientes

En ambos A=0, O=O0-T, Q=Q0+T-P. Para llenado definir
u=t-clamp(t-.4,0,.5). Entonces P=min(u,2.5),
T=min(2,3t,.5+P). Q inicial cubre servicio desde el primer paso;
el transporte llena Q en t=.25, después repone lo procesado. La parada
encuentra Q lleno: T=.9, P=.4 y O=1.1 permanecen constantes.
Al recuperar no hay trabajo bancado: P vuelve a 1/s y T lo repone hasta agotar
O en t=2; Q termina de drenar en t=3. Estas fórmulas valen también en las
fronteras discretas usadas: h<=.07 y Q inicial suficiente para el servicio.
No se extrapolan a pasos grandes o cualquier configuración.

Para vaciado, T=min(t,.8). En fluido P=min(3t,1+T); Q llega a cero
en t=.5 con O=.3 todavía disponible y permanece vacío hasta agotar O en .8.
En discreto, para fronteras t_0=0,...,t_n, el oráculo cerrado es:

`P_n = min(3*t_n, min_{1<=j<=n}(1+min(t_{j-1},.8)+3*(t_n-t_j)))`.

Es la envolvente de servicio acumulado y suministro disponible antes de cada
paso; no llama al módulo ni usa una ejecución fina como verdad. El test mantiene
el mínimo de interceptos para evaluar esa expresión sin almacenar toda la grilla.
Un corte corto puede dejar backlog: usar solo el suministro del paso anterior
como fórmula de P sería incorrecto. O y T coinciden con el fluido; Q residual
y P retrasado distinguen el orden discreto de residencia fluida cero.

### Aceptación y resultados

En **cada transición** se verifican oráculo discreto para O,Q,T,P, A=0,
capacidades, cantidades y tasas no negativas/acotadas por tiempo simulado,
simulado=dt, descartado=0 y suma de ambos=dt solicitado. Conservación local:
O_anterior=O_nuevo+T_paso, Q_anterior+T_paso=Q_nuevo+P_paso;
acumulada O=O0-T, Q=Q0+T-P, O+Q+P=O0+Q0.
El test anterior de catch-up conserva cobertura de descarte positivo.

Ventanas comunes [0,.4], [.4,.9], [.9,1.2], [1.2,2.1], [2.1,3.1],
[3.1,4]. Sus nombres describen eventos de uno u otro fixture. Para O,Q,A,T,P
se exige el error absoluto máximo y el de incrementos respecto al inicio de
cada ventana predicho por los oráculos discretos/fluidos, tolerancia absoluta
<1e-8 unidades. Además se exige envolvente absoluta 3h+1e-8 y de incrementos
6h+1e-8 (tasa máxima y resta de dos errores); es aceptación de estos fixtures,
no una cota universal. No se exige un cociente monótono por componente con
particiones recortadas: el perfil analítico es el criterio más preciso.

| h | Máximo absoluto Q y P, vaciado | Máximo incremento Q y P, vaciado |
| ---: | ---: | ---: |
| .07 | .06 | .06 |
| .035 | .025 | .025 |
| .0175 | .0125 | .0125 |
| .00875 | .0075 | .0075 |

En llenado todos los errores observados fueron cero a nueve decimales; en
vaciado O,A,T también. Los errores Q/P están en [.4,.9]; desde .9 todos son
cero. La comparación por incremento impide atribuir un desfase anterior a la
recuperación. El oráculo discreto coincide en todas las transiciones a <1e-8.
La tolerancia cubre redondeo en 4 s y cantidades <=2.5, no pérdidas sistemáticas.

**Suficiencia y límites:** junto a §§8–10 queda cubierta la verificación pendiente
de esta línea: arranque vacío/parcial/lleno, ambas relaciones b/p, saturación,
vaciado interior, bloqueo, recuperación, capacidad pequeña y particiones distintas.
No se encontró defecto del módulo. Más fixtures vecinos no justifican postergar
el siguiente entregable M0: reconciliar los detalles pendientes del GDD indicados
en ROADMAP y acordar entradas/escenarios del simulador de balance antes de
implementarlo. No se autoriza aquí RNG, economía, grafos ni gameplay. No hay
prueba universal, error fluido entre observaciones, tasas continuas variables,
validación del tick de gameplay ni cobertura de motor/red/dispositivos.
M0 sigue abierto; sus decisiones de producto pendientes no cambian.


## 12. Avance del simulador autorizado — 2026-10-18

**Instantánea previa a D-013; superada por §13.** Se implementaron y verificaron
primero runner determinista, luego descubrimiento experimental. Economía condicionada,
compras, promoción y métricas de rangos todavía pendientes. La conexión del primer
extractor necesita respuesta a Q-010 antes de fijar esa parte del experimento.
No cambió `Production.luau`, su contrato, dependencias ni runtime.

Reproducción desde la raíz, Lune 0.11.0:

```sh
lune run tests/balanceRunner.luau
lune run tests/discoveryExperiment.luau
lune run scripts/balance.luau
lune run scripts/seededBalance.luau
lune run scripts/check.luau
git diff --check
```

Salidas ignoradas: `build/balance/deterministic.json` incluye escenarios completos,
revisión Git/dirty, versión, métricas y series por frontera; `build/balance/seeded/`
incluye manifiesto y CSV por escenario con semillas y cada corrida. No son evidencia
de guardado durable. Repetición determinista comparada byte por byte con `cmp`.
Modelo `deterministic-runner-v1`, balance `D011-D012-experimental-v1`, revisión base
`2e15f5c`, dirty=true. Los números de sesión/buffer/upgrade siguen siendo hipótesis.

| Escenario | Online s | A aceptado | P procesado |
| --- | ---: | ---: | ---: |
| S1 starter | 600 | 600 | 599.9375 |
| S2 upgrades exógenos | 1200 | 16924.6875 | 16922.8125 |
| S3 bloqueos | 1200 | 15727.375 | 15725.5 |
| S4 sesiones y control continuo | 900 | 900 | 899.9375 |
| S6 dos líneas | 3600 | 216000 | 215996.25 |

S5: al reducir h de 1/32 a 1/64, A aumenta .15625 y P aumenta 1.09375
para cada una de las tres capacidades ensayadas. En las fronteras de S2, el cambio
de paso reduce retardo de arranque y desfase entre etapas; el buffer (50,30)
permite aceptar 45 unidades adicionales frente a (5,3), conservadas en inventario,
sin aumentar 45 unidades de caudal sostenible. Antes de decidir pacing falta
publicar diferencias por ventana y completar los candidatos económicos.

Runner: eventos se ordenan por tiempo e ID, recorta pasos en eventos/sesiones/
observaciones; ausencia conserva inventario sin ejecutar Production. Las métricas
de ocupación usan cuadratura por extremo izquierdo, no tiempo continuo exacto.
El presupuesto global experimental se renueva por paso simulado y reparte por ID
estable, sin bancar remanente; no es aprobación de prioridad entre fuentes en
runtime. Se prueba demanda agregada 120/s limitada a 60/s y rechazo de tercera
línea marcada como extractor máximo. Un perfil de fuentes debe declarar esa marca;
no es validación de compras/construcción de gameplay.

Descubrimiento: Park–Miller 16807/módulo 2147483647, vector de referencia probado;
geometría inversa para saltar fallos naturales sin iterar cada unidad. El flujo
natural conserva posiciones absolutas por unidad y la garantía no consume draws.
Solo se pasa trabajo entero nuevo; la integración de fracciones con economía aún
está pendiente. Las corridas usan floor(A+1e-8) al final y jamás procesan inventario
inicial como oportunidad. No es una selección de RNG de producción.

100000 corridas por cada uno de 12 escenarios/variantes y por política (2.4 millones
en total), semilla maestra 20261018. Derivación y semillas individuales en artefactos.
Políticas: garantía aprobada y control puro contrafactual. Tiempos desde la primera
unidad entera aceptada, interpolados dentro del tramo de aceptación constante.
Percentiles nearest-rank sobre **toda** la cohorte, censura como infinito.
Banda DKW 99% descriptiva ±.005148 en CDF bajo draws independientes ideales; no
cubre sesgo del PRNG ni incertidumbre sobre comportamiento humano.

Contraste independiente en unidades (100000 corridas por política):

| Política | Media medida | Media analítica | Mediana | p90 | p99 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Garantía | 86468.72151 | 86466.607012 | 69319 | 200000 | 200000 |
| Control puro | 100002.01759 | 100000 | 69319 | 230217 | 460314 |

13.535% de la cohorte de contraste llega a H. En S6 la garantía produce mediana
1155.5833 s y p90/p99 3333.3167 s online/calendario desde la primera unidad.
En S1/S2/S3/S4 no se alcanzan mediana/p90/p99 dentro de sus horizontes;
fracciones censuradas respectivas 99.402%, 84.432%, 85.447%, 99.103%.
No extrapolar estos horizontes a compras, rangos ni primera promoción.

Checks locales pasaron tras corregir formato; ninguna prueba nueva de Studio,
multiplayer, touch o servicios reales. No commit/push de paso 1 todavía: falta
completar su alcance y verificarlo antes de cruzar la puerta al paso 2.


## 13. Simulador M0 completo offline — paso 1 (2026-10-18)

**Implementado; resultados experimentales, sin aprobación de economía/pacing.**
D-013 resuelve la sustitución del starter. `Production.luau`, runtime, configuración
Rojo, herramientas y dependencias permanecen intactos. Se verificó primero el runner
determinista (§12), luego descubrimiento y economía, cada incremento con pruebas.
Los pasos de evaluación/aprobación de producto, guardado y cierre M0 son posteriores.

### Contratos e hipótesis del experimento

- `EconomyExperiment`: starter gratuito 1/1/1, Intel inicial 0; primer extractor
  sustituye manual sin sumar caudal (D-013). Precios incrementales de §2; política
  ordenada: extractor, procesador básico, cinta básica, extractor T2, procesador T2,
  cinta mejorada, extractor T3; después segunda línea y sus mejoras. La secuencia
  sirve de prerrequisito; una compra sin saldo espera, sin inyección de moneda.
- Segunda línea **hipotética** conectada por 95 Intel (30 extractor +60 procesador
  +5 segmento), inicialmente 1/10/10. Un segmento lógico por línea; no pretende
  medir distancia/coste del routing físico. No aprueba un paquete para runtime.
- Compra en primera frontera de paso asequible; demora de 5 segundos **online**
  entre decisiones. Sin costes de construcción/animación ni errores del jugador.
  Variantes de precio multiplican todos esos precios, sin alterar p/H ni capacidades.
- Buffers (50,50) por línea; sensibilidad (1,1). h=1/32, catch-up cap=2 s;
  pasos recortados en fronteras de sesión/actividad/bloqueo. Sin catch-up offline.
  Presupuesto fresco compartido 60*dt, orden estable de línea; hasta dos líneas.
- Promoción: consentimiento voluntario programado después de completar compras,
  tutorial-equivalente por automatización y alcanzar requisitos de producción/Intel.
  Es una política experimental explícita, no promoción automática de gameplay.
  Reset a starter/100 Intel, multiplicador 1.25; inventario descartado contabilizado,
  Intel sobrante reseteado contabilizado; solo una promoción por corrida.
- Elegibilidad: `floor(accepted acumulado +1e-8)` da IDs de trabajo enteros nuevos;
  nunca redondear cada paso/sesión. Las fracciones y el total acumulado sobreviven
  al reset; las unidades previamente aceptadas no vuelven a sortearse. Tolerancia
  1e-8 solo para redondeo numérico. Descubrimiento se acopla a esos IDs, nunca a P.
  RNG y contadores se conservan en chunks/promoción/reconexión. El experimento no
  emite Demonstration Archives ni les permite entrar al flujo elegible.
- Archivos no alteran ingresos/compras: el mismo camino económico determinista
  puede reutilizarse para todas las semillas sin cambiar resultados de economía.
  Cada unidad ordinaria sigue en inventario/procesamiento aunque descubra archivo.
  Conservación por transición, tasas y presupuesto se comprueban; balances acumulados
  de material y moneda con tolerancia absoluta 1e-6 en horizontes de hasta 100h online.
- Se acelera únicamente repetición de un estado de buffers fijo comprobado, sin
  compras/promoción pendientes, en pasos h enteros hasta próxima frontera. Test
  contra recorrido no acelerado: A/T/P/Intel coinciden a <1e-6. No extrapola fluido.

### Reproducción y artefactos

```sh
lune run scripts/check.luau
lune run scripts/balance.luau
lune run scripts/seededBalance.luau
lune run scripts/economyBalance.luau
lune run scripts/steadyBalance.luau
lune run scripts/balanceSensitivity.luau
lune run scripts/economyBalance.luau E1-baseline 1
lune run scripts/seededBalance.luau S6-cap 1
git diff --check
```

Lune 0.11.0; semilla maestra 20261018. Código/entradas versionados en Git;
`build/balance/` generado e ignorado. `economy/all.json` registra manifiestos completos,
trayectorias, transacciones, resúmenes, revisión/dirty, hashes Git del contenido de
cada fuente y comando. CSV por escenario conserva semillas, resultados individuales
(y vacíos censurados). El comando final repite una corrida por índice sin cambiar
su derivación. Algoritmo y método de censura/percentiles/bandas están en §12;
`BalanceMetrics` incluye intervalo por inversión de banda DKW 99% para cada percentil.
No interpretar esa banda como validación de supuestos de comportamiento humano.

Corridas: S1–S6 y variantes: 12 escenarios ×2 políticas ×100000; economía:
11 escenarios ×2 políticas ×100000; control sostenido: 100000 caminos por política
mapeados a 1/10/30/60/s con draws comunes. Contraste analítico separado: 100000 por
política (§12); se comprueban medias y CDF en umbrales de trabajo frente a fórmulas
geométrica/truncada, tanto primer hallazgo como gap posterior. Garantía es la política aprobada; puro aleatorio solo control.
Los horizontes cortos conservan censura; los largos llegan a 100h online según sesión.
Rangos candidatos 1/5/15/40/100, sin depender de producción/Intel. Gaps posteriores:
primero→segundo hallazgo; control sostenido los separa de arranque y progresión.

### Compras y primera promoción (medidas, desde inicio de sesión inicial)

| Candidato | Primera automatización | Fábrica 60/s | Primera promoción programada |
| --- | ---: | ---: | ---: |
| E1 precios originales | 30.0625 s | 344.8125 s | no solicitada |
| E2 5 min cada hora | 30.0625 s | 3644.8125 s calendario /344.8125 s online | no solicitada |
| E3 30 min diarios | 30.0625 s | 344.8125 s | no solicitada |
| E4 bloqueo + reconexión | 30.0625 s | 354.84375 s | no solicitada |
| E5 precios ×5 | 150.0625 s | 1719.75 s | no solicitada |
| E6 promoción 25k P/10k Intel | 30.0625 s | 344.8125 s | 721.84375 s |
| E7 manual 10 s/día, online 5 min/día | 172810.0625 s calendario | 259224.875 s calendario | no solicitada |
| E8 buffers (1,1) | 30.0625 s | 344.8125 s | no solicitada |
| E9 precios ×2 | 60.0625 s | 688.03125 s | no solicitada |
| E10 promoción 100k P/50k Intel | 30.0625 s | 344.8125 s | 1971.84375 s |
| E11 manual solo 10 s, horizonte 600 s | **inalcanzable** | **inalcanzable** | no solicitada |

E1 coste total de maquinaria 2380 Intel; E5 11900; E9 4760.
E11 produce solo 10 unidades, saldo 10; extractor de 30 no se compra por suerte ni
por inyección de Intel. E6/E10 conservan trabajo elegible al reset y registran
exactamente una promoción. No se simula segunda promoción, edificios o rutas arbitrarias.

### Descubrimiento, sesiones y rangos (garantía)

E1 primera búsqueda: mediana 1459.4427 s (~24.32 min), p90/p99 3637.4260 s
(~60.62 min), desde primera unidad entera. Gap segundo hallazgo: mediana ~19.27 min,
p90/p99 ~55.56 min. La garantía limita trabajo; la rampa puede superar 55.56 min
online para el primer archivo, y las ausencias aumentan el tiempo calendario.

| Escenario | Mediana primer archivo calendario | p90/p99 calendario | Mediana online |
| --- | ---: | ---: | ---: |
| E1 continuo | 24.32 min | 60.62 min | 24.32 min |
| E2 5 min/hora | 4.07 h | 12.01 h | 24.32 min |
| E3 30 min/día | 24.33 min | 48.01 h | 24.33 min |
| E4 bloqueo/reconexión | 36.10 min | 92.40 min | 26.10 min |
| E5 precios ×5 | 44.59 min | 80.90 min | 44.59 min |
| E6 promoción temprana | 27.09 min | 63.39 min | 27.09 min |
| E7 manual limitado | ~6.00 días | ~14.00 días | 33.99 min |

Valores individuales y bandas completas en los artefactos; redondeos de tabla no
son objetivos de producto. Cohortes independientes por escenario; diferencias
pequeñas entre E1/E8 incluyen variación muestral, no efecto probado del buffer.
En E2 rango100 queda censurado en el horizonte de 100 sesiones de 5 min; no
presentarlo como alcanzado. Tiempo manual se reporta aparte: en E1, los hallazgos
posteriores a automatizar no suman actividad manual aunque sí tiempo online.

| Rango candidato | E1 mediana online | E1 p90 online | E1 p99 online |
| ---: | ---: | ---: | ---: |
| 1 | .4054 h | 1.0104 h | 1.0104 h |
| 5 | 2.0584 h | 3.0004 h | 3.7675 h |
| 15 | 6.0685 h | 7.6439 h | 8.9439 h |
| 40 | 16.0714 h | 18.5998 h | 20.7080 h |
| 100 | 40.0864 h | 44.0606 h | 47.3885 h |

Control sostenido 60/s: primer hallazgo mediana 1155.4833 s, p90/p99 3333.3167 s;
gap posterior mediana 1155 s, p90/p99 3333.3333 s. A 1/s, mediana primera
19.2581h y p90/p99 55.5553h: el starter sin automatizar es lento de forma explícita.
No proponer un hallazgo genuino rápido de tutorial con estos p/H sin cambiar producto.
El demo no sustituye estadísticas genuinas. Otros caudales y control puro en `steady.json`.

### Aceptación, sensibilidad y límites

Pasaron tests de runner, RNG, economía/métricas, 16 tests previos de Production,
formato/lint/build/smoke y diff check. Tests económicos incluyen asequibilidad,
no suma manual/auto, espera/reconexión, bloqueo, compra imposible, promoción y
retención de fracciones/counter; no afirman persistencia durable ni T-009.

En todos E1–E11, h/2 conserva secuencia de transacciones. Máxima diferencia de A:
8.375 unidades en hasta 100h online; máximo adelanto de transacción .21875 s online
(en E6/E10). Umbral de diagnóstico 100 unidades solo alarma cambios grandes;
la aceptación usa diferencias observadas pequeñas y su causa, no una cota universal.
Variación procede de latencia downstream-first y compra en fronteras discretas;
no hay pérdida acumulada ni aumento de caudal estable. En S5, diferencias por ventana
para (5,3): P +.03125 [0,120], +.28125 [120,200], +.78125 [900,1200]; A +.15625
[300,400]; resto cero. Las tres capacidades comparten estos deltas. T e inventario
concuerdan por conservación. Artefacto completo `sensitivity.json`.

Repetición completa: todos los CSV económicos resultaron byte-idénticos (SHA-256);
replay individual E1 índice 1 y S6 índice 1 coincide exactamente para ambas políticas.
La exportación determinista también coincidió byte por byte. Estas comprobaciones
excluyen cambios esperados de procedencia Git tras el commit; los valores son reproducibles.

No se eligió tick de gameplay. No se validaron motor, Studio, red, touch, ocho plots,
servicios reales, persistencia o durabilidad. Sin modificaciones a `src/` ni Production.
Los resultados son candidatos para decidir el paso 2; M0 continúa abierto hasta
aprobar pacing/economía y completar los pasos 3–5.


## 14. Evaluación de alternativas — paso 2 (2026-10-18)

Paso 1 publicado en commit `6e2802f3398c4cf00466b666c7540ce112b857be` a
`origin/master`; [CI remoto exitoso](https://github.com/F94Olivera/gdd/actions/runs/39172535646).
Se comparan combinaciones antes de pedir decisiones de producto. **Aprobación posterior registrada en D-014–D-016**. La repetición y el cierre
del paso se registran abajo; las alternativas no seleccionadas siguen como evidencia.

Se agregan E12/E13 a `economyScenarios.all`, manteniendo índices/semillas previos.
Comandos: `lune run scripts/economyBalance.luau E12-prices-x2-early-promotion`
y `lune run scripts/economyBalance.luau E13-prices-x2-later-promotion`.
Cada escenario ejecutó 100000 corridas por política y exportó manifiesto/CSV propios.
Pasaron check local, diff check y `lune run scripts/balanceSensitivity.luau`.
En ambos, delta de A al usar h/2=9.15625 unidades/100h online y máximo adelanto
transaccional .21875 s; conservación, secuencia de compras y caudal estable intactos.

| Alternativa | Primera automatización | 60/s | Primera promoción | Mediana primer archivo | p90/p99 primer archivo |
| --- | ---: | ---: | ---: | ---: | ---: |
| Originales +25k/10k (E6) | 30.06 s | 5:44.81 | 12:01.84 | 27.09 min | 63.39 min |
| Originales +100k/50k (E10) | 30.06 s | 5:44.81 | 32:51.84 | 24.32 min | 63.39 min |
| Precios ×2 +25k/10k (E12) | 60.06 s | 11:28.03 | 17:05.38 | 36.18 min | 72.49 min |
| Precios ×2 +100k/50k (E13) | 60.06 s | 11:28.03 | 37:55.38 | 29.38 min | 72.49 min |

Tiempos online continuos ideales, según los supuestos de §13. En E13,
medianas online por rango 5/15/40/100: 2.2573/6.2623/16.2647/40.2807 horas;
p99 3.9565/9.1417/20.9223/47.5673 horas. No incluyen errores de construcción,
tiempos de pensar distintos de la demora programada o coste geométrico de rutas.

**Recomendación presentada, no elegida:** E13, precios ×2 y primera promoción 100k P/50k Intel;
conservar rebuild grant 100/multiplicador total 1.25 como candidatos. Da un minuto
hasta automatización y más uso de la fábrica completa antes del reset. E12 resetea
antes y retrasa más la mediana del primer archivo. Precios ×5 no se recomiendan
para el objetivo propuesto de automatizar antes de 2 minutos (mide 150.06 s).
El requisito de producción domina a la fee en estos candidatos: además del fee,
el reset desecha Intel sobrante; el futuro preview debe mostrar ambos conceptos.

Se consulta explícitamente al productor economía, objetivos Q-002 (mediana ≤37 min,
p90/p99 ≤75 min online en el control con progresión y una promoción; ver controles
sostenidos/manuales de §13) y títulos/umbrales Q-004. Son propuestas para validar
luego en playtests, no límites de espera calendario ni nuevas garantías.
Después de su respuesta: registrar decisiones, repetir las simulaciones afectadas,
verificar coherencia y recién entonces commit/push/CI del paso 2. Q-005 segunda
promoción no se aprueba por inferencia; quedará fuera de M1 hasta decisión separada.


### Decisión y repetición del paso 2

El productor eligió **E10: precios originales +100k P/50k Intel**, grant100 y
multiplicador1.25 (D-014); aceptó objetivos ≤37/75/75 min online (D-015) y
umbrales/títulos de §3 (D-016). La aprobación no comprende buffers/demoras/paquete
hipotético de segunda línea ni coste geométrico de rutas. Segunda promoción fuera de M1.
Repetición completada: E10 100000 por política, control sostenido 100000 por
política, sensibilidad E1–E13, `lune run scripts/check.luau` y `git diff --check`.
E10: primera automatización30.0625s, 60/s344.8125s, promoción1971.84375s;
primer archivo mediana1459.3260s, p90/p99 3803.3396s online. Cumple explícitamente
D-015 (37min/75min/75min). Exactamente una promoción, sin pérdidas de elegibilidad.
Rangos elegidos 5/15/40/100: medianas2.1032/6.1011/16.1200/40.1405h online;
p99 3.8118/8.9985/20.7844/47.3733h. Son los resultados de precios originales,
no los de la alternativa ×2. Pasó el check local; validación de motor/dispositivos
no ejecutada. Paso 2 completo en evidencia local, listo para commit/push y CI.
No se implementó gameplay, nuevas dependencias ni persistencia.
