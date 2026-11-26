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
| D-010 | (Reemplazada por D-025) Al eliminar una obra, sus gastos pasaban a generales (antes D-104). | No perder desembolsos reales. | La relación `gastos.proyecto_id` usa `ON DELETE SET NULL` (P-003). |
| D-011 | El respaldo es un archivo .zip local y gratuito (antes D-105). | Mantener la app sin conexión (D-002) y no cobrar por no perder datos. | La nube queda como posible plan de pago (D-108). |
| D-012 | Los ingresos siguen la misma regla que los gastos: generales o ligados a cotizaciones aprobadas y obras; al eliminar la obra pasan a generales. | Coherencia con D-009 y D-010. | Tabla `ingresos` con `ON DELETE SET NULL` (P-010). |
| D-013 | La pestaña "Gastos" pasa a "Movimientos", con selector Gastos/Ingresos y el balance del mes arriba. | Mantener 5 pestañas y ver ambos en un lugar. | `MovimientosPagina` reutiliza `ExpensePage` e `IngresosPagina` (P-012). |
| D-014 | El balance real es ingresos menos gastos registrados en el mes. | Lo cotizado no es dinero recibido. | Los materiales cotizados no cuentan hasta registrarlos como gasto; P-030 lo mejora. |
| D-015 | Se mantiene el vocabulario de construcción; las partidas sin material se llaman "servicios" (antes D-103). | Menos cambios ahora. | El vocabulario por rubro (P-055) queda pospuesto. |
| D-016 | El IVA se configura en Mi perfil y cada cotización puede cambiarlo: 15 %, 0 % o "no cobro IVA" (antes D-106). | Hay emprendedores en RIMPE que no cobran IVA. | Las cotizaciones previas quedan sin IVA para no cambiar sus totales. |
| D-017 | El total cotizado es la base sin IVA; el cliente paga el total con IVA. | El IVA no es ganancia. | La rentabilidad usa el total sin IVA; el saldo de cobros usa el total con IVA. |
| D-018 | Las partidas de servicio tienen precio propio, no son costo y no reciben margen. | Un servicio ya es precio de venta. | El margen se reparte solo entre materiales y la línea de mano de obra y ejecución. |
| D-019 | Las claves foráneas se activan después de migrar la base. | Las migraciones recrean tablas referenciadas sin borrar en cascada. | `RepositorioSqlite.abrir` ejecuta `PRAGMA foreign_keys = ON` tras abrir. |
| D-020 | Un consumo de material es un gasto con detalle (material, cantidad y costo real). Si una obra tiene consumos, la rentabilidad y el cierre usan lo consumido en lugar del material cotizado. | Reutilizar balance, reportes y Movimientos sin contar el material dos veces. | Conviene registrar todos los materiales de la obra; el detalle muestra lo cotizado frente a lo usado. |
| D-021 | Un adicional es un precio sin IVA que toma el IVA de su proyecto y se borra con él. | Coherencia con la proforma (D-017). | Suma al saldo de cobros, a la rentabilidad, al balance estimado y al cierre; tiene su PDF "Orden de cambio". |
| D-022 | Solo se crea una versión al editar algo comercial (cliente, descripción, fechas, total, IVA, condiciones o partidas) de una cotización que no está en borrador. | Cambiar el estado no altera lo que recibió el cliente. | Las versiones guardan una copia JSON y se pueden volver a exportar en PDF. |
| D-023 | El identificador de la app es `ec.coti.app`; la firma de release se lee de `android/key.properties`, fuera del repositorio. | Identificador propio antes de publicar; las claves no van a git. | Las instalaciones de prueba con `com.example.cotizo_app` se ven como otra app. Pasos en `docs/PUBLICACION.md`. |
| D-024 | La ayuda se da con un tutorial de 4 pantallas la primera vez (se puede saltar y se repite desde Mi perfil) y un botón ⓘ con panel inferior. No se usan globos ni flechas sobre la pantalla. | Ayudar sin interrumpir. | Todos los textos de ayuda están en `widgets/ayuda/temas_ayuda.dart`. |
| D-025 | Un proyecto con cobros o gastos no se elimina: se cancela y conserva su historial. Solo se eliminan los que no tienen dinero (con sus partidas y fotos). Cada gasto e ingreso guarda el texto de su proyecto (`origen`). El dinero devuelto se registra como "Devolución a cliente". | Que todo dinero tenga explicación. Reemplaza a D-010 y a la parte de D-012 sobre eliminar. | La devolución descuenta lo cobrado y el balance del mes, pero no es costo de la obra. |
| D-026 | El bloqueo usa el bloqueo del teléfono (huella, rostro, PIN o patrón) mediante `local_auth`. Se ofrece al terminar el tutorial y se cambia en Mi perfil, confirmando siempre con la huella o clave. Vuelve a pedirse tras 1 minuto fuera de la app. | Coti no guarda claves propias que puedan filtrarse u olvidarse. | Si el teléfono no tiene bloqueo de pantalla, la opción queda desactivada. |
| D-027 | Las fotos de obra se guardan a 1920 px (hasta unos 600 KB, JPEG calidad 85 a 72) con una miniatura de 400 px, sin metadatos de ubicación. | Buena nitidez para mostrar el trabajo sin llenar el teléfono; WhatsApp las reduce a un tamaño parecido. | Las fotos entran en el respaldo .zip. |
| D-028 | Se publica primero gratis y sin límites ni publicidad. La monetización (Premium o pago único, respaldo en la nube) se decide cuando la app crezca. | Conseguir usuarios y opiniones antes de cobrar; la publicidad deja poco y molesta al inicio. | Fase 7 antes que Fase 8; P-084 (publicidad) queda descartada por ahora. |
| D-029 | Por ahora solo se usan las estadísticas de Google Play Console (instalaciones, usuarios activos, reseñas y fallos en Android vitals); no se agregan Firebase, Crashlytics ni Analytics (antes D-110). | No sumar servicios externos ni declaraciones de privacidad antes de publicar. | Si los fallos de la prueba cerrada no alcanzan para diagnosticar, reconsiderar Crashlytics. |

## Por decidir

| ID | Pregunta | Opciones | Afecta |
| --- | --- | --- | --- |
| D-101 | ¿Cómo conviven el modo sueldo y el modo emprendimiento? | a) Un modo elegido al instalar. b) Cambiar de modo desde el perfil, con datos separados. c) Ambos activos, con pestañas según lo activado. | P-040 a P-044 |
| D-108 | ¿Qué modelo de pago se usa cuando la app crezca? | a) Suscripción mensual o anual (unos $2,99 al mes o $24,99 al año; Google cobra 15 %). b) Pago único de por vida (unos $14,99): más simple, pero deja menos a largo plazo. c) Ambos. En todos los casos, cobro con Google Play Billing y RevenueCat, y respaldo en el Google Drive del usuario como beneficio. | P-080 a P-083 |

Al decidir una pregunta, moverla a "Tomadas" con un ID nuevo de la serie D-0## y actualizar las tareas afectadas en `PENDIENTES.md`.
