# Respuesta a la revisión de Codex sobre OBJECTS.md

**Fecha:** 2026-10-19
**Contexto:** el productor pasó la revisión que hizo Codex del inventario de objetos
3D (`docs/OBJECTS.md`) y pidió evaluar si tiene sentido y dar una respuesta final.
Este archivo es esa respuesta. Las correcciones que acepté **ya están aplicadas** en
OBJECTS.md (marcadas con «corrección 2026-10-19» o «revisión 2026-10-19»).

## Veredicto

La revisión de Codex **tiene sentido y es útil**. Encontró tres errores reales en lo
que escribí, dos inconsistencias que había que cerrar, y cuatro puntos donde exagera
o lee mal el documento. La propuesta de reparto de roles y de orden de producción es
razonable, con una salvedad importante sobre lo que una IA puede y no puede hacer en
arte. Nada de lo que propone contradice una regla de producto aprobada.

## Punto por punto

| # | Observación de Codex | Mi evaluación | Qué hice |
| --- | --- | --- | --- |
| 1 | El brazo del extractor (~5 studs desde Z = +2) sobresale del footprint ±4 | **Correcto.** La punta llegaba a Z = +7 en pose horizontal y a +5.8 en la pose baja, y mi propio contrato prohibía sobresalir. Error mío | Brazo acortado a 2.5 studs con pivote en Z = +1 y rango 0° a −60°: la punta nunca pasa de Z = +3.5. Se exige validar el barrido en el blockout |
| 2 | La tabla dice archivo de 2 studs de alto y el contrato dice 1.5 | **Correcto.** Inconsistencia mía | Tabla corregida: 2 × 1.5 × 1.5 (caja, por defecto) o 2 × 1.5 × 0.5 (carpeta, alternativa) |
| 3 | Los materiales tileables mezclan dos sistemas; usar `MaterialVariant` para tileables y `SurfaceAppearance` para mallas con UV | **Correcto.** Mi redacción en la sección de Designer estaba mal. Verificado en la doc oficial: MaterialVariant es «for customizing the appearance of reusable tileable material» y SurfaceAppearance «for a specific mesh with UV mapping» | Sección de Designer y tabla de herramientas corregidas |
| 4 | El papel como plano de 2 triángulos contradice la guía de Roblox de mallas con volumen | **Correcto.** La tabla decía caja de 0.05 con ≤12 triángulos y la sección de Blender decía plano de 2 triángulos. Además un plano de una cara es invisible desde atrás salvo `DoubleSided` | Unificado: caja fina 1 × 1.2 × 0.05, 12 triángulos |
| 5 | No asumir que los Empties de Blender se convierten en Attachments; Roblox documenta el sufijo `_Att` | **Correcto y mejor que lo que yo tenía.** Yo ya decía «si el importador no los trae, crearlos a mano», pero no conocía la convención. Verificado: la doc de accesorios dice que la geometría con sufijo `_Att` se convierte en `Attachment` al importar. Está documentado para accesorios, así que igual hay que probarlo en el primer import | Contrato cambiado: puertos y montajes se modelan como cubos de 0.1 studs llamados `Port_Out_0_Att`, con fallback manual |
| 6 | Todo objeto recibe flujo «AAA» completo; usar bake y Painter selectivamente | **Parcialmente correcto.** El doc ya diferenciaba (cintas y props por trim sheet, tiers por texture set, UI en Studio, solo seis hero assets con concept), pero el párrafo introductorio sonaba a «todo con high-poly» | Introducción reescrita: high → low + bake solo en hero assets; el resto low-poly directo, trim sheets y materiales compartidos |
| 7 | Blender está excluido del texturizado final; quitar la restricción | **Parcialmente correcto.** La restricción absoluta era excesiva. Pero el productor pidió un pipeline hiperprofesional y eligió Substance; para hero assets y máquinas con desgaste y calcas, Painter sigue siendo la elección correcta por velocidad y control | Suavizado: Blender aceptable para assets simples (atlas, trim básica, bakes procedurales); Painter por defecto para hero y máquinas. No es prohibición |
| 8 | Las Parts nativas de Studio están «ampliamente desaconsejadas» | **Lectura exagerada.** El doc ya usaba Parts para piso, colisión, cristal, Neon, luces, superficie de cinta y UI; lo único desaconsejado era modelar máquinas y props con Parts/CSG. Aun así, conviene la lista explícita | Agregada la lista de usos permitidos en la tabla de herramientas |
| 9 | La notación de medidas es ambigua respecto de `Vector3` (X, Y, Z) | **Parcialmente correcto.** El doc definía «ancho × profundidad × alto = X × Z × Y», pero quien se saltea esa línea lo lee al revés. La sugerencia de guardar las medidas con nombre en el manifiesto es buena | Nota ampliada y regla para el manifiesto: `size_x`, `size_y`, `size_z`; los contratos ya escriben rangos por eje |
| 10 | Las 44+ filas no son 44 proyectos; estimar por familias | **Correcto.** | Agregado el conteo real: unas 18 familias de modelado distintas |
| 11 | La propuesta futura de «baler / rayos X» contradice que el archivo se otorga al limpiar y no se pierde aguas abajo | **El principio es correcto, pero esa propuesta no existe en el repo.** Ni OBJECTS.md ni ningún doc mencionan baler ni rayos X; debe venir de otra conversación con Codex. Si alguien la propone, choca con D-002 (el scanner no es puerta de descubrimiento) y con la regla de que la salida ordinaria y el archivo son independientes | Sin cambios. No se agrega a la sección de excluidos algo que nadie propuso en el repo; si aparece, va a Q-008 |
| 12 | Reparto: productor = dirección de arte; Codex = modelos, materiales, exports; Claude y el segundo contribuidor = gameplay e integración | **Razonable, con una salvedad.** Codex puede escribir scripts de Blender Python y de validación, pero **ninguna IA puede juzgar calidad visual** ni ejecutar Substance Painter de forma confiable; el Master Prompt v2.0 §6 prohíbe «claim control of Studio or art tools» sin integración probada, y eso aplica a Codex igual que a mí. El productor tiene que aprobar cada asset mirando el render en Studio, y el segundo contribuidor (que tiene Studio) hace la aceptación | Es una **decisión del productor**, no mía. Si la confirma, va a DECISIONS.md como E-0xx y ASSET_PIPELINE «Goals and ownership» se actualiza. No la registré por mi cuenta |
| 13 | Orden de producción en seis etapas y flujo «brief → blockout → fit check → modelado → materiales → export → check → Git» | **Correcto y coincide** con el primer entregable y los contratos de OBJECTS.md | Sin cambios; el orden propuesto es compatible con ROADMAP M1-09 |
| 14 | Gemini solo para siluetas, paleta y referencias; no establece medidas | **Correcto**, es lo que dice D-020 y OBJECTS.md | Sin cambios |

## Lo que queda abierto para el productor

1. **Confirmar o rechazar el reparto de roles** del punto 12 (Codex como ejecutor de
   arte con scripts; Claude y el segundo contribuidor en gameplay). Si se confirma, se
   registra en DECISIONS.md y se actualiza ASSET_PIPELINE.
   **Cerrado 2026-10-20 (E-015):** rechazado. Alan hace el 3D y lo aprueba; el
   productor hace el código y la integración. Codex no ejecuta arte.
2. **Moodboard y paleta en hex**, decisión caja vs carpeta, y layout de parcela: siguen
   siendo las entradas que faltan para arte final (sección «Qué sigue faltando» de
   OBJECTS.md).
3. **Prueba del cubo en Studio** con un `_Att` incluido, para convertir en evidencia la
   escala 1 unidad = 1 stud, la orientación −Z y la conversión de Attachments. Requiere
   Studio instalado (ROADMAP M0.1-12).

## Fuentes verificadas para esta respuesta

- [Roblox: accesorios, convención `_Att`](https://create.roblox.com/docs/art/accessories)
- [Roblox: 3D Importer](https://create.roblox.com/docs/art/modeling/3d-importer)
- [Roblox: materiales, MaterialVariant vs SurfaceAppearance](https://create.roblox.com/docs/parts/materials)
- [Roblox: especificaciones de modelado (volumen, 20 000 triángulos)](https://create.roblox.com/docs/art/modeling/specifications)
