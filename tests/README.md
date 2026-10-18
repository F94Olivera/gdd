# Tests

`lune run tests/smoke.luau` verifica el contrato mínimo del proyecto sin frameworks.
Lune no ejecuta el motor Roblox. Al agregar reglas puras, cubrirlas con asserts
bajo Lune; si necesitan APIs de Roblox, probarlas en Studio. No simular el motor.
Antes de integrar: Studio → Test → iniciar servidor con 2 clientes; verificar
Output, replicación, aislamiento y rechazo de solicitudes malformadas.
