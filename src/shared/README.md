# Shared

Módulos Luau compartidos, tipos y constantes públicos. Todo lo que vive aquí
se replica al cliente: nunca guardar secretos ni lógica de autoridad.
No agregar un init.luau a esta carpeta: cambiaría su representación en Rojo.

- `Catalog.luau` (M1-01): definiciones públicas versionadas con ID estable para la
  línea starter, extractor/procesador/cinta, rangos y la primera promoción. Cada valor
  cita su decisión. Se valida al cargarse y queda congelado. Sin bahías ni buffers
  hasta que tengan números aprobados.
