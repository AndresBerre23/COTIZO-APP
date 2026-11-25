# Estado del producto

Última revisión: 2026-11-25. `flutter analyze` sin errores ni advertencias, `flutter test` 92 de 92 y APK de depuración compilado.

## Propuesta original

Aplicación móvil para que emprendedores o cualquier persona manejen sus ingresos y gastos. Tiene tres pilares:

1. **Cotizaciones y proformas (emprendedor):** crear cotizaciones y proformas registrando materiales y gastos, con la posibilidad de agregar más durante el trabajo.
2. **Ingresos y gastos:** saber cuánto entra, cuánto sale y cuánto queda.
3. **Trabajo con sueldo mensual:** registrar el sueldo y los gastos para saber cuánto va quedando y, opcionalmente, las actividades realizadas en el trabajo.

Leyenda de estado: **Hecho**, **Parcial**, **Falta**.

## 1. Cotizaciones y proformas

| Funcionalidad | Estado | Notas |
| --- | --- | --- |
| Catálogo de materiales con unidad, costo e imagen | Hecho | Galería, cámara o Wikimedia Commons. |
| Asistente de cotización en 4 pasos | Hecho | Cliente y fechas, materiales y servicios, gastos previstos, precio y condiciones. |
| Precio sugerido | Hecho | Margen configurable en Mi perfil (20 % por defecto). |
| Estados de cotización | Hecho | Borrador, Enviado, Aprobado, Finalizado, Rechazado y Cancelado, con fecha de creación. |
| Ciclo de obra: iniciar, finalizar, alerta de retraso | Hecho | |
| Proforma PDF | Hecho | Emisor con logo, datos del cliente, precios finales (D-008), IVA (D-016), validez, forma de pago y condiciones. |
| Reporte de cierre PDF | Hecho | |
| Archivo de documentos con búsqueda y filtros | Hecho | |
| Agregar materiales durante la obra | Parcial | Solo como gasto con monto. Editar una obra en curso modifica la proforma enviada (P-030 a P-032). |
| Partidas de servicio sin material | Hecho | Con precio propio y sin margen (D-018). |
| Datos completos del cliente y lista de clientes | Hecho | Autocompletado en el editor y página Clientes. |

## 2. Ingresos y gastos

| Funcionalidad | Estado | Notas |
| --- | --- | --- |
| Gastos generales o por proyecto, con fecha y hora | Hecho | Solo cotizaciones aprobadas y obras aceptan gastos (D-009); al eliminar una obra, sus gastos pasan a generales (D-010). |
| Búsqueda, filtros y total de gastos | Hecho | |
| Registro de ingresos o cobros | Hecho | Entidad `Ingreso` con categoría y método de pago (D-012). |
| Anticipos, abonos y saldo pendiente por cliente | Hecho | Sección "Cobros" en el detalle del proyecto. |
| Balance real: cobrado menos gastado | Hecho | En Inicio y Movimientos, separado del estimado de obras (D-014). |
| Reportes por mes y por categoría | Hecho | Reporte mensual con exportación a PDF. |
| Respaldo y restauración de datos | Hecho | Archivo .zip local desde Mi perfil (D-011). Plan con nube por decidir (D-108). |

## 3. Modo sueldo mensual

| Funcionalidad | Estado | Notas |
| --- | --- | --- |
| Elegir modo: emprendimiento o empleo | Falta | Depende de D-101 (P-040). |
| Sueldo mensual y período | Falta | P-041. |
| Gastos personales contra el sueldo: "cuánto me queda" | Falta | P-042. |
| Registro de actividades del trabajo | Falta | P-043. |
| Informe mensual de actividades | Falta | P-044. |

## Errores conocidos

Ninguno registrado. Los errores P-001 a P-004 se corrigieron el 2026-11-25.

## Estado técnico

- **Stack:** Flutter 3.32 / Dart 3.8, SQLite (`sqflite`), BLoC/Cubit, `pdf` y `printing`. Esquema SQLite en la versión 10.
- **Plataformas:** solo Android está configurado; no hay iOS ni web.
- **Arranque:** splash nativo de color sólido y pantalla animada en Flutter (`funcionalidades/arranque/`).
- **Pruebas:** 23 archivos de prueba, 92 pruebas aprobadas. No se ha probado en un teléfono real (P-006).
- **Publicación:** `applicationId` sigue como `com.example.cotizo_app` y la versión release se firma con la clave de depuración.
- **Deuda técnica:**
  - `repositorio_sqlite.dart` tiene 305 líneas, sobre el límite de 300.
  - `lib/screens/` es una capa heredada; `dashboard_screen.dart` tiene lógica real.
  - El nombre del producto cambia según el archivo: Coti, Cotizo y ObraPro.
  - `pubspec.lock` aparece modificado por completo, probablemente por saltos de línea (CRLF/LF).
