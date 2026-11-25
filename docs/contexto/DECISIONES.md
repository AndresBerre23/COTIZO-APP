# Decisiones

Aquí se registra lo que ya se decidió, para no volver a discutirlo, y lo que falta decidir antes de implementar ciertas tareas.

## Tomadas

| ID | Decisión | Motivo | Consecuencia |
| --- | --- | --- | --- |
| D-001 | Los montos se guardan como enteros en centavos. | Evitar errores de redondeo. | Toda la lógica opera con `int`; el formato se aplica solo al mostrar. |
| D-002 | La app funciona sin conexión; los datos viven solo en el dispositivo (SQLite). | No exigir cuenta ni internet. | Hace falta un respaldo (P-007). |
| D-003 | El estado se maneja con BLoC/Cubit, sin generación de código. | Menos archivos generados. | Los widgets no hablan con SQLite directamente. |
| D-004 | Los gastos previstos están separados de los registrados. | Un presupuesto no es un desembolso. | Los previstos no entran en la rentabilidad. |
| D-005 | Las partidas guardan una copia del nombre, la unidad y el costo del material. | Conservar el historial. | Editar el catálogo no cambia cotizaciones guardadas. |
| D-006 | "En curso" y "Retrasada" se calculan; no son estados guardados. | Evitar datos redundantes. | El estado guardado solo tiene cuatro valores. |
| D-007 | Un material usado en una cotización no se puede eliminar. | Integridad de las partidas. | Solo se puede editar. |
| D-008 | La proforma del cliente reparte el margen en el precio de cada partida (antes D-102). | El cliente no debe ver costos internos ni el margen. | Los gastos previstos y la mano de obra se agrupan en una línea "Mano de obra y ejecución"; el desglose queda solo en la app (P-001). |
| D-009 | Un gasto se puede asignar a cotizaciones aprobadas y a obras, y cuenta en el balance (antes D-107). | Hay compras antes de iniciar la obra. | Borradores y enviadas no aceptan gastos (P-002). |
| D-010 | Al eliminar una obra, sus gastos pasan a generales (antes D-104). | No perder desembolsos reales. | La relación `gastos.proyecto_id` usa `ON DELETE SET NULL` (P-003). |
| D-011 | El respaldo es un archivo .zip local y gratuito (antes D-105). | Mantener la app sin conexión (D-002) y no cobrar por no perder datos. | La nube queda como posible plan de pago (D-108). |
| D-012 | Los ingresos siguen la misma regla que los gastos: generales o ligados a cotizaciones aprobadas y obras; al eliminar la obra pasan a generales. | Coherencia con D-009 y D-010. | Tabla `ingresos` con `ON DELETE SET NULL` (P-010). |
| D-013 | La pestaña "Gastos" pasa a "Movimientos", con selector Gastos/Ingresos y el balance del mes arriba. | Mantener 5 pestañas y ver ambos en un lugar. | `MovimientosPagina` reutiliza `ExpensePage` e `IngresosPagina` (P-012). |
| D-014 | El balance real es ingresos menos gastos registrados en el mes. | Lo cotizado no es dinero recibido. | Los materiales cotizados no cuentan hasta registrarlos como gasto; P-030 lo mejora. |
| D-015 | Se mantiene el vocabulario de construcción; las partidas sin material se llaman "servicios" (antes D-103). | Menos cambios ahora. | El vocabulario por rubro (P-055) queda pospuesto. |
| D-016 | El IVA se configura en Mi perfil y cada cotización puede cambiarlo: 15 %, 0 % o "no cobro IVA" (antes D-106). | Hay emprendedores en RIMPE que no cobran IVA. | Las cotizaciones previas quedan sin IVA para no cambiar sus totales. |
| D-017 | El total cotizado es la base sin IVA; el cliente paga el total con IVA. | El IVA no es ganancia. | La rentabilidad usa el total sin IVA; el saldo de cobros usa el total con IVA. |
| D-018 | Las partidas de servicio tienen precio propio, no son costo y no reciben margen. | Un servicio ya es precio de venta. | El margen se reparte solo entre materiales y la línea de mano de obra y ejecución. |
| D-019 | Las claves foráneas se activan después de migrar la base. | Las migraciones recrean tablas referenciadas sin borrar en cascada. | `RepositorioSqlite.abrir` ejecuta `PRAGMA foreign_keys = ON` tras abrir. |

## Por decidir

| ID | Pregunta | Opciones | Afecta |
| --- | --- | --- | --- |
| D-101 | ¿Cómo conviven el modo sueldo y el modo emprendimiento? | a) Un modo elegido al instalar. b) Cambiar de modo desde el perfil, con datos separados. c) Ambos activos, con pestañas según lo activado. | P-040 a P-044 |
| D-108 | ¿Se ofrece un plan de pago con respaldo en la nube y sin límites? | a) Plan mensual: nube, sincronización entre equipos y sin límite de proformas (hoy no hay límite). b) Pago único sin nube. c) Sin plan de pago. Requiere servidor, cuentas y cobro con Google Play. | Nueva fase futura |

Al decidir una pregunta, moverla a "Tomadas" con un ID nuevo de la serie D-0## y actualizar las tareas afectadas en `PENDIENTES.md`.
