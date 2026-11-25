# Pendientes

Última actualización: 2026-11-25.

## Dónde quedamos (2026-11-25)

- Terminadas: el splash animado (P-008) y las fases 0, 1 y 2, salvo la prueba en teléfono (P-006). También se dividió el editor (P-052). El detalle está en `CAMBIOS.md`.
- Verificación: `flutter analyze` sin errores ni advertencias; `flutter test` 92 de 92; `flutter build apk --debug` correcto.
- Commit: ninguno; todo el trabajo de la sesión está sin commit.
- Siguiente: la Fase 3. Solo se analizó el diseño, que está en sus notas; no hay código. Luego, la Fase 5 o la prueba en teléfono (P-006).
- Bloqueado: la Fase 4 espera D-101. El plan de pago con nube espera D-108.

Las tareas están ordenadas por fase. Dentro de cada fase, conviene seguir el orden de los IDs. Las convenciones de prioridad y estado están en [LEEME.md](LEEME.md).

## Fase 0: estabilizar lo que existe

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-006 | Probar en un teléfono Android | Alta | Pendiente | Cámara, galería, Wikimedia, compartir e imprimir PDF y uso sin conexión probados; el resultado queda en `VERIFICACION.md`. |

## Fase 1: ingresos y cobros

Completada el 2026-11-25.

## Fase 2: proforma profesional

Completada el 2026-11-25.

## Fase 3: trabajo durante la obra

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-030 | Consumos reales de obra | Media | Pendiente | Durante la obra se registra material del catálogo, cantidad y costo, separado de lo cotizado. |
| P-031 | Adicionales u órdenes de cambio | Media | Pendiente | Un adicional aumenta el total cobrable y genera su propio PDF. |
| P-032 | Congelar o versionar la proforma enviada | Media | Pendiente | Editar después de enviar crea una versión nueva; la anterior se conserva. |

Notas de diseño propuestas (sin implementar; confirmar antes de empezar):

- Todo va en una migración v11. Las claves foráneas ya se activan después de migrar (D-019).
- **P-030:** un consumo sería un `Gasto` con detalle de material.
  - Columnas nuevas en `gastos`: `material_id`, `cantidad`, `costo_unitario` y `nombre_material`.
  - Así cuenta solo en el balance, los reportes y Movimientos, y pasa a generales si se elimina la obra (D-010).
  - Cuando una obra tiene consumos, su rentabilidad usaría lo consumido en lugar del material cotizado, para no contarlo dos veces.
  - El detalle mostraría lo cotizado frente a lo consumido por material.
  - Al editar un consumo desde Movimientos se abriría su propio formulario.
- **P-031:** tabla `adicionales` (proyecto, descripción, monto sin IVA, fecha) que se borra con el proyecto.
  - Suma al total cobrable, al saldo de cobros (con el IVA del proyecto), a la rentabilidad y al resultado de cierre.
  - PDF propio "Orden de cambio", con el emisor y el cliente de la proforma.
- **P-032:** tabla `versiones_proforma` (proyecto, número, fecha y una copia JSON de la cotización, sus partidas y sus gastos previstos).
  - Al guardar una cotización que no es borrador, el repositorio copia antes la versión anterior.
  - El detalle lista las versiones y permite ver el PDF de cada una.
- **Pantallas:** `detalle_proyecto_pagina.dart` ya tiene 300 líneas. Cobros, consumos, adicionales y versiones deberían ir en un solo componente.
- **Archivos sobre el límite:** `repositorio_sqlite.dart` tiene 305 líneas. Conviene mover las operaciones de proyectos a un mixin, como las de ingresos y clientes.

## Fase 4: modo sueldo mensual

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-040 | Selector de modo y navegación según el modo | Media | Bloqueada | Esperando D-101. |
| P-041 | Sueldo mensual, día de pago y períodos | Media | Pendiente | El usuario registra su sueldo y la app calcula el período actual. |
| P-042 | Gastos personales contra el sueldo | Media | Pendiente | Se ve cuánto queda del sueldo y para cuántos días; presupuesto opcional por categoría. |
| P-043 | Registro de actividades del trabajo | Media | Pendiente | Se guardan fecha, horas, descripción y empresa o jefe. |
| P-044 | Informe mensual de actividades | Baja | Pendiente | Se exporta un PDF con las actividades del mes. |

## Fase 5: publicación y orden del código

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-050 | `applicationId` definitivo y firma de release | Media | Pendiente | El APK o AAB de release se firma con una clave propia guardada fuera del repositorio. |
| P-051 | Retirar la capa `lib/screens/` | Baja | Pendiente | El inicio vive en `funcionalidades/inicio/` y `lib/screens/` ya no existe. |
| P-053 | Unificar el nombre del producto (Coti) | Baja | Pendiente | `DESIGN.md`, `pubspec.yaml` y el código usan el mismo nombre. |
| P-054 | Agregar `.gitattributes` | Baja | Pendiente | Los saltos de línea quedan fijos y `pubspec.lock` deja de aparecer modificado sin motivo. |
| P-055 | Vocabulario genérico o por rubro | Baja | Pendiente | Pospuesta por D-015: se mantiene el vocabulario de construcción. |
| P-056 | Proyecto iOS | Baja | Pendiente | Solo si se decide publicar en iPhone. |
| P-057 | Consultas por período cuando crezcan los datos | Baja | Pendiente | La carga deja de leer toda la base en memoria. |

## Completadas

Mover aquí cada tarea terminada, con su fecha y la referencia a `CAMBIOS.md`.

| ID | Tarea | Fecha |
| --- | --- | --- |
| P-001 | Separar la proforma del cliente del desglose interno | 2026-11-25 (ver `CAMBIOS.md`) |
| P-002 | Evitar gastos que no cuentan en ningún total | 2026-11-25 (ver `CAMBIOS.md`) |
| P-003 | No perder gastos al eliminar una obra | 2026-11-25 (ver `CAMBIOS.md`) |
| P-004 | Unificar el código de documento (COT-####) | 2026-11-25 (ver `CAMBIOS.md`) |
| P-005 | Ejecutar análisis, pruebas y compilación | 2026-11-25 (ver `CAMBIOS.md`) |
| P-007 | Respaldo y restauración de datos | 2026-11-25 (ver `CAMBIOS.md`) |
| P-008 | Corregir el splash screen y animar el logo | 2026-11-25 (ver `CAMBIOS.md`) |
| P-010 | Entidad `Ingreso` y tabla `ingresos` | 2026-11-25 (ver `CAMBIOS.md`) |
| P-011 | Anticipos y abonos por obra; saldo pendiente | 2026-11-25 (ver `CAMBIOS.md`) |
| P-012 | Pantalla de ingresos o de movimientos | 2026-11-25 (ver `CAMBIOS.md`) |
| P-013 | Balance real en Inicio | 2026-11-25 (ver `CAMBIOS.md`) |
| P-014 | Reportes por mes y por categoría | 2026-11-25 (ver `CAMBIOS.md`) |
| P-020 | Datos del emisor | 2026-11-25 (ver `CAMBIOS.md`) |
| P-021 | Datos del cliente y lista de clientes | 2026-11-25 (ver `CAMBIOS.md`) |
| P-022 | IVA configurable | 2026-11-25 (ver `CAMBIOS.md`) |
| P-023 | Validez de la oferta, forma de pago y condiciones | 2026-11-25 (ver `CAMBIOS.md`) |
| P-024 | Estado Rechazada o Cancelada y fecha de creación | 2026-11-25 (ver `CAMBIOS.md`) |
| P-025 | Margen configurable | 2026-11-25 (ver `CAMBIOS.md`) |
| P-026 | Partidas de servicio sin material | 2026-11-25 (ver `CAMBIOS.md`) |
| P-052 | Dividir `editor_proyecto_pagina.dart` | 2026-11-25 (ver `CAMBIOS.md`) |
