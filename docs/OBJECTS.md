# Inventario de objetos 3D — Find the Secret Archive

**Propósito:** checklist de los modelos 3D que el juego necesita, inferidos de
`docs/GDD.md`, el Master GDD v2.0 original, `DECISIONS.md` (D-012/D-013/D-018),
`ARCHITECTURE.md`, `ASSET_PIPELINE.md`, `ROADMAP.md` y los IDs usados en
`scripts/models/EconomyExperiment.luau`. Marcar `[x]` cuando el modelo exista
(placeholder o final) y anotar el estado en la columna correspondiente.

**Estado (2026-10-21):** 39 de los 47 objetos de las secciones 1–6 existen en el repo de
arte de Alan (`3d-models_FTSA`) y están marcados `[x]`: 33 como blockout (31 con candidato
de material A) y 6 como blockout nativo de Studio. Ninguno tiene todavía apariencia final ni
aceptación en Studio. Faltan `plot_bay_frame`, `hub_floor`, `hub_plot_gate` y `prop_column`,
ya especificados en D-024, y los nuevos `belt_straight_starter`, `hub_street_segment` y
`hub_street_cross`. `env_roof_truss` queda fuera de lanzamiento (D-024). D-024 y D-025 fijan
el entorno y resuelven los conflictos de medidas; el resto de las medidas sigue siendo
**propuesta de contrato de assets**, a validar en Studio.

## Cómo leer las medidas

- Unidad: **studs** de Roblox. Un personaje R15 por defecto mide ~5 studs de alto y
  ~4 studs de ancho de hombros; una celda de la grilla mide **4×4 studs** (D-018).
- Formato: **ancho × profundidad × alto**, es decir **X × Z × Y**. Atención: no es el
  orden de `Vector3`/`Size` de Roblox (X, Y, Z). Para no confundir, en el manifiesto
  de assets las medidas se guardan como tres campos con nombre (`size_x`, `size_y`,
  `size_z`) y los contratos de modelo escriben el bounding box como rangos por eje.
- Las medidas de máquinas son **múltiplos exactos de 4 studs** en planta para que
  encajen en la grilla; la altura es libre pero debe dejar la cámara en tercera
  persona legible. Todas son hipótesis a validar con placeholders en M1-09
  (ASSET_PIPELINE §«Export/import process»).
- Las reglas de juego dicen qué hace cada objeto; **la reproducción de un objeto
  nunca es una unidad económica** (240 papeles visuales máx. por cliente, GDD §7).
- Nombres de modelo sugeridos siguen la convención del pipeline
  (`machine_*`, `belt_*`, `archive_*`); el manifiesto futuro los mapea a IDs lógicos.

## Herramientas y pipeline AAA

Cada fila termina con la columna **Herramienta (pipeline AAA)**: el flujo de programas
elegido para ese objeto, en orden. El estándar es el de un juego AAA, aplicado
**selectivamente**: high-poly → low-poly con bake de normales solo en los seis hero
assets; el resto de máquinas se modela directo en low-poly con biseles horneados por
shader; props y estructura usan trim sheet y materiales tileables compartidos; los
tiers son texture sets sobre el mismo mesh; y Studio ensambla, ilumina y pone la UI,
con Parts nativas donde una Part alcanza (pisos, colisión, cristal, luces, blockouts).

| Herramienta | Rol en este proyecto | Nunca para |
| --- | --- | --- |
| **Blender** | Todo el modelado hard-surface, UVs, high→low-poly, bake, LODs, pivotes y puertos `_Att`, export FBX/glTF. Texturizado aceptable para assets simples (atlas de papel, trim sheet básica, bakes procedurales) | Texturizado de hero assets y máquinas con desgaste/calcas: ahí Painter es más rápido y controlable. No es una prohibición absoluta (revisión 2026-10-19) |
| **Substance Painter** | Texturizado PBR por objeto: metal/pintura/desgaste/sellos/etiquetas; un texture set por mesh; export para SurfaceAppearance | Materiales tileables grandes (pesan y repiten mal) |
| **Substance Designer** | Materiales tileables procedurales: hormigón, acero, goma de cinta, papel apilado, atlas de hojas | Objetos únicos con detalle local |
| **Substance Sampler / 3D Assets** | Opcional: convertir referencias fotográficas en materiales base para Designer | Assets finales sin pasar por Designer/Painter |
| **Gemini Pro (NanoBanana)** | Concept art y exploración de siluetas/paleta **antes** de modelar los hero assets (extractor, archivo, bóveda, pila) | Assets finales, texturas o meshes en runtime: D-020 y ASSET_PIPELINE lo limitan a referencia hasta revisar procedencia y licencia |
| **Roblox Studio** | Import 3D, MeshPart + SurfaceAppearance, colisiones, Attachments, materiales nativos (Glass, Neon), `MaterialVariant` para tileables, luces, partículas, SurfaceGui/BillboardGui, UI en mundo scripteada. **Parts nativas sí** para pisos, carriles, volúmenes de colisión, cristales, luces, superficie de cinta, piezas estructurales simples y blockouts | Modelar máquinas, archivo o props detallados con Parts/CSG (sin control de UVs ni bake) |

**Hero assets** (reciben pase de concept + presupuesto de textura máximo):
`archive_confidential`, `machine_extractor_t1`, `machine_processor_t1`, `plot_vault`,
`supply_pile_ground`; `hub_plot_gate` solo si se hace el arco opcional (P2, D-024). El resto reutiliza su lenguaje visual.

## Formatos de archivo, compatibilidad e incorporación a Roblox

**Respuesta corta:** sí, Blender y Substance son compatibles entre sí y con Roblox.
El puente es **FBX** para geometría y **PNG** para texturas. Blender exporta FBX,
Substance Painter lo abre tal cual, Painter exporta PNG con un preset oficial de
Roblox, y Roblox Studio importa el FBX y los PNG. Ninguna herramienta necesita
convertidores externos.

| Herramienta | Formato **fuente** (va a Git/LFS, nunca se borra) | Formato de **intercambio** que exporta | Quién lo recibe |
| --- | --- | --- | --- |
| Blender | `.blend` | `.fbx` (recomendado), `.gltf/.glb`, `.obj` | Substance Painter y Roblox Studio |
| Substance Painter | `.spp` (proyecto con capas) | Texturas `.png` 8 bits (también `.tga`, `.exr`) | Roblox Studio |
| Substance Designer | `.sbs` (grafo editable) | `.sbsar` (material publicado) y bitmaps `.png` | Painter (lee `.sbsar` directo) y Roblox Studio (PNG) |
| Substance Sampler | `.ssa` | `.sbsar` y bitmaps `.png` | Designer / Painter |
| Gemini Pro (NanoBanana) | `.png` / `.jpg` (imágenes generadas) | Las mismas imágenes | Carpeta `assets/references/`; **nunca** al runtime |
| Roblox Studio | `.rbxl` / `.rbxlx` (place), `.rbxm` / `.rbxmx` (modelo) | Asset IDs publicados | El juego |

Lo que Roblox Studio acepta, verificado en la documentación oficial (2026-10-19):

| Regla | Valor oficial | Fuente |
| --- | --- | --- |
| Formatos de malla que importa el 3D Importer | `.fbx`, `.obj`, `.gltf`. FBX y glTF soportan jerarquías, PBR, rig y animación; OBJ solo malla simple | [3D Importer](https://create.roblox.com/docs/art/modeling/3d-importer) |
| Triángulos por malla | **máximo 20 000**; geometría watertight, con volumen, quads donde sea posible | [Modeling specifications](https://create.roblox.com/docs/art/modeling/specifications) |
| Formatos de textura | `.png`, `.jpg`, `.tga`, `.bmp` | [Texture specifications](https://create.roblox.com/docs/art/modeling/texture-specifications) |
| Resolución | Hasta 4096×4096 para texturas básicas; para mapas PBR el espacio UV recomendado es **1024×1024**. Guía: 256 px para objetos de 5×5 studs, 512 px para 10×10, 1024 px para 20×20 | ídem |
| Materiales y UVs | **Un solo material por malla**, **un solo set de UV**, todo dentro de 0–1; se permiten UVs solapadas | ídem |
| Mapas PBR (`SurfaceAppearance`) | Color (RGB), Normal (RGB, **solo OpenGL tangent-space**), Roughness (gris 8 bits), Metalness (gris 8 bits, flujo metalness), Emissive (gris 8 bits). No hay mapa de AO | [Texture specs](https://create.roblox.com/docs/art/modeling/texture-specifications), [Surface appearance](https://create.roblox.com/docs/art/modeling/surface-appearance) |
| Export FBX desde Blender | `Transform › Apply Scalings = FBX Units Scale`, `Path Mode = Copy`, `Embed Textures` activado, `Add Leaf Bones` desactivado, `Bake Animation` desactivado salvo animación real | [Export requirements](https://create.roblox.com/docs/art/modeling/export-requirements) |
| Preset de Painter para Roblox | Desde Substance Painter 8.2 existen la plantilla de proyecto y el preset de export **«Roblox – Surface Appearance»** (y «Roblox – Material Variant») | [Notas de versión de Adobe](https://experienceleague.adobe.com/en/docs/substance-3d-painter/using/release-notes/all-changes) |

### Flujo concreto por objeto (del concept al juego)

1. **Concept (Gemini, solo hero assets).** 3–5 imágenes de silueta/paleta. Se guardan en
   `assets/references/<id>/` con fecha y prompt. No se importan a Studio.
2. **Blender: blockout a medida.** Un cubo con las medidas exactas de la tabla (1 unidad
   de Blender = 1 stud, ver abajo). Se exporta ese blockout como **placeholder** y se
   prueba en Studio **antes** de detallar: así se validan medidas, pivote, puertos y
   cámara (ROADMAP M1-09) sin tirar trabajo de texturizado.
3. **Blender: high-poly → low-poly.** High-poly con biseles/subdivisión para hornear;
   low-poly dentro del presupuesto de triángulos (tabla abajo), UV única en 0–1,
   transformaciones aplicadas, origen en el centro de la base. Export `.fbx` con las
   opciones de la tabla anterior. Exportar también el high-poly a `.fbx` aparte solo
   para el bake.
4. **Substance Painter: texturizado.** Nuevo proyecto con la plantilla **Roblox –
   Surface Appearance**, formato de normal **OpenGL**, importar el low-poly FBX, hornear
   desde el high-poly (Normal, AO, Curvature, Position, Thickness), pintar, exportar
   con el preset Roblox a PNG 8 bits, 1024×1024 máximo.
5. **Substance Designer: materiales tileables.** Para pisos, acero, goma de cinta y
   papel apilado: grafo `.sbs` → publicar `.sbsar` (para reutilizar en Painter) y
   exportar PNG 1024 (Color/Normal OpenGL/Roughness/Metalness) para Studio.
6. **Roblox Studio: integración.** `File › Import 3D` con `Scale Unit = Studs`;
   MeshPart resultante + `SurfaceAppearance` con los mapas; `CollisionFidelity = Box`
   para máquinas (coincide con el footprint de grilla) y `Hull` para props; crear los
   `Attachment` de puertos (`Port_In`, `Port_Out`) desde los Empties exportados;
   agrupar en un `Model` con `PrimaryPart`; guardar como `.rbxm` y anotar los Asset
   IDs en el manifiesto (ASSET_PIPELINE «Asset handoff contract»).
7. **Git.** `.blend`, `.spp`, `.sbs`, `.sbsar`, `.fbx` y los PNG exportados van a
   **LFS** (`.gitattributes` ya tiene reglas para binarios; verificar con
   `git check-attr filter <archivo>` antes de agregar). El manifiesto y este archivo
   van en Git normal. Subir a Roblox sigue requiriendo autorización explícita.

### Escala: 1 unidad de Blender = 1 stud

Trabajar en Blender con la escena por defecto (Unit Scale 1.0) tratando **1 metro =
1 stud**, y en el importador de Studio dejar `Scale Unit = Studs`. Así las medidas de
las tablas se escriben tal cual en Blender. Esto no está fijado por Roblox como
regla: la documentación oficial muestra `0.01` para rigs de avatar en centímetros, así
que la **prueba del cubo de 4×4×4** en el primer import (paso 2) es obligatoria antes
de modelar nada más; si hay desvío, se ajusta `Scale Unit` y se anota aquí.

Orientación: en Roblox el frente de un modelo es **−Z**. En Blender, modelar el frente
mirando a **−Y** y exportar FBX con los valores por defecto (`Forward = −Z`, `Up = Y`)
lo deja correcto. Confirmar en la misma prueba del cubo con una marca en la cara frontal.

## Prioridad

| Tier | Significado |
| --- | --- |
| **P0** | Imprescindible para el loop M1 (M1-09 «primer handoff de placeholders») |
| **P1** | Necesario para que M1 se vea completo (tutorial, social, hub) |
| **P2** | Lanzamiento M2–M4 (cosméticos, pulido, props de ambiente) |
| **Fuera** | Mencionado en documentos pero **excluido** de lanzamiento; no modelar |

---

## 1. Máquinas de producción (P0)

El flujo aprobado es `pila → sorter manual / extractor → buffer → cinta → procesador → salida segura`
(ARCHITECTURE «Core production flow»). Cada máquina usa slots designados con **puertos
tipados** (entrada/salida) y una dirección de frente clara.

| ✓ | Objeto | ID lógico sugerido | Medidas (ancho × prof × alto, studs) | Celdas | Puertos | Notas de diseño | Herramienta (pipeline AAA) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [x] | **Pila de papeleo (supply pile)** | `supply_pile_ground` | 12 × 12 × 6 | 3×3 | 2 salidas, una por bahía: `Port_Supply_0` (−2, 1, −6) hacia −Z y `Port_Supply_1` (+6, 1, +2) hacia +X (D-025) | Capas visuales que retroceden al limpiar; se repone sola sin cobrar Intel. Debe verse «enorme» pero no bloquear la cámara. Al menos 4 estados visuales (lleno → vacío). **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. **Pendiente de Alan (D-025):** hoy tiene una sola boca en (0, 1, −6). | **Gemini (NanoBanana)** concept (estados lleno→vacío) → **Blender** 4 niveles → **Substance Designer** material de papel apilado → **Substance Painter** detalles → **Roblox Studio** |
| [x] | **Estación de clasificación manual (sorter)** | `machine_sorter_manual` | 8 × 8 × 4 | 2×2 | 1 entrada (pila), 1 salida (cinta) | Mesa de clasificación con bandeja. Gratis y ya conectada en el carril starter (D-013). Necesita zona de interacción táctil amplia (hold-to-clear). **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. **Pendiente de Alan (D-025):** su blockout mide 8 × 4 (2×1); pasa a 2×2 con los mismos puertos que el extractor, `Port_Supply_0` (0, 1, +4) hacia +Z y `Port_Out_0` (−2, 1, −4) hacia −Z, para que el extractor lo reemplace en el mismo slot. | **Blender** → **Substance Painter** → **Roblox Studio** import, puertos, colisión |
| [x] | **Extractor tier 1** | `machine_extractor_t1` | 8 × 8 × 8 | 2×2 | 1 entrada (pila), 1 salida (cinta) | Primera automatización (30 Intel, 1 u/s). Sustituye al sorter en el carril gratuito. Estados visibles: trabajando / sin suministro / salida llena / desconectado. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Gemini (NanoBanana)** concept → **Blender** high/low-poly + bake → **Substance Painter** PBR → **Roblox Studio** import, puertos, colisión (hero asset; define el lenguaje visual de toda la maquinaria) |
| [x] | **Extractor tier 2** | `machine_extractor_t2` | 8 × 8 × 10 | 2×2 | igual que t1 | 10 u/s. Mismo footprint que t1 (es un upgrade incremental, no se reubica). Diferenciar con añadidos: brazo extra, tolva, luces. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. **Pendiente de Alan (D-025):** el brazo toca el montante interno de la tolva; el montante va a x ≤ −0.95 o se recorta a Z ≤ 0.7. | **Blender** añadidos sobre t1 → **Substance Painter** texture set propio → **Roblox Studio** |
| [x] | **Extractor tier 3** | `machine_extractor_t3` | 8 × 8 × 12 | 2×2 | igual que t1 | 30 u/s, tope de lanzamiento (D-012). Mismo footprint. Debe leerse como «máxima capacidad» a distancia. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. **Pendiente de Alan (D-025):** el brazo toca el montante interno de la tolva; el montante va a x ≤ −0.95 o se recorta a Z ≤ 0.7. | **Blender** añadidos sobre t2 → **Substance Painter** → **Roblox Studio** luces/partículas de «máxima capacidad» |
| [x] | **Procesador básico (scanner)** | `machine_processor_t1` | 8 × 8 × 8 | 2×2 | 1 entrada (cinta), 1 salida (salida segura) | 60 Intel, 10 u/s. Clasifica papeleo ordinario → Intel. **No** es puerta de descubrimiento; evitar que parezca un «detector de archivos». **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Rodillos bajados a Y 0.5 (tope en FLOW_Y). | **Gemini (NanoBanana)** concept → **Blender** high/low-poly + bake → **Substance Painter** PBR → **Roblox Studio** import, puertos, colisión |
| [x] | **Procesador tier 2** | `machine_processor_t2` | 8 × 8 × 10 | 2×2 | igual que t1 | 350 Intel, 40 u/s. Mismo footprint. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** añadidos sobre t1 → **Substance Painter** → **Roblox Studio** |
| [x] | **Procesador starter (carril gratuito)** | `machine_processor_starter` | 8 × 8 × 6 | 2×2 | igual que t1 | 1 u/s, viene gratis conectado. Derivado de t1 con el gabinete superior acortado para llegar a 6 de alto; carril, rodillos, ScanBar y puertos iguales a t1, y `StatusLight` en (3, 5.5, −3). **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Alto real 5.8; texturas de desgaste diferidas. | **Blender** derivado del t1 (gabinete superior acortado) → **Substance Painter** variante desgastada → **Roblox Studio** |
| [x] | **Salida segura (secure output)** | `machine_secure_output` | 4 × 4 × 6 | 1×1 | 1 entrada | Buzón/contenedor blindado donde el papeleo ordinario termina y paga Intel. Puede estar integrado al procesador si el contrato de puertos lo permite; se lista aparte para no acoplar visual y regla. Es **opcional**: el procesador ya tiene salida integrada, así que si se usa no se paga dos veces. `Port_In_0` en (0, 1, +2) hacia +Z; montaje propuesto por Alan con el centro en (−2, 0, −6) relativo al procesador, que en el layout D-024 cae en las celdas (14, 14) y (0, 1), que `Catalog.layout` no reserva. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** import, puertos, colisión |

## 2. Cintas transportadoras (P0)

M1 soporta **solo cintas rectas y de esquina con rotación de 90°**; sin splitters ni
merges (GDD §5). Precio por **segmento** (5 Intel) con upgrade a 50 u/s (25 Intel).

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Celdas | Notas | Herramienta (pipeline AAA) |
| --- | --- | --- | --- | --- | --- | --- |
| [x] | **Cinta recta básica** | `belt_straight_t1` | 4 × 4 × 1.4 | 1×1 | Superficie a ~1 stud del suelo; puertos entrada/salida en caras opuestas. Pivote en el centro de la celda. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Alto real 1.4 por las barandas; superficie en FLOW_Y 1.0. | **Blender** geometría → **Substance Designer** material tileable → **Roblox Studio** (UV offset animado en Studio) |
| [x] | **Cinta esquina básica** | `belt_corner_t1` | 4 × 4 × 1.4 | 1×1 | Entrada en una cara, salida en la adyacente (giro 90°). Una sola variante; la rotación la hace el servidor. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Alto real 1.4. Goma curva estática, aceptada en M1 (D-025). | **Blender** geometría → **Substance Designer** material tileable → **Roblox Studio** |
| [x] | **Cinta recta mejorada** | `belt_straight_t2` | 4 × 4 × 1.4 | 1×1 | 50 u/s. Mismo mesh con rodillos/color distinto, o material swap. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Alto real 1.45 por las bandas de tier; superficie en FLOW_Y 1.0. | **Substance Designer** variante de material (rodillos/color) sobre el mesh t1 → **Roblox Studio** |
| [x] | **Cinta esquina mejorada** | `belt_corner_t2` | 4 × 4 × 1.4 | 1×1 | Idem. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Alto real 1.45. Goma curva estática, aceptada en M1 (D-025). | **Substance Designer** idem → **Roblox Studio** |
| [ ] | **Cinta recta starter (carril gratuito)** | `belt_straight_starter` | 4 × 4 × 1.4 | 1×1 | P1 (D-025). Visual de las 7 cintas gratuitas a 1 u/s (`belt_starter` en `Catalog`). Variante gastada **solo de material** del mesh de `belt_straight_t1`: mismos puertos y la misma superficie nativa. Hasta que exista se usa `belt_straight_t1`. | **Substance Painter** variante gastada sobre el mesh t1 → **Roblox Studio** |
| [x] | **Marcador de puerto (port gizmo)** | `ui_port_marker` | 1 × 1 × 1 | — | Indicador 3D de puerto libre/ocupado/inválido para la preview de colocación. Es UI en mundo, no mesh de producción. **Alan (2026-10-21):** blockout nativo de Studio (`.rbxmx`); aceptación en juego pendiente. Lo visible mide 0.25 × 0.725 × 0.25; ingeniería lo escala por script hasta 1 × 1 × 1 y lo valida en PC y táctil (D-025). | **Roblox Studio** solamente (Parts/Neon/Gui, scripteado) |
| [x] | **Preview de footprint** | `ui_footprint_preview` | 4 × 4 × 0.2 (tileable) | — | Plano translúcido verde/rojo por celda para «valid footprint preview» (GDD §5). **Alan (2026-10-21):** blockout nativo de Studio (`.rbxmx`); aceptación en juego pendiente. | **Roblox Studio** solamente (Parts/Neon/Gui, scripteado) |

## 3. Descubrimiento y coleccionable (P0)

Una sola clase de archivo, sin variantes ni tiers (D-001). El objeto se revela al
limpiar: en la pila (manual) o en una **bandeja protegida** (extractor).

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Notas | Herramienta (pipeline AAA) |
| --- | --- | --- | --- | --- | --- |
| [x] | **Confidential Archive (el coleccionable)** | `archive_confidential` | **2 × 1.5 × 1.5** (caja de dossier, D-025) | **Un solo modelo.** Debe leerse como «confidencial» a 20 studs de distancia (sello, precinto, color distintivo). Un serial opcional es solo procedencia, no cambia valor (GDD v2.0 §2). Se reutiliza en bandeja, vitrina y reveal. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. **Pendiente de Alan (D-025):** cuerpo oscuro para diferenciarlo de la caja común; las medidas se mantienen. La tapa queda cerrada mientras está en la bandeja. | **Gemini (NanoBanana)** concept → **Blender** high/low-poly + bake → **Substance Painter** PBR → **Roblox Studio** import, puertos, colisión (hero asset principal; máximo presupuesto de textura) |
| [x] | **Demonstration Archive (tutorial)** | `archive_demonstration` | mismas que `archive_confidential` | Geometría derivada del genuino (`.blend` propio de Alan, aceptado en D-025) con etiqueta clara «DEMO / Demonstration» (D-007). No cuenta para rango ni contador. Debe ser imposible confundirlo visualmente con el genuino. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Aceptada como está (D-025). La tapa queda cerrada mientras está en la bandeja. | **Blender** derivado del genuino + **Substance Painter** → **Roblox Studio** |
| [x] | **Bandeja de descubrimiento protegida** | `archive_reveal_tray` | 3 × 3 × 2.5 | Asset separado que se monta en un nicho del extractor, **dentro** de su footprint 2×2 (no ocupa celda propia; ver contrato). Cubierta de cristal que se abre al revelar. Entregable del primer handoff (ASSET_PIPELINE). **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Tapa con bisagra de 0 a 100°, sin choque con el extractor. | **Gemini (NanoBanana)** concept → **Blender** con cubierta animable → **Substance Painter** → **Roblox Studio** animación de apertura y cristal |
| [x] | **Papel ordinario (visual)** | `paper_sheet_visual` | 1 × 1.2 × 0.05 | Hoja/legajo representativo que se anima sobre cintas y en la pila. Presupuesto: 240 por cliente, 120 en plot propio, 30 por plot vecino. Low-poly extremo (≤ 12 triángulos). **Alan (2026-10-21):** blockout con el atlas de papel compartido (sin candidato Painter); Studio pendiente. | **Blender** plano ≤12 tris → **Substance Designer** atlas de hojas (4–8 variantes) → **Roblox Studio** instanciado por presupuesto |
| [x] | **Fajo/caja de papeles (visual)** | `paper_bundle_visual` | 2 × 1.5 × 1 | Variante agrupada para cintas rápidas (50 u/s) donde una hoja por unidad sería ilegible. **Alan (2026-10-21):** blockout con el atlas de papel compartido (sin candidato Painter); Studio pendiente. | **Blender** → **Substance Designer** mismo atlas → **Roblox Studio** |

## 4. Parcela, grilla y hub (P0–P1)

D-018: ocho envolventes de **100 × 100 studs** alrededor de un hub compacto; grilla
construible **16 × 16 celdas de 4 studs = 64 × 64 studs**; el resto son carriles de
acceso. **Solo Ground** en M1 y lanzamiento inicial.

| ✓ | Prio | Objeto | ID lógico sugerido | Medidas (studs) | Notas | Herramienta (pipeline AAA) |
| --- | --- | --- | --- | --- | --- | --- |
| [x] | P0 | **Piso de parcela (envolvente)** | `plot_floor_ground` | 100 × 100 × 1 | Losa industrial. Marca visualmente el borde de propiedad. **Alan (2026-10-21):** blockout nativo de Studio (`.rbxmx`); aceptación en juego pendiente. Pivote en la cara superior (Y 0); la losa ocupa Y −1..0. | **Substance Designer** hormigón industrial tileable → **Roblox Studio** Part/MeshPart con SurfaceAppearance |
| [x] | P0 | **Área construible (grilla)** | `plot_build_grid` | 64 × 64 × 0.1 | Textura/decal de grilla 16×16 sobre el piso; cada celda 4×4. Debe poder ocultarse (visitantes, modo reducido). **Alan (2026-10-21):** blockout nativo de Studio (`.rbxmx`); aceptación en juego pendiente. Hecha con 34 Parts de línea, no con Decal. | **Substance Designer** textura de grilla 16×16 → **Roblox Studio** Decal/Texture con toggle |
| [ ] | P0 | **Bahía de producción fija** | `plot_bay_frame` | 8 × 44 × 0.05 | Marco perimetral pintado en el piso (D-024; interior sin pintar) que cubre una línea fija: fuente + 7 cintas + procesador, 2 × 11 celdas. Sin colisión; puede quedar debajo de las máquinas. Frente −Z en el extremo del procesador, misma rotación que las máquinas de la línea. Centros: bahía 1 en (2, 0, 28) y bahía 2 en (−28, 0, −2) de la parcela. Precio: 0 en M1 (D-023). | **Blender** o **Roblox Studio** Parts (pintura de seguridad de la trim sheet) → **Roblox Studio** |
| [x] | P0 | **Carril de acceso peatonal** | `plot_access_lane` | 4 × 100 × 0.2 (tileable) | Pasillos entre grilla y borde: 18 studs libres por lado. Textura de piso pintado. **Alan (2026-10-21):** blockout nativo de Studio (`.rbxmx`); aceptación en juego pendiente. | **Substance Designer** piso pintado tileable → **Roblox Studio** Parts |
| [x] | P1 | **Muros/cerco de parcela** | `plot_fence_segment` | 8 × 0.5 × 6 | Segmento modular; delimita visualmente sin bloquear cámara. Opcional si el hub ya separa plots. Sin colisión; se repite cada 8. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Colocación (D-024): cuadrado de 96 × 96 entre las columnas de las esquinas, 12 segmentos por lado y 16 studs libres en la entrada. | **Blender** → **Substance Painter** → **Roblox Studio** import, puertos, colisión |
| [x] | P1 | **Cartel de parcela (nombre + rango)** | `plot_sign` | 8 × 0.5 × 4 | Soporte físico del «overhead text» con nombre, rango y total de archivos (GDD v2.0 §3). El texto es `SurfaceGui`/`BillboardGui`, el mesh es el soporte. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** SurfaceGui con nombre/rango/total |
| [ ] | P1 | **Hub central** | `hub_floor` | 100 × 100 × 1 | Baldosa central de la grilla de 3 × 3 (D-024) y origen del mundo. Mismo tipo de pieza que `plot_floor_ground`: cara superior en Y = 0 y losa en Y −1..0. | **Substance Designer** materiales → **Roblox Studio** Part nativa |
| [ ] | P1 | **Calle (tramo)** | `hub_street_segment` | 20 × 100 × 1 | Calle de 20 entre baldosas (D-024). Cara superior en Y = 0, losa en Y −1..0. 12 tramos en el mundo. | **Substance Designer** piso pintado → **Roblox Studio** Part nativa |
| [ ] | P1 | **Calle (cruce)** | `hub_street_cross` | 20 × 20 × 1 | Cruce de dos calles (D-024). Cara superior en Y = 0. 4 cruces en el mundo. | **Substance Designer** piso pintado → **Roblox Studio** Part nativa |
| [x] | P1 | **Spawn / punto de llegada** | `hub_spawn_pad` | 8 × 8 × 0.5 | Plataforma de spawn en el hub. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** import, puertos, colisión |
| [ ] | P2 | **Arco de entrada a parcela** | `hub_plot_gate` | 16 × 2 × 14 | Sin teletransporte en M1 (D-024): se llega a pie. Arco decorativo numerado (1–8), opcional, con abertura libre de 12 × 12, centrado en (0, 0, −48) de la parcela, sobre la línea del cerco. Solo colisionan los postes; la viga superior no tiene colisión ni consulta. | **Gemini (NanoBanana)** concept → **Blender** high/low-poly + bake → **Substance Painter** PBR → **Roblox Studio** import, puertos, colisión |
| [x] | P2 | **Tablero de clasificación global** | `hub_leaderboard_board` | 12 × 1 × 8 | Soporte físico para los boards (archivos / documentos / Intel). Las tablas globales son gate M3; en M1 solo contadores locales. El mesh puede existir antes. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** SurfaceGui de tablas |

## 5. Presentación social y tutorial (P1)

GDD v2.0 §3: cada parcela tiene un **contador de bóveda** y **tres posiciones de
exhibición cosmética** mostrando la misma clase de archivo.

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Notas | Herramienta (pipeline AAA) |
| --- | --- | --- | --- | --- | --- |
| [x] | **Bóveda / vault counter** | `plot_vault` | 8 × 8 × 10 | Caja fuerte o puerta de bóveda con display del total de archivos. Punto focal del plot. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Gemini (NanoBanana)** concept → **Blender** high/low-poly + bake → **Substance Painter** PBR → **Roblox Studio** import, puertos, colisión (hero asset social; display en SurfaceGui) |
| [x] | **Vitrina de exhibición (×3 posiciones)** | `plot_display_case` | 4 × 4 × 6 | Un solo modelo instanciado 3 veces. Muestra `archive_confidential` representativo; **no** un modelo por archivo poseído. Vacía cuando el total es 0. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** metal/base → **Roblox Studio** cristal con material Glass nativo |
| [x] | **Guía de tutorial (marcador 3D)** | `ui_tutorial_marker` | 2 × 2 × 2 | Flecha/anillo pulsante sobre el objetivo actual (una sola cosa resaltada a la vez). Es UI en mundo. Alan lo hizo como flecha estática de 0.8 × 0.8 × 2.0; el pulso lo hace el script. **Alan (2026-10-21):** blockout nativo de Studio (`.rbxmx`); aceptación en juego pendiente. | **Roblox Studio** solamente (Parts/Neon/Gui, scripteado) |
| [x] | **Pedestal de reveal** | `archive_reveal_pedestal` | 4 × 4 × 2 | Opcional. Donde se reproduce la inspección de 3 segundos cuando el hallazgo es manual (en la pila). Puede ser el mismo spot de la pila. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** import, puertos, colisión |

## 6. Props de ambiente del almacén (P2)

Dan contexto de «almacén de archivo industrial» (estilizado, legible). Ninguno
afecta reglas. Mantener presupuesto bajo y materiales compartidos
(ASSET_PIPELINE «Content quality»).

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Notas | Herramienta (pipeline AAA) |
| --- | --- | --- | --- | --- | --- |
| [x] | **Estantería de archivo (alta)** | `prop_shelf_tall` | 8 × 2 × 12 | Llena de cajas de archivo. Fondo de parcela/hub. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Designer** metal tileable + **Substance Painter** desgaste → **Roblox Studio** |
| [x] | **Estantería de archivo (baja)** | `prop_shelf_low` | 8 × 2 × 6 | Variante para no tapar cámara cerca de la grilla. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Designer**/**Substance Painter** compartidos con la alta → **Roblox Studio** |
| [x] | **Caja de archivo (banker box)** | `prop_archive_box` | 2 × 1.5 × 1.2 | Relleno de estanterías y pilas decorativas. Variantes por color/etiqueta vía material, no geometría. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Mantiene su cuerpo #B49A74; el que se oscurece es el archivo (D-025). | **Blender** → **Substance Painter** con variantes de etiqueta por material → **Roblox Studio** |
| [x] | **Pallet con cajas** | `prop_pallet_boxes` | 4 × 4 × 3 | Relleno de esquinas. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** |
| [x] | **Carro de archivo (cart)** | `prop_file_cart` | 3 × 2 × 3.5 | Decorativo; sin interacción. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** |
| [ ] | **Columna industrial** | `prop_column` | 2 × 2 × 32 (fuste) | D-024: estructura de almacén sin techo. Centrada en las 4 esquinas (±48, ±48) de cada parcela y del hub, nunca dentro de la grilla. Brazo opcional para la lámpara con `Mount_Lamp` en (0, 14, −3.5) local, dirección (0, −1, 0) (normal saliente de la cara inferior del brazo, opuesta al +Y del `Mount_Ceiling` de la lámpara) y up (0, 0, 1), de modo que la base de `prop_lamp_hanging` quede a 12 studs. Con el brazo, la envolvente es X ∈ [−1, 1], Z ∈ [−4, 1], Y ∈ [0, 32] (descentrada hacia −Z; Alan la registra como desviación de envolvente). | **Blender** → **Substance Designer** hormigón/acero tileable → **Roblox Studio** |
| [x] | **Lámpara colgante industrial** | `prop_lamp_hanging` | 3 × 3 × 2 | Iluminación de almacén. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. Se monta en el brazo de `prop_column` (`Mount_Lamp`) con la base a 12 studs (D-024). | **Blender** → **Substance Painter** → **Roblox Studio** PointLight/SpotLight |
| [x] | **Puerta de carga / portón** | `prop_loading_door` | 12 × 1 × 10 | Fondo de hub o parcela. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Blender** → **Substance Painter** → **Roblox Studio** |
| [x] | **Señalética de almacén** | `prop_sign_warehouse` | 4 × 0.2 × 2 | Carteles de pasillo/sector; texto **original**, nada copiado. **Alan (2026-10-21):** blockout + candidato de material A; apariencia final y Studio pendientes. | **Gemini (NanoBanana)** concept de estilo gráfico → **Blender** → **Substance Painter** texto original → **Roblox Studio** |
| [ ] | **Techo / cerchas (opcional)** | `env_roof_truss` | 100 × 4 × 2 (segmento) | **Fuera de lanzamiento (D-024):** M1 no tiene techo. Un techo o piso superior de una expansión necesita su propia decisión (D-018) y una prueba de cámara y touch en Studio. No modelar. | **Blender** → **Substance Designer** acero tileable → **Roblox Studio** |

## 7. Cosméticos (P2 — solo con decisión de comercio)

GDD §9: skins de máquinas, decoraciones de parcela y presentaciones de bóveda, **sin
efecto en mecánicas**. No modelar hasta que exista una decisión de comercio (M4).

| ✓ | Objeto | Notas | Herramienta (pipeline AAA) |
| --- | --- | --- | --- |
| [ ] | Skins de extractor / procesador / cintas | Mismas dimensiones y puertos que el base; solo material/detalle. | **Gemini (NanoBanana)** concept de skins → **Substance Painter** texture sets nuevos sobre los mismos meshes → **Roblox Studio** |
| [ ] | Variantes de bóveda y vitrina | Mismas dimensiones. | **Gemini (NanoBanana)** concept → **Substance Painter** → **Roblox Studio** |
| [ ] | Decoraciones de parcela | Dentro de carriles de acceso, nunca sobre la grilla. | **Blender** → **Substance Painter** → **Roblox Studio** |

## 8. Excluido de lanzamiento — NO modelar

| Objeto / idea | Motivo |
| --- | --- |
| Pisos Upper / Basement, escaleras, ascensores, puertos entre pisos | D-018: Ground solamente en M1 y lanzamiento inicial. El concepto de 24 studs entre pisos queda para expansión. |
| Splitter / merger de cintas | GDD §5: sin splitters/merges en M1; backlog F08. |
| Variantes o tiers de archivo (oro, raro, etc.) | D-001: una sola clase. Prohibido. |
| Herramientas manuales (lupa, guantes, carrito jugable) | Backlog F01, Q-008 abierta. |
| Redes de energía/agua, tuberías, generadores | Backlog F16/F17. |
| Mascotas, armas, objetos de robo/trading | D-009. |
| Cajas de loot / ruletas de archivo | Sin pay-for-luck (D-009). |
| Un papel físico por unidad económica | Regla dura: solo visuales representativos. |
| Techo / cerchas (`env_roof_truss`) | D-024: sin techo en M1 ni en el lanzamiento inicial. |

---

## Resumen por prioridad

| Prio | Cantidad | Objetos |
| --- | --- | --- |
| P0 | 24 | 9 máquinas/estaciones, 6 piezas de cinta/UI de colocación, 5 de descubrimiento, 4 de parcela base (piso, grilla, bahía, carril) → **primer handoff M1-09** |
| P1 | 11 | cerco, cartel, hub, 2 piezas de calle (tramo y cruce), spawn, cinta starter, bóveda, vitrina, marcador tutorial, pedestal |
| P2 | 11+ | tablero global, arco de entrada, 9 props de almacén, cosméticos |
| Fuera | 1 | cercha `env_roof_truss` (D-024) |

**Esfuerzo real por familias, no por filas.** De las ~50 filas, solo unas **18 son
proyectos de modelado distintos**: extractor (t1 + añadidos t2/t3), procesador (t1 +
añadidos t2, variante starter por textura), sorter, salida segura, pila (4 estados),
cinta recta, cinta esquina, bandeja, archivo (demo por textura), papel/fajo (atlas),
bahía, cerco, cartel, bóveda, vitrina, arco de entrada, tablero, y el kit de props (estantería,
caja, pallet, carro, columna, lámpara, portón, señal) que comparte una trim
sheet. El resto son variantes de material, instancias repetidas, Parts nativas o UI.

**Primer entregable sugerido (ASSET_PIPELINE):** `machine_extractor_t1` +
`belt_straight_t1` + `machine_processor_t1` + `archive_reveal_tray` +
`archive_confidential`, con medidas, pivotes y puertos validados en Studio antes de
encargar el resto.

## Recomendaciones de diseño para calidad AAA en Roblox

Roblox no es Unreal: no hay LODs por malla, ni mapa de AO, ni cambio de mapas PBR en
tiempo de ejecución, y el cliente móvil es el límite. La calidad «AAA» acá viene de
**siluetas legibles, materiales PBR bien horneados y un kit modular coherente**, no de
polígonos. Estas son las reglas que propongo adoptar desde el primer asset.

### Generales

| ✓ | Recomendación | Por qué |
| --- | --- | --- |
| [ ] | **Presupuesto de triángulos por clase:** hero machines 6 000–10 000; máquinas normales 3 000–6 000; cintas 150–300 por segmento; props grandes 800–2 000; cajas/props chicos 100–400; papel visual ≤ 12. Siempre bajo el máximo de 20 000 | Ocho parcelas × 60 nodos de simulación + visitantes en móvil (30 FPS mínimo, ROADMAP). Cada cinta se repite decenas de veces |
| [ ] | **Presupuesto de texturas:** hero 1024²; máquinas y props medianos 512²; cajas y piezas chicas 256² o atlas compartido | Guía oficial de 256/512/1024 según tamaño del objeto; la memoria de textura es el cuello en móvil |
| [ ] | **Texel density constante:** ~10 px/stud en hero, ~5 px/stud en props | Evita que una caja se vea más nítida que la máquina de al lado; se mide con el checker de Blender |
| [ ] | **Una trim sheet industrial** (1024²) compartida: chapa, remaches, pintura de seguridad amarilla/negra, rejilla, cantos gastados, calcas de advertencia originales | Cercos, columnas, cerchas, bahías, carriles y pallets se texturizan en minutos y quedan coherentes. Es la técnica estándar de kits modulares AAA |
| [ ] | **Un atlas de papel** (512²) con 8 variantes de hoja/legajo/etiqueta | Los 240 papeles visuales comparten una sola textura y un solo material |
| [ ] | **Paleta cerrada:** acero gris-azulado, pintura industrial (un color de marca por tier de máquina: t1 gris, t2 azul, t3 naranja), cartón/papel crema, y **un único acento** rojo lacre reservado al Confidential Archive | El jugador debe reconocer el tier desde la cámara en tercera persona y el archivo debe ser inconfundible a 20 studs. Nada más usa el rojo lacre |
| [ ] | **Siluetas por tier, no solo color:** t2 agrega una tolva o brazo; t3 agrega chimenea/torre con luz | Legibilidad en móvil y con daltonismo; el GDD pide «leerse como máxima capacidad a distancia» |
| [ ] | **Luces de estado como Parts separadas** (`StatusLight`, material Neon + `PointLight`), no en el mapa emissive | `SurfaceAppearance` no se puede cambiar por script en runtime; los cuatro estados (trabajando / sin suministro / salida llena / desconectado) tienen que cambiar de color en vivo |
| [ ] | **Superficie de cinta animada como Part con `Texture`**, no como SurfaceAppearance | Solo `Texture.OffsetStudsU/V` se puede animar por script; el bastidor de la cinta sí lleva SurfaceAppearance |
| [ ] | **Pivote en el centro de la base**, alineado al centro de la celda 4×4 que ocupa, frente a −Z | La colocación en grilla y la rotación de 90° del servidor dependen de un pivote predecible (ASSET_PIPELINE «Origin / pivot / facing») |
| [ ] | **Puertos como Empties en Blender** (`Port_In_0`, `Port_Out_0`) exportados dentro del FBX → `Attachment` en Studio | El contrato de puertos tipados vive en datos, no en el dibujo; el código los lee por nombre |
| [ ] | **Colisión Box para máquinas, Hull para props, y nunca geometría decorativa con colisión** | El footprint lógico es la celda; la cámara y los avatares no deben trabarse con detalles (ASSET_PIPELINE «Collision») |
| [ ] | **Ambient Occlusion horneada dentro del Color** (multiplicar suave, 20–30 %) | Roblox no tiene mapa de AO; sin esto los modelos se ven planos bajo luz uniforme |
| [ ] | **Probar cada asset en Studio con `Lighting.Technology = Future`, en una parcela con iluminación real, en PC y en el emulador de móvil** | Painter y Studio no coinciden en brillo/reflejos según la propia documentación; lo que vale es el render de Studio |

### Blender (modelado)

| ✓ | Recomendación |
| --- | --- |
| [ ] | Escena vacía nueva por asset, Unit Scale 1.0, cuadrícula de 4 unidades activada para alinear a la grilla de celdas. Guardar como `assets/source/blender/<id>.blend` |
| [ ] | Flujo high → low: high-poly con **Bevel modifier + Weighted Normal** (o Subdivision con soporte de aristas); low-poly a mano, sin n-gons, triangulación al exportar. Nunca entregar un Decimate como low-poly final |
| [ ] | Cada arista dura es una costura de UV; **Smooth by Angle** (~30°) para que el bake de normales no sufra gradientes |
| [ ] | Una sola UV, isla con padding de 8 px a 1024; islas de las caras simétricas solapadas para ganar densidad (Roblox permite solape) |
| [ ] | Nombres de objeto = ID lógico: `machine_extractor_t1`, con `_HIGH` para el high-poly y `_COL` si hay malla de colisión aparte. Un material por objeto, llamado igual que el ID |
| [ ] | Antes de exportar: `Apply All Transforms`, origen en la base, escala 1/rotación 0, normales recalculadas hacia afuera, `Mesh › Clean Up` para vértices sueltos |
| [ ] | Export FBX: solo lo seleccionado (`Selected Objects`), `Apply Scalings = FBX Units Scale`, `Forward −Z / Up Y`, `Apply Modifiers`, `Triangulate Faces`, sin leaf bones ni animación |
| [ ] | Variantes de tier: **no duplicar el modelo entero**; `t2` y `t3` son el mesh `t1` más objetos añadidos (tolva, brazo, torre) para que el footprint y los puertos no se muevan nunca |
| [ ] | El papel visual es una **caja fina con volumen** de 1 × 1.2 × 0.05 (12 triángulos), no un plano: la especificación de Roblox pide mallas con volumen y un plano de una cara se ve invisible desde atrás salvo `DoubleSided`. UV apuntando al atlas; se exporta una vez y se instancia en Studio |

### Substance Painter (texturizado)

| ✓ | Recomendación |
| --- | --- |
| [ ] | Proyecto desde la plantilla **Roblox – Surface Appearance**; `Normal Map Format = OpenGL`; `Compute tangent space per fragment` activado; resolución del documento 2048 para pintar y **exportar a 1024** |
| [ ] | Hornear todo desde el `_HIGH`: Normal, World Space Normal, AO, Curvature, Position, Thickness. Si hay gradientes raros en la normal, re-exportar el low-poly con tangentes desde Blender (recomendación de la doc de Roblox) |
| [ ] | Metalness **binaria**: 0 o 1 salvo transiciones de óxido/pintura descascarada. Roblox usa solo flujo metalness |
| [ ] | Roughness **variada**: huellas, polvo, rayones; es lo que separa un asset «AAA» de uno plano. Si aparecen artefactos de Fresnel en Studio, subir roughness ~0.1 (nota de la doc oficial) |
| [ ] | Smart materials propios (`SA_SteelPainted`, `SA_Cardboard`, `SA_Lacquer`) guardados en el shelf del proyecto y reutilizados en todas las máquinas; los de fábrica de Adobe solo como punto de partida |
| [ ] | Texto y calcas (etiquetas «CONFIDENTIAL», números de bahía, señalética): **originales**, hechas como alphas propios; nada tomado de otro juego ni de bancos sin licencia |
| [ ] | El `archive_demonstration` se hace como **texture set alternativo** del mismo proyecto `.spp` del archivo genuino: misma geometría, sello «DEMO», paleta neutra (sin rojo lacre). D-025 acepta el `.blend` derivado que hizo Alan |
| [ ] | Export con el preset Roblox a PNG 8 bits; nombres `<id>_Color.png`, `<id>_Normal.png`, `<id>_Roughness.png`, `<id>_Metalness.png`, `<id>_Emissive.png` (si aplica). Mantener la carpeta `assets/exports/textures/<id>/` |

### Substance Designer (materiales tileables)

| ✓ | Recomendación |
| --- | --- |
| [ ] | Materiales 1024² perfectamente tileables, con parámetros expuestos (color de pintura, desgaste, suciedad) y publicados como `.sbsar` para que Painter y las variantes de skin futuras los reutilicen |
| [ ] | Set inicial: `hormigón_pulido_almacén`, `acero_galvanizado`, `pintura_industrial`, `goma_cinta_rodillos`, `papel_apilado_bordes`, `cartón_archivo`, `piso_pintado_carriles` (líneas de seguridad), y la **trim sheet** |
| [ ] | Export Color / Normal (OpenGL) / Roughness / Metalness en PNG. En Studio son dos sistemas distintos y no se mezclan: los materiales **tileables** van como **`MaterialVariant`** (en `MaterialService`, se aplican a Parts o MeshParts y tilean por `StudsPerTile`); `SurfaceAppearance` es **solo** para mallas únicas con UV propio (máquinas, archivo, props). Corrección 2026-10-19: la versión anterior mezclaba ambos |

### Gemini Pro (NanoBanana), solo referencia

| ✓ | Recomendación |
| --- | --- |
| [ ] | Prompts que pidan **vistas ortográficas** (frente/lado/3⁄4) con fondo neutro y la medida escrita, para traducir directo a Blender |
| [ ] | Nunca pedir «estilo de <juego existente>»; describir el nuestro: «almacén de archivo industrial estilizado, legible, acero y pintura de seguridad, papel crema, un acento rojo lacre» |
| [ ] | Guardar prompt, fecha y modelo junto a cada imagen en `assets/references/<id>/README.md`. Hasta revisar procedencia y licencia (D-020), ninguna imagen ni textura derivada entra al juego |

## Contratos de modelo — primer entregable (M1-09)

Especificación que el modelador necesita para trabajar **sin preguntar**, para los
cinco objetos del primer handoff: `machine_extractor_t1`, `belt_straight_t1`,
`machine_processor_t1`, `archive_reveal_tray` y `archive_confidential`. Son el
«reviewed model contract» del paso 1 de ASSET_PIPELINE. Todo valor es propuesta de
ingeniería hasta que la prueba del cubo y el primer import en Studio lo confirmen;
las medidas de las tablas anteriores mandan si hubiera diferencia.

### Convenciones comunes a todos los contratos

| Tema | Regla |
| --- | --- |
| Sistema de coordenadas local | Origen en el **centro de la base** (Y = 0 es el piso de la parcela). X a la derecha, Y arriba, **−Z es el frente**. Coordenadas en studs. En Blender: frente a −Y y export FBX con `Forward = −Z, Up = Y`. |
| Altura de flujo `FLOW_Y` | **1.0 stud.** Es la altura de la superficie de las cintas y de todos los puertos de entrada/salida. Los papeles visuales viajan con su centro en Y ≈ 1.05. Si cambia, cambia en todos los modelos a la vez. |
| Carril A | Las máquinas de 2×2 celdas tienen sus puertos de cinta en la **celda izquierda** (X = −2), nunca en el centro del modelo (X = 0), porque las cintas ocupan una celda y el puerto debe caer en el centro de esa celda. Así extractor → cintas → procesador forman una línea recta sin desplazamientos. |
| Puertos | Nombre `Port_<Tipo>_<n>`; posición local; **dirección = normal hacia afuera de la cara que cruza el material**. Tipos: `In` (recibe de cinta), `Out` (entrega a cinta), `Supply` (toma de la pila, no es cinta). En Blender **no** usar Empties: el importador de Roblox convierte en `Attachment` la **geometría cuyo nombre termina en `_Att`** (documentado para accesorios; probarlo con la malla del cubo en el primer import). Modelar cada puerto como un cubo diminuto de 0.1 studs llamado `Port_Out_0_Att`, con su origen en la posición exacta y su eje local −Z apuntando en la dirección del puerto. Si la prueba falla, los Attachments se crean a mano la primera vez con las coordenadas de este contrato y quedan guardados en el `.rbxm`. |
| Montajes | Nombre `Mount_<Qué>`: puntos donde se acopla otro asset o una UI (`Mount_Tray`, `Mount_Archive`, `Mount_Prompt`). Misma regla que los puertos (sufijo `_Att` en Blender). |
| Partes móviles | Cada pieza que se mueve es un **objeto separado** en Blender (y una `Part`/`MeshPart` separada en Studio) con su pivote en el eje de giro o en el inicio del recorrido. **El código las mueve** (TweenService / CFrame). Sin huesos ni animaciones horneadas en este entregable. |
| Luz de estado | `StatusLight`: Part de 0.6 × 0.6 × 0.6, material Neon, con `PointLight` hijo. Colores los pone el código: verde = trabajando, ámbar = sin suministro, rojo = salida llena, gris = desconectado. No va en el mapa emissive. |
| Colisión | Máquinas: `CollisionFidelity = Box` sobre la `PrimaryPart` invisible que cubre exactamente el footprint. Decoración, brazos y bandeja **sin colisión** (`CanCollide = false`, `CanQuery = false`). |
| Jerarquía en Studio | `Model` llamado como el ID, `PrimaryPart` = `Footprint` (Part invisible del tamaño exacto del footprint, pivote en la base). Hijos: `Body` (MeshPart principal con `SurfaceAppearance`), partes móviles, `StatusLight`, Attachments. |
| Entregables por asset | `assets/source/blender/<id>.blend` · `assets/exports/models/<id>.fbx` (low-poly) y `<id>_HIGH.fbx` · `assets/source/substance/<id>.spp` · `assets/exports/textures/<id>/<id>_{Color,Normal,Roughness,Metalness}.png` · captura de pantalla del asset en Studio junto a un cubo de 4×4×4 y un R15 por defecto · fila en el manifiesto. |
| Aceptación común | Importa sin advertencias con `Scale Unit = Studs`; bounding box = medidas de la tabla (±0.1); triángulos y resolución dentro del presupuesto; un material y un set UV; normal OpenGL; Attachments en las coordenadas de este contrato; pivote en la base; frente a −Z; Box de colisión no pisa la celda vecina. |

### Contrato 1 — `machine_extractor_t1`

| Campo | Valor |
| --- | --- |
| Footprint / bounding box | 2×2 celdas: X ∈ [−4, 4], Z ∈ [−4, 4], Y ∈ [0, 8]. La silueta puede ser más baja en partes, nunca más ancha. |
| Pivote / frente | Centro de la base (0, 0, 0). Frente −Z: la salida y la bandeja están en la cara frontal. |
| `Port_Supply_0` | (0, 1.0, +4), dirección +Z. Cara trasera, mira a la pila. El papel entra visualmente por acá (tolva o boca ancha de ~6 studs). El servidor decide si exige adyacencia física a la pila; el modelo solo marca la boca. |
| `Port_Out_0` | **(−2, 1.0, −4)**, dirección −Z. Carril A. La cinta que recibe tiene su centro en (−2, 0, −6). La boca de salida mide 3.2 de ancho × 1.5 de alto, con el borde inferior en Y = 1.0. |
| Nicho de bandeja | Hueco en la cara frontal derecha: X ∈ [0.5, 3.5], Y ∈ [1.0, 3.5], Z ∈ [−4, −1]. `Mount_Tray` en **(2, 1.0, −2.5)**, dirección −Z. El nicho queda vacío en el modelo del extractor; lo llena `archive_reveal_tray`. **Actualización 2026-10-21 (Alan):** el nicho queda abierto arriba y atrás para que gire la tapa de la bandeja; el barrido de la tapa ocupa X ∈ [0.6, 3.4] y llega hasta Y = 6.61 y Z = −0.61. Vale para t1, t2 y t3. |
| `Mount_Prompt` | (0, 4.5, −4.2): punto del `ProximityPrompt` de inspección/mejora, cara frontal, altura de pecho de un R15. |
| Partes móviles | `Arm` (brazo recolector): pivote en (0, 6.5, +1), gira sobre X entre 0° (horizontal hacia la pila, +Z) y +60° (baja hacia la boca; en Roblox, la rotación positiva sobre +X baja un brazo que apunta a +Z, verificado por Alan); **longitud máxima 2.5 studs** para que la punta nunca pase de Z = +3.5 ni salga del footprint en ninguna pose (corrección 2026-10-19: la versión anterior de 5 studs desde Z = +2 sobresalía hasta Z = +7). `Drum` (tambor interno visible por una rejilla frontal): cilindro de radio 1, eje X, pivote en (−2, 2.5, −1), gira continuo. El código fija velocidad y amplitud según estado. Validar el barrido completo en el blockout. En t2/t3, `UpgradeHopper` y `CapacityTower` tampoco pueden cruzar el barrido del `Arm` (D-025). |
| `StatusLight` | Centro en (3, 7.5, −3), en una torreta corta sobre la esquina frontal derecha. |
| Lenguaje visual | Es el **hero** de la maquinaria y fija el estilo de t2/t3 y del procesador: cuerpo de chapa gris-azulada, franjas de pintura de tier (t1 = gris claro), remaches y paneles atornillados, tolva trasera, rejilla frontal, un panel de control pequeño junto al `Mount_Prompt`. Sin texto legible salvo calcas originales. |
| Presupuesto | 6 000–10 000 triángulos (todas las partes sumadas). Texturas 1024², un texture set para `Body`; `Arm` y `Drum` comparten ese mismo set (islas reservadas) para no sumar materiales. |
| Qué NO hacer | No tapar la boca de salida con decoración; no colocar nada sobre el nicho (la bandeja debe verse desde el frente y desde 3⁄4); no sobresalir del footprint ni siquiera con el brazo en su extremo. |
| Aceptación propia | Con `belt_straight_t1` colocada en (−2, 0, −6) y la bandeja montada, la línea se ve continua y la tapa de la bandeja abre sin atravesar el cuerpo. |

### Contrato 2 — `belt_straight_t1`

| Campo | Valor |
| --- | --- |
| Footprint / bounding box | 1 celda: X ∈ [−2, 2], Z ∈ [−2, 2], Y ∈ [0, 1.4]: superficie en `FLOW_Y` = 1.0 y barandas laterales hasta Y = 1.4 (t2 llega a 1.45 por las bandas de tier, dentro de la tolerancia). |
| Pivote / frente | Centro de la base. El material fluye de +Z a −Z (entra por atrás, sale por el frente). |
| `Port_In_0` / `Port_Out_0` | (0, 1.0, +2) dirección +Z · (0, 1.0, −2) dirección −Z. |
| Partes | `Frame` (MeshPart: bastidor, patas, rodillos de los extremos horneados en la normal, barandas) con `SurfaceAppearance`. `BeltSurface`: **Part plana nativa** de 3.2 × 4.0 × 0.1 con su cara superior en Y = 1.0, material SmoothPlastic negro, con una instancia `Texture` de goma/tacos (de Designer, 1 tile = 1 stud) que el código desplaza en `OffsetStudsV`. No usar SurfaceAppearance acá: no se puede animar. |
| Zona de papel | El papel viaja centrado en X = 0, Y ≈ 1.05; ancho útil 3.2 → las barandas no deben invadir X ∈ [−1.6, 1.6]. |
| Esquina (`belt_corner_t1`, fuera de este entregable) | Mismo contrato con `Port_Out_0` en (+2, 1.0, 0) dirección +X; la rotación de 90° la aplica el servidor sobre el mismo modelo. Diseñar el `Frame` recto pensando en que la esquina reutilice sus piezas. **D-025:** en M1 la goma de la esquina es una superficie curva estática; la `Texture` animada solo aplica a la recta, y los papeles visuales recorren el arco. |
| Presupuesto | 150–300 triángulos. Textura del `Frame` desde la **trim sheet** industrial (sin texture set propio). Textura de goma 256² tileable. |
| Aceptación propia | Diez segmentos en fila no muestran costuras ni z-fighting entre bastidores; el `Texture` tilea sin salto entre segmentos. |

### Contrato 3 — `machine_processor_t1`

| Campo | Valor |
| --- | --- |
| Footprint / bounding box | 2×2 celdas: X ∈ [−4, 4], Z ∈ [−4, 4], Y ∈ [0, 8]. |
| Pivote / frente | Centro de la base. Frente −Z. |
| `Port_In_0` | **(−2, 1.0, +4)**, dirección +Z. Carril A, cara trasera. Recibe de la cinta cuyo centro está en (−2, 0, +6). Boca 3.2 × 1.5 con borde inferior en Y = 1.0. |
| `Port_Out_0` | (−2, 1.0, −4), dirección −Z. Salida segura: el papel ordinario «desaparece» acá y paga Intel. En M1 puede ser un buzón cerrado integrado al cuerpo; `machine_secure_output` separado queda para después. |
| `Mount_Prompt` | (0, 4.5, −4.2). |
| Partes móviles | `Roller_0` y `Roller_1`: cilindros radio 0.5, eje X, pivotes en (−2, 0.5, +2.5) y (−2, 0.5, −2.5), con el tope en `FLOW_Y` (corrección 2026-10-21, hecha por Alan), visibles bajo la cubierta, giran continuo. `ScanBar`: barra de 3.4 × 0.2 × 0.2 con material Neon que recorre Z ∈ [+2, −2] a Y = 2.2 sobre el papel; pivote en (−2, 2.2, +2). |
| `StatusLight` | (3, 7.5, −3). |
| Lenguaje visual | Hermano del extractor (misma chapa, mismos remaches, misma franja de tier) pero **más cerrado y limpio**: cuerpo tipo gabinete de escaneo con una ventana de cristal (Studio `Glass`) sobre el carril A para ver rodillos y barra. **Evitar** que parezca un detector de archivos: sin lupas, radares ni iconos de «alerta»; es una máquina de oficina industrial que clasifica. |
| Presupuesto | 5 000–8 000 triángulos. Texturas 1024², un texture set; rodillos y barra en islas del mismo set. |
| Aceptación propia | Con la cinta en (−2, 0, +6) la línea extractor → cinta → procesador se ve continua y el papel visual entra por el centro de la boca. |

### Contrato 4 — `archive_reveal_tray`

| Campo | Valor |
| --- | --- |
| Bounding box | 3 × 3 × 2.5: X ∈ [−1.5, 1.5], Z ∈ [−1.5, 1.5], Y ∈ [0, 2.5] en coordenadas **propias**. Montada en el extractor, su origen va en `Mount_Tray` = (2, 1.0, −2.5) del extractor, con el frente (−Z) coincidiendo con la cara frontal del extractor. |
| Pivote / frente | Centro de la base. Frente −Z (la cara que ve el jugador). |
| Partes | `Base`: bandeja metálica con bordes, 3 × 3 × 0.5. `Cover`: cúpula/tapa de cristal (Studio `Glass`, `Transparency` 0.3) de 2.8 × 2.8 × 2.0, **pivote en la arista trasera superior** (0, 2.5, +1.4) para abrir hacia atrás hasta 100°. **Se eligió la bisagra** (Alan; el deslizamiento quedó descartado). Mientras abre, la tapa sale hasta ~0.54 por delante del extractor (el máximo, cerca de 35°), sin colisión. `Lamp`: Part Neon 0.4 × 0.1 × 0.4 en el techo interior de la `Cover`, se enciende en el reveal. |
| `Mount_Archive` | (0, 0.5, 0), dirección +Y: donde el servidor coloca `archive_confidential` (o el demo) al revelar. El archivo (2 × 1.5 × 1.5) se monta con la tapa cerrada; solo la `Cover` abre (D-025). |
| Lenguaje visual | Acabado distinto al resto de la máquina: acero inoxidable cepillado o pintura blanca «sala limpia», con una franja negra/amarilla fina en el borde de la base. Es el único lugar «protegido» de la fábrica y tiene que leerse así. Sin rojo lacre (reservado al archivo). |
| Presupuesto | 400–800 triángulos. Texturas 512² propias para `Base`; `Cover` y `Lamp` son Parts nativas sin textura. |
| Aceptación propia | Montada en el extractor, la `Cover` abre sin atravesar el nicho ni el cuerpo; el archivo colocado en `Mount_Archive` es visible desde el frente y desde 3⁄4 a 20 studs. |

### Contrato 5 — `archive_confidential` (hero principal)

**Forma resuelta (D-025):** caja de dossier de 2 × 1.5 × 1.5, como la hizo Alan.

| Campo | Valor |
| --- | --- |
| Forma (D-025) | **Caja de dossier** cerrada con tapa: 2 × 1.5 × 1.5 (X × Z × Y). Lee mejor a distancia, se apoya estable en la bandeja y la vitrina, y tiene una cara frontal grande para el sello. |
| Alternativa | ~~Carpeta/dossier plano con precinto: 2 × 1.5 × 0.5~~. Descartada (D-025). |
| Pivote / frente | Centro de la base. Frente −Z = cara del sello. |
| Partes | `Body` (caja). `Lid`: tapa, pivote en la arista trasera superior (0, 1.5, +0.75), abre sobre X hasta 110° en la inspección de 3 s **solo con el archivo suelto** (pila o pedestal); montado en la bandeja queda cerrada porque choca con la tapa de vidrio (D-025). `Seal`: precinto/lacre sobre la junta frontal, Part separada para que el código pueda ocultarlo o «romperlo» en el reveal. `Mount_Serial`: Attachment en (0, 0.9, −0.76) para un `SurfaceGui` opcional con serial/fecha (solo procedencia, GDD v2.0 §2). |
| Lenguaje visual | El **único** objeto con el acento rojo lacre: sello, cinta de precinto y una franja diagonal. Cuerpo de cartón prensado oscuro o cuero envejecido con cantos metálicos; una etiqueta original con tipografía de sello («CONFIDENTIAL» o equivalente inventado, nunca copiado). Tiene que ser inconfundible al lado de una `prop_archive_box` ordinaria. **D-025:** se mantienen las medidas (misma planta de 2 × 1.5 que la caja común y el fajo) y la diferencia se logra con un cuerpo de luminancia claramente menor que el de `prop_archive_box` (#B49A74) y que el de las cajas de las estanterías (#806C52) (por ejemplo, #4A3B30 o más oscuro: luminancia relativa ≤ 0.05), más el sello, la franja roja, los cantos de latón y la tapa con sello. |
| Variante demo | `archive_demonstration`: mismo `.blend` y `.spp`, texture set alternativo: sin rojo, etiqueta «DEMO» grande en la tapa y el frente, cuerpo gris neutro. No se modela aparte. **Alan (2026-10-21):** lo hizo como `.blend` propio derivado del genuino, con «DEMO» modelado solo en el frente, sin rojo y con cuerpo claro (crema en el material A) y cantos de acero. Difiere de este contrato (DEMO también en la tapa, cuerpo gris), pero **se acepta así (D-025)**; la prueba a 20 studs en escala de grises también tiene que distinguirlo del genuino. |
| Presupuesto | 1 500–2 500 triángulos (se ve de cerca en el reveal y en la vitrina). Texturas 1024², un texture set. Sin alpha. |
| Dónde se usa | En `Mount_Archive` de la bandeja, en la pila (reveal manual), en las tres `plot_display_case` y en el reveal de inspección a cámara cerca (~6 studs): el detalle de roughness del lacre y el cuero tiene que aguantar esa distancia. |
| Aceptación propia | A 20 studs se distingue de una caja ordinaria en escala de grises por la luminancia del cuerpo, el sello y la franja (D-025); a 6 studs la tapa abre sin intersecar el cuerpo; el `Seal` se puede ocultar sin dejar agujero visible. |

### Qué sigue faltando para el arte final (fuera de este contrato)

- **Moodboard y paleta en hex** del productor/director de arte (referencias de época,
  grado de estilización, cantidad de desgaste). Es la entrada del paso Concept.
- ~~**Decisión caja vs carpeta** para el archivo~~: resuelta, caja de dossier (D-025).
- ~~**Layout de parcela**~~: definido en D-024 y `Catalog.layout`.
- Un **place de prueba en Studio** con la grilla de 4 studs dibujada, un cubo de 4×4×4
  y un R15 por defecto, provisto por ingeniería para la aceptación (M0.1-12 pendiente:
  Studio no está instalado en la Mac actual).

## Decisiones que afectaban este inventario (resueltas)

1. **Tamaño de bahía fija y su precio:** marca de 8 × 44 × 0.05 por línea (D-024); la
   bahía 2 cuesta 0 en M1 (D-023); el precio de bahías posteriores a M1 sigue sin número.
2. **Distribución de las 8 parcelas alrededor del hub:** grilla de 3 × 3 con calles de 20
   y sin teletransporte (D-024).
3. **Almacén cerrado con techo o abierto:** abierto, sin techo en M1; columnas de 32 en
   las esquinas (D-024).
4. **Forma del archivo:** caja de dossier de 2 × 1.5 × 1.5, como la hizo Alan (D-025).
5. **Sector vs piso (Q-012):** un solo sector al lanzamiento (D-022); no hace falta un
   segundo set de entorno.
6. **Bandeja integrada al footprint del extractor:** confirmada; Alan la montó en el nicho
   del extractor sin celda propia.

## Especificación de entorno (D-024)

**Estado: decisión D-024 (2026-10-21).** Reemplaza la propuesta anterior. Las medidas
siguen sujetas a la prueba de cámara y touch en Studio (E-018). Coordenadas en studs;
formato de medidas X × Z × Y, como el resto del archivo.

### Ancla de la parcela y de la grilla

| Tema | Valor |
| --- | --- |
| Origen de la parcela | Centro de la envolvente de 100 × 100. Y = 0 es la cara superior del piso; el `plot_floor_ground` nativo de Alan ya ocupa Y −1..0. Ejes de los contratos: X a la derecha, Y arriba, **entrada en −Z**. |
| Grilla | Centrada: 64 × 64 con 18 studs libres por lado. La esquina mínima de la celda (0, 0) está en (−32, 0, −32) y el centro de la celda (x, z) en **(−30 + 4x, 0, −30 + 4z)**. La celda x crece hacia +X y la z hacia +Z, igual que `Catalog.layout` y `PlotGraph` (dirección 0 = −Z, 1 = +X, 2 = +Z, 3 = −X). |

### Layout de la parcela (`Catalog.layout`)

| Elemento | Celdas | Centro (studs) | Orientación |
| --- | --- | --- | --- |
| Pila | x 0–2 × z 13–15 | (−26, 0, 26) | Sin giro (frente −Z). Una boca por fuente (D-025): `Port_Supply_0` en (−2, 1, −6) local hacia −Z, frente a la fuente de la bahía 2 en (−28, 1, 20); `Port_Supply_1` en (+6, 1, +2) local hacia +X, frente a la fuente de la bahía 1 en (−20, 1, 28). |
| Bahía 1 (starter): fuente | x 3–4 × z 14–15 | (−16, 0, 28) | Flujo +X: el −Z local de las máquinas gira hacia +X. Su parte trasera da a la pila. |
| Bahía 1: cintas | x 5–11, fila 14 | z = 26 | Rotación 1 (+X). Son las 7 cintas gratuitas. |
| Bahía 1: procesador | x 12–13 × z 14–15 | (20, 0, 28) | Igual que la fuente. |
| Bahía 2: fuente | x 0–1 × z 11–12 | (−28, 0, 16) | Flujo −Z, sin giro. Su parte trasera da a la pila. |
| Bahía 2: cintas | columna 0, z 10 a 4 | x = −30 | Rotación 0 (−Z). El jugador las compra. |
| Bahía 2: procesador | x 0–1 × z 2–3 | (−28, 0, −20) | Igual que la fuente. |
| Salida segura (opcional) | (14, 14) y (0, 1) | — | Montaje de Alan, centro en (−2, 0, −6) relativo al procesador. `Catalog.layout` no reserva esas celdas. |

El resto de la grilla, que incluye todo el lado de la entrada, queda libre para caminar
y enrutar.

### Bahía (`plot_bay_frame`)

| Campo | Valor |
| --- | --- |
| Medidas | **8 × 44 × 0.05** (2 × 11 celdas): cubre exactamente fuente + 7 cintas + procesador. |
| Tipo | Marco perimetral pintado, sin colisión ni consulta. Su cara superior (Y = 0.05) queda por encima de las líneas de la grilla nativa (Y 0.015–0.035), y el interior queda sin pintar para que se vean las celdas donde se colocan las cintas; el ancho de la franja lo elige Alan. Puede quedar debajo de las máquinas. |
| Pivote y ejes locales | Centro de la base. Frente −Z = extremo del procesador; misma rotación que las máquinas de su línea. En coordenadas locales, la fuente está centrada en z = +18, las cintas en z −14..+14 y el procesador en z = −18; el carril A en x = −2. |
| Posiciones | Bahía 1 en **(2, 0, 28)**, con el −Z local girado hacia +X. Bahía 2 en **(−28, 0, −2)**, sin giro. |

### Mundo, hub y calles

| Tema | Valor |
| --- | --- |
| Distribución | Grilla de 3 × 3 baldosas de 100 × 100 con calles de 20: el mundo mide 340 × 340 (X, Z ∈ [−170, 170]). El origen del mundo es el centro del hub. |
| Baldosas | Centros en X, Z ∈ {−120, 0, 120}. Hub en (0, 0). Parcelas en sentido horario: 1 (0, −120), 2 (120, −120), 3 (120, 0), 4 (120, 120), 5 (0, 120), 6 (−120, 120), 7 (−120, 0), 8 (−120, −120). |
| Orientación | Entrada = −Z local. Parcelas 8, 1 y 2: el −Z local mira a +Z del mundo (giro de 180°). Parcelas 4, 5 y 6: sin giro. Parcela 3: −Z local hacia −X. Parcela 7: −Z local hacia +X. |
| Calles | Franjas X o Z ∈ [−70, −50] y [50, 70]. Hay 12 tramos `hub_street_segment` de 20 × 100 × 1 y 4 cruces `hub_street_cross` de 20 × 20 × 1 en (±60, ±60). Cara superior en Y = 0. |
| Hub | `hub_floor` de 100 × 100 × 1 en (0, 0); sugerido: `hub_spawn_pad` en su centro. |
| Recorrido | ≈140 studs por el hub y las calles hasta la entrada más lejana (≈9 s a 16 studs/s). Sin teletransporte. |

### Portales, cerco, techo, columnas y lámpara

| Objeto | Valor |
| --- | --- |
| Arco (`hub_plot_gate`, P2, opcional) | 16 × 2 × 14, abertura libre de 12 × 12, centrado en (0, 0, −48) de la parcela. Solo colisionan los postes. |
| Cerco (`plot_fence_segment`, opcional) | Cuadrado de 96 × 96 centrado: 12 segmentos de 8 por lado, con centros en ±4, ±12, …, ±44. Del lado de la entrada faltan los dos segmentos centrales, lo que deja 16 libres (x −8..8). Sin colisión. |
| Techo | No hay en M1. Nada fijo sobre la envolvente de la parcela; `env_roof_truss` queda fuera de lanzamiento. |
| Columnas (`prop_column`) | 2 × 2 × 32, centradas en (±48, ±48) de cada parcela y del hub. Las puntas del cerco quedan escondidas dentro de las columnas. Con el brazo, la envolvente es X ∈ [−1, 1], Z ∈ [−4, 1]. |
| Lámpara | Brazo opcional en la columna con `Mount_Lamp` en (0, 14, −3.5) local, dirección (0, −1, 0) y up (0, 0, 1). El `Mount_Ceiling` de la lámpara (0, 2, 0, hacia +Y) coincide con él, así que la base queda a 12. Ingeniería gira cada columna en pasos de 90° para que el brazo apunte a lo largo de un borde de la parcela. La lámpara ilumina la esquina del margen (radio ≈9 en el piso), no la grilla; la iluminación de la grilla se resuelve en la prueba de Studio (E-018). |
| Despeje de cámara | Lo más alto son las columnas (32), en las esquinas y a 16 studs de la grilla; después vienen el arco (14) en la entrada y los props del margen (≤ 12). |
