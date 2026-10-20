# Fuentes originales del productor

**Qué es:** transcripciones textuales de los tres documentos que el productor entregó
como fuente de verdad. Cumple el pedido del Master GDD v2.0 §8 «Keep the GDD,
decision log, implementation plan, and balance configuration in the repository»
(M0.1-02, Q-013). Los binarios originales **no** se suben al repo; se identifican
por su SHA-256.

**Autoridad:** decisiones explícitas del productor en [DECISIONS.md](../DECISIONS.md)
> estas fuentes > el resumen de trabajo [GDD.md](../GDD.md) y los demás documentos.
No hay versión 2.1: el productor confirmó el 2026-10-20 que el GDD canónico es la
**versión 2.0** (Q-011). Las menciones a «v2.1» dentro del propio backlog (hoja
*Decision guide*) se conservan tal cual porque son texto del original.

| Transcripción | Archivo original | SHA-256 del original | Metadatos |
| --- | --- | --- | --- |
| [MASTER_GDD_v2.0.md](MASTER_GDD_v2.0.md) | `Find_the_Secret_Archive_Master_GDD_v2.docx` | `a0da3515d87623409af3f685b3d3092fe419496bb959d47e4998b71a9efb34be` | Version 2.0, 15 Oct 2026; 8 secciones numeradas |
| [CLAUDE_MASTER_PROMPT_v2.0.md](CLAUDE_MASTER_PROMPT_v2.0.md) | `Find_the_Secret_Archive_Claude_Master_Prompt_v2.docx` | `b529da6ff36c539d8d5c14d34f2a3a96e2776c90d7ccadd0a1c0ec2744ba65bf` | Version 2.0 |
| [FUTURE_CONCEPTS_BACKLOG.md](FUTURE_CONCEPTS_BACKLOG.md) | `Find_the_Secret_Archive_Future_Concepts_Backlog.xlsx` | `39f22529aabc9dcf1ad1102795815ea2338253e6906c62ca9a5eff591e9f99ec` | Hojas *Feature backlog* (F01–F19, todas Proposed) y *Decision guide* |

**Ubicación de los originales:** copia del productor en
`~/Downloads/Find the Secret Archive/` (máquina del desarrollador). Para comprobar que
una copia es la misma: `shasum -a 256 <archivo>` y comparar con la tabla.

**Método de transcripción (2026-10-20):** lectura directa del XML de cada archivo
(`word/document.xml`; `xl/sharedStrings.xml` y hojas del libro) con un script de un
solo uso, sin dependencias. Se conserva todo el texto en su orden y las tablas como
tablas Markdown. Los estilos *Title*, *Heading1* y *Heading2* pasan a `#`, `##` y `###`.
Se pierden el formato tipográfico, los colores de celda y los saltos de página; por
eso el conteo de páginas no se puede comprobar desde aquí. Si un texto difiere entre
la transcripción y el original, manda el original.

**Reglas de mantenimiento:** no editar las transcripciones a mano. Si el productor
entrega una versión nueva, se agrega una transcripción nueva con su hash y se
registra el cambio en DECISIONS.md, sin sobrescribir la anterior.
