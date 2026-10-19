# Inventario de objetos 3D — Find the Secret Archive

**Propósito:** checklist de los modelos 3D que el juego necesita, inferidos de
`docs/GDD.md`, el Master GDD v2.0 original, `DECISIONS.md` (D-012/D-013/D-018),
`ARCHITECTURE.md`, `ASSET_PIPELINE.md`, `ROADMAP.md` y los IDs usados en
`scripts/models/EconomyExperiment.luau`. Marcar `[x]` cuando el modelo exista
(placeholder o final) y anotar el estado en la columna correspondiente.

**Estado (2026-10-19):** ningún modelo existe todavía. El productor confirmó (E-013)
que el arte arranca de cero. Todo lo que sigue es **propuesta de contrato de assets**,
no arte entregado ni medidas aprobadas.

## Cómo leer las medidas

- Unidad: **studs** de Roblox. Un personaje R15 por defecto mide ~5 studs de alto y
  ~4 studs de ancho de hombros; una celda de la grilla mide **4×4 studs** (D-018).
- Formato: **ancho × profundidad × alto** (X × Z × Y), siguiendo la convención
  `Size` de Roblox donde Y es la altura.
- Las medidas de máquinas son **múltiplos exactos de 4 studs** en planta para que
  encajen en la grilla; la altura es libre pero debe dejar la cámara en tercera
  persona legible. Todas son hipótesis a validar con placeholders en M1-09
  (ASSET_PIPELINE §«Export/import process»).
- Las reglas de juego dicen qué hace cada objeto; **la reproducción de un objeto
  nunca es una unidad económica** (240 papeles visuales máx. por cliente, GDD §7).
- Nombres de modelo sugeridos siguen la convención del pipeline
  (`machine_*`, `belt_*`, `archive_*`); el manifiesto futuro los mapea a IDs lógicos.

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

| ✓ | Objeto | ID lógico sugerido | Medidas (ancho × prof × alto, studs) | Celdas | Puertos | Notas de diseño |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | **Pila de papeleo (supply pile)** | `supply_pile_ground` | 12 × 12 × 6 | 3×3 | 1 salida (hacia sorter/extractor) | Capas visuales que retroceden al limpiar; se repone sola sin cobrar Intel. Debe verse «enorme» pero no bloquear la cámara. Al menos 4 estados visuales (lleno → vacío). |
| [ ] | **Estación de clasificación manual (sorter)** | `machine_sorter_manual` | 8 × 4 × 4 | 2×1 | 1 entrada (pila), 1 salida (cinta) | Mesa de clasificación con bandeja. Gratis y ya conectada en el carril starter (D-013). Necesita zona de interacción táctil amplia (hold-to-clear). |
| [ ] | **Extractor tier 1** | `machine_extractor_t1` | 8 × 8 × 8 | 2×2 | 1 entrada (pila), 1 salida (cinta) | Primera automatización (30 Intel, 1 u/s). Sustituye al sorter en el carril gratuito. Estados visibles: trabajando / sin suministro / salida llena / desconectado. |
| [ ] | **Extractor tier 2** | `machine_extractor_t2` | 8 × 8 × 10 | 2×2 | igual que t1 | 10 u/s. Mismo footprint que t1 (es un upgrade incremental, no se reubica). Diferenciar con añadidos: brazo extra, tolva, luces. |
| [ ] | **Extractor tier 3** | `machine_extractor_t3` | 8 × 8 × 12 | 2×2 | igual que t1 | 30 u/s, tope de lanzamiento (D-012). Mismo footprint. Debe leerse como «máxima capacidad» a distancia. |
| [ ] | **Procesador básico (scanner)** | `machine_processor_t1` | 8 × 8 × 8 | 2×2 | 1 entrada (cinta), 1 salida (salida segura) | 60 Intel, 10 u/s. Clasifica papeleo ordinario → Intel. **No** es puerta de descubrimiento; evitar que parezca un «detector de archivos». |
| [ ] | **Procesador tier 2** | `machine_processor_t2` | 8 × 8 × 10 | 2×2 | igual que t1 | 350 Intel, 40 u/s. Mismo footprint. |
| [ ] | **Procesador starter (carril gratuito)** | `machine_processor_starter` | 8 × 8 × 6 | 2×2 | igual que t1 | 1 u/s, viene gratis conectado. Puede ser una variante «vieja/gastada» del básico o el mismo mesh con material distinto. |
| [ ] | **Salida segura (secure output)** | `machine_secure_output` | 4 × 4 × 6 | 1×1 | 1 entrada | Buzón/contenedor blindado donde el papeleo ordinario termina y paga Intel. Puede estar integrado al procesador si el contrato de puertos lo permite; se lista aparte para no acoplar visual y regla. |

## 2. Cintas transportadoras (P0)

M1 soporta **solo cintas rectas y de esquina con rotación de 90°**; sin splitters ni
merges (GDD §5). Precio por **segmento** (5 Intel) con upgrade a 50 u/s (25 Intel).

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Celdas | Notas |
| --- | --- | --- | --- | --- | --- |
| [ ] | **Cinta recta básica** | `belt_straight_t1` | 4 × 4 × 1 | 1×1 | Superficie a ~1 stud del suelo; puertos entrada/salida en caras opuestas. Pivote en el centro de la celda. |
| [ ] | **Cinta esquina básica** | `belt_corner_t1` | 4 × 4 × 1 | 1×1 | Entrada en una cara, salida en la adyacente (giro 90°). Una sola variante; la rotación la hace el servidor. |
| [ ] | **Cinta recta mejorada** | `belt_straight_t2` | 4 × 4 × 1 | 1×1 | 50 u/s. Mismo mesh con rodillos/color distinto, o material swap. |
| [ ] | **Cinta esquina mejorada** | `belt_corner_t2` | 4 × 4 × 1 | 1×1 | Idem. |
| [ ] | **Marcador de puerto (port gizmo)** | `ui_port_marker` | 1 × 1 × 1 | — | Indicador 3D de puerto libre/ocupado/inválido para la preview de colocación. Es UI en mundo, no mesh de producción. |
| [ ] | **Preview de footprint** | `ui_footprint_preview` | 4 × 4 × 0.2 (tileable) | — | Plano translúcido verde/rojo por celda para «valid footprint preview» (GDD §5). |

## 3. Descubrimiento y coleccionable (P0)

Una sola clase de archivo, sin variantes ni tiers (D-001). El objeto se revela al
limpiar: en la pila (manual) o en una **bandeja protegida** (extractor).

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Notas |
| --- | --- | --- | --- | --- |
| [ ] | **Confidential Archive (el coleccionable)** | `archive_confidential` | 2 × 1.5 × 0.5 (carpeta/dossier) o 2 × 1.5 × 2 (caja de archivo) | **Un solo modelo.** Debe leerse como «confidencial» a 20 studs de distancia (sello, precinto, color distintivo). Un serial opcional es solo procedencia, no cambia valor (GDD v2.0 §2). Se reutiliza en bandeja, vitrina y reveal. |
| [ ] | **Demonstration Archive (tutorial)** | `archive_demonstration` | mismas que `archive_confidential` | Misma geometría con etiqueta clara «DEMO / Demonstration» (D-007). No cuenta para rango ni contador. Debe ser imposible confundirlo visualmente con el genuino. |
| [ ] | **Bandeja de descubrimiento protegida** | `archive_reveal_tray` | 4 × 4 × 3 | Se acopla al extractor (1×1 celda adyacente o integrada). Cubierta/cristal que se abre al revelar. Mencionada como entregable del primer handoff (ASSET_PIPELINE). |
| [ ] | **Papel ordinario (visual)** | `paper_sheet_visual` | 1 × 1.2 × 0.05 | Hoja/legajo representativo que se anima sobre cintas y en la pila. Presupuesto: 240 por cliente, 120 en plot propio, 30 por plot vecino. Low-poly extremo (≤ 12 triángulos). |
| [ ] | **Fajo/caja de papeles (visual)** | `paper_bundle_visual` | 2 × 1.5 × 1 | Variante agrupada para cintas rápidas (50 u/s) donde una hoja por unidad sería ilegible. |

## 4. Parcela, grilla y hub (P0–P1)

D-018: ocho envolventes de **100 × 100 studs** alrededor de un hub compacto; grilla
construible **16 × 16 celdas de 4 studs = 64 × 64 studs**; el resto son carriles de
acceso. **Solo Ground** en M1 y lanzamiento inicial.

| ✓ | Prio | Objeto | ID lógico sugerido | Medidas (studs) | Notas |
| --- | --- | --- | --- | --- | --- |
| [ ] | P0 | **Piso de parcela (envolvente)** | `plot_floor_ground` | 100 × 100 × 1 | Losa industrial. Marca visualmente el borde de propiedad. |
| [ ] | P0 | **Área construible (grilla)** | `plot_build_grid` | 64 × 64 × 0.1 | Textura/decal de grilla 16×16 sobre el piso; cada celda 4×4. Debe poder ocultarse (visitantes, modo reducido). |
| [ ] | P0 | **Bahía de producción fija** | `plot_bay_frame` | 16 × 12 × 0.5 | Marco/zona que delimita un slot de máquinas (GDD v2.0 §4 «purchase fixed production bays»). Tamaño a confirmar; **el precio de bahía no tiene número aprobado**. |
| [ ] | P0 | **Carril de acceso peatonal** | `plot_access_lane` | 4 × 100 × 0.2 (tileable) | Pasillos entre grilla y borde: 18 studs libres por lado. Textura de piso pintado. |
| [ ] | P1 | **Muros/cerco de parcela** | `plot_fence_segment` | 8 × 0.5 × 6 | Segmento modular; delimita visualmente sin bloquear cámara. Opcional si el hub ya separa plots. |
| [ ] | P1 | **Cartel de parcela (nombre + rango)** | `plot_sign` | 8 × 0.5 × 4 | Soporte físico del «overhead text» con nombre, rango y total de archivos (GDD v2.0 §3). El texto es `SurfaceGui`/`BillboardGui`, el mesh es el soporte. |
| [ ] | P1 | **Hub central** | `hub_floor` | 60 × 60 × 1 (estimado) | Plaza de spawn entre las 8 parcelas. Medida a definir según distribución (anillo 3×3 con hub al centro ⇒ ~100×100; cruz ⇒ menos). |
| [ ] | P1 | **Spawn / punto de llegada** | `hub_spawn_pad` | 8 × 8 × 0.5 | Plataforma de spawn en el hub. |
| [ ] | P1 | **Teletransporte / puerta a parcela** | `hub_plot_gate` | 8 × 2 × 10 | Portal o puerta numerada por plot (1–8). Opcional si las parcelas son caminables desde el hub. |
| [ ] | P2 | **Tablero de clasificación global** | `hub_leaderboard_board` | 12 × 1 × 8 | Soporte físico para los boards (archivos / documentos / Intel). Las tablas globales son gate M3; en M1 solo contadores locales. El mesh puede existir antes. |

## 5. Presentación social y tutorial (P1)

GDD v2.0 §3: cada parcela tiene un **contador de bóveda** y **tres posiciones de
exhibición cosmética** mostrando la misma clase de archivo.

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Notas |
| --- | --- | --- | --- | --- |
| [ ] | **Bóveda / vault counter** | `plot_vault` | 8 × 8 × 10 | Caja fuerte o puerta de bóveda con display del total de archivos. Punto focal del plot. |
| [ ] | **Vitrina de exhibición (×3 posiciones)** | `plot_display_case` | 4 × 4 × 6 | Un solo modelo instanciado 3 veces. Muestra `archive_confidential` representativo; **no** un modelo por archivo poseído. Vacía cuando el total es 0. |
| [ ] | **Guía de tutorial (marcador 3D)** | `ui_tutorial_marker` | 2 × 2 × 2 | Flecha/anillo pulsante sobre el objetivo actual (una sola cosa resaltada a la vez). Es UI en mundo. |
| [ ] | **Pedestal de reveal** | `archive_reveal_pedestal` | 4 × 4 × 2 | Opcional. Donde se reproduce la inspección de 3 segundos cuando el hallazgo es manual (en la pila). Puede ser el mismo spot de la pila. |

## 6. Props de ambiente del almacén (P2)

Dan contexto de «almacén de archivo industrial» (estilizado, legible). Ninguno
afecta reglas. Mantener presupuesto bajo y materiales compartidos
(ASSET_PIPELINE «Content quality»).

| ✓ | Objeto | ID lógico sugerido | Medidas (studs) | Notas |
| --- | --- | --- | --- | --- |
| [ ] | **Estantería de archivo (alta)** | `prop_shelf_tall` | 8 × 2 × 12 | Llena de cajas de archivo. Fondo de parcela/hub. |
| [ ] | **Estantería de archivo (baja)** | `prop_shelf_low` | 8 × 2 × 6 | Variante para no tapar cámara cerca de la grilla. |
| [ ] | **Caja de archivo (banker box)** | `prop_archive_box` | 2 × 1.5 × 1.2 | Relleno de estanterías y pilas decorativas. Variantes por color/etiqueta vía material, no geometría. |
| [ ] | **Pallet con cajas** | `prop_pallet_boxes` | 4 × 4 × 3 | Relleno de esquinas. |
| [ ] | **Carro de archivo (cart)** | `prop_file_cart` | 3 × 2 × 3.5 | Decorativo; sin interacción. |
| [ ] | **Columna industrial** | `prop_column` | 2 × 2 × 24 | Si el almacén tiene techo. Altura según decisión de techo (ver abajo). |
| [ ] | **Lámpara colgante industrial** | `prop_lamp_hanging` | 3 × 3 × 2 | Iluminación de almacén. |
| [ ] | **Puerta de carga / portón** | `prop_loading_door` | 12 × 1 × 10 | Fondo de hub o parcela. |
| [ ] | **Señalética de almacén** | `prop_sign_warehouse` | 4 × 0.2 × 2 | Carteles de pasillo/sector; texto **original**, nada copiado. |
| [ ] | **Techo / cerchas (opcional)** | `env_roof_truss` | 100 × 4 × 2 (segmento) | Solo si se decide almacén cerrado. Atención a cámara en tercera persona y touch. **Decisión pendiente** del productor/arte. |

## 7. Cosméticos (P2 — solo con decisión de comercio)

GDD §9: skins de máquinas, decoraciones de parcela y presentaciones de bóveda, **sin
efecto en mecánicas**. No modelar hasta que exista una decisión de comercio (M4).

| ✓ | Objeto | Notas |
| --- | --- | --- |
| [ ] | Skins de extractor / procesador / cintas | Mismas dimensiones y puertos que el base; solo material/detalle. |
| [ ] | Variantes de bóveda y vitrina | Mismas dimensiones. |
| [ ] | Decoraciones de parcela | Dentro de carriles de acceso, nunca sobre la grilla. |

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

---

## Resumen por prioridad

| Prio | Cantidad | Objetos |
| --- | --- | --- |
| P0 | 24 | 9 máquinas/estaciones, 6 piezas de cinta/UI de colocación, 5 de descubrimiento, 4 de parcela base (piso, grilla, bahía, carril) → **primer handoff M1-09** |
| P1 | 9 | cerco, cartel, hub, spawn, puerta, bóveda, vitrina, marcador tutorial, pedestal |
| P2 | 11+ | tablero global, 10 props de almacén, cosméticos |

**Primer entregable sugerido (ASSET_PIPELINE):** `machine_extractor_t1` +
`belt_straight_t1` + `machine_processor_t1` + `archive_reveal_tray` +
`archive_confidential`, con medidas, pivotes y puertos validados en Studio antes de
encargar el resto.

## Decisiones pendientes que afectan este inventario

1. **Tamaño de bahía fija y su precio** (sin número aprobado; observación §9 del
   contraste de fuentes).
2. **Distribución de las 8 parcelas alrededor del hub** (anillo vs cruz) ⇒ medidas
   del hub y si hacen falta portales.
3. **Almacén cerrado con techo o abierto** ⇒ columnas, cerchas y restricciones de cámara.
4. **Forma del archivo**: carpeta/dossier plano vs caja de archivo. Afecta bandeja,
   vitrina y legibilidad a distancia.
5. **Sector vs piso (Q-012):** si la primera promoción abre un sector nuevo,
   hará falta un segundo set de piso/entorno visual aunque la grilla sea la misma.
