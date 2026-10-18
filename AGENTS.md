# Convenciones del repositorio

- Usar Luau nativo y `--!strict` en cada script; funciones públicas con tipos explícitos.
- `src/server`: autoridad, persistencia y validación. `src/client`: entrada y presentación.
  `src/shared`: tipos, constantes públicas y reglas puras; nunca secretos.
- No agregar gameplay, dependencias, frameworks ni abstracciones sin necesidad concreta.
- No agregar backend Node.js ni monorepo. Preferir módulos pequeños y orden de inicio explícito.
- Validar en servidor cada solicitud: tipo, límites, permisos, contexto, frecuencia y estado.
  Nunca confiar en monedas, inventario, daño o posiciones informados por el cliente.
- No publicar experiencias, subir assets, crear remotos ni hacer push sin autorización.
- Git es la fuente de verdad de código y configuración. No editar scripts sincronizados en Studio.
- Al cambiar el árbol Rojo, revisar qué instancias administra antes de sincronizar un place existente.
- No versionar secretos, builds, sourcemaps ni paquetes descargados. Sí versionar `wally.lock`.
- Binarios 3D usan las reglas LFS de `.gitattributes`; no convertir archivos de texto a LFS.
- Ejecutar `lune run scripts/check.luau` antes de entregar. Selene valida `src` (Roblox);
  scripts/tests usan APIs de Lune y se ejecutan como parte del check, sin fingir APIs del motor.
- Para lógica nueva, agregar tests de comportamiento relevantes. No simular Roblox completo.
- Reportar validaciones realmente ejecutadas y distinguir pruebas locales de CI/Studio pendientes.
- Actualizar README ante cambios de setup, comandos o ownership de assets.
