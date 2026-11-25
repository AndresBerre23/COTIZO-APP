# Bitácora de cambios

Las entradas más recientes van primero. Hay una entrada por tarea o por sesión de trabajo.

## Formato

```text
## AAAA-MM-DD: título corto
- Tarea: P-### (si aplica)
- Qué: lo que cambió
- Por qué: motivo
- Archivos: rutas principales
- Verificación: análisis, pruebas o revisión realizada
- Commit: hash, cuando se haga
```

---

## 2026-11-25: fase 2, proforma profesional

- Tareas: P-020 a P-026 y P-052. Decisiones D-015 a D-019.
- Qué:
  - Esquema v10 (`datos/migracion_v10.dart`):
    - Tabla `clientes`.
    - `proyectos` recreada con los estados Rechazado y Cancelado, fecha de creación, cliente, IVA, validez, forma de pago y condiciones.
    - `items_proyecto` admite servicios sin material.
    - Preferencias amplían con los datos del negocio y los ajustes de cotización.
    - Las instalaciones nuevas pasan por el mismo paso de migración.
  - P-020: Mi perfil tiene "Datos del negocio" (nombre comercial, RUC o cédula, teléfono, correo, dirección y logo). El logo se incluye en el respaldo.
  - P-021: el campo de cliente sugiere clientes guardados y tiene datos de contacto opcionales; el cliente se crea o actualiza al guardar. Hay una página Clientes, desde Cotizaciones.
  - P-022 y P-023: IVA (15 %, 0 % o no cobro IVA), validez, forma de pago y condiciones en el paso de precio, con valores por defecto en Mi perfil.
  - P-024: estados Rechazado y Cancelado; el orden "Más recientes" usa la fecha de creación.
  - P-025: margen sugerido configurable en Mi perfil; cada cotización guarda el suyo.
  - P-026: partidas de servicio con precio propio; no son costo ni reciben margen.
  - La proforma PDF muestra emisor y cliente con sus datos, "Válida hasta", subtotal, IVA y total, forma de pago y condiciones, en una sola página. El aviso legal pasa al pie y las cantidades se muestran sin decimales sobrantes.
  - P-052: el estado del editor pasa a `EstadoEditorCotizacion` y `DatosProformaEditor`; `editor_proyecto_pagina.dart` queda en 299 líneas.
  - Refactorizaciones:
    - `AlmacenImagenLocal` reúne los almacenes de imágenes.
    - Mi perfil se dividió en secciones (262 líneas).
    - Los PDF quedaron bajo 300 líneas.
    - `confirmarAccion` admite un texto de cancelar.
- Por qué: la propuesta pide proformas profesionales con datos completos.
- Archivos: `datos/*`, `dominio/*`, `funcionalidades/{cotizaciones,clientes,perfil,proformas}/*`, `widgets/selector_iva.dart`.
- Verificación: `flutter analyze` sin errores ni advertencias; `flutter test` 92 de 92, con pruebas nuevas de cálculos, repositorio v10, editor con servicio e IVA, perfil y clientes a 360, 800 y 1440 px; PDF y capturas revisadas; `flutter build apk --debug` correcto.
- Commit: pendiente.

## 2026-11-25: fase 1, ingresos, cobros y reportes

- Tareas: P-010 a P-014. Decisiones D-012 a D-014.
- Qué:
  - P-010: entidad `Ingreso` (monto, fecha, categoría, método, nota y proyecto opcional), esquema v9 con tabla `ingresos`. Las operaciones viven en `operaciones_ingresos_sqlite.dart`, y `guardarRegistro` y `exigirRegistro` pasaron a `utilidades_sqlite.dart`.
  - P-011: sección "Cobros" en el detalle del proyecto, con cobrado, saldo pendiente, barra de avance y registro de anticipos o abonos.
  - P-012: la pestaña "Gastos" pasa a "Movimientos", con selector Gastos/Ingresos. Gastos e ingresos comparten filtros (`filtrar_movimientos.dart`), tarjeta (`TarjetaMovimiento`) y campos de formulario (`widgets/movimientos/`). El formulario de gastos bajó de 266 a 165 líneas.
  - P-013: tarjeta "Balance real del mes" (cobrado menos gastado) en Inicio y Movimientos, separada del balance estimado de obras.
  - P-014: reporte mensual con navegación entre meses, totales y barras por categoría, y PDF para compartir.
- Por qué: la propuesta pide saber cuánto entra, cuánto sale y cuánto queda.
- Archivos: `dominio/entidades/{ingreso,movimiento}.dart`, `dominio/categorias_ingreso.dart`, `dominio/calcular_{cobros_proyecto,resumen_mes}.dart`, `datos/*`, `funcionalidades/{ingresos,movimientos,reportes}/*`, `widgets/movimientos/*`, `widgets/tarjeta_movimiento.dart`, `app.dart`, `screens/dashboard_screen.dart`.
- Verificación: `flutter analyze` sin errores ni advertencias; `flutter test` 81 de 81, con pruebas nuevas de repositorio, resumen mensual, cobros, registro de ingresos y adaptación a 360, 800 y 1440 px; capturas revisadas de Movimientos (móvil), reporte (escritorio) y detalle (móvil); `flutter build apk --debug` correcto.
- Commit: pendiente.

## 2026-11-25: código de documento y suite de pruebas en verde

- Tareas: P-004, P-005.
- Qué:
  - P-004: `codigoDocumento` y `codigosBusqueda` en `core/formato.dart`; la app y el PDF muestran `COT-0001`, y la búsqueda acepta 3 o 4 dígitos.
  - P-005: se pusieron al día las pruebas desactualizadas y se corrigieron tres errores reales (detalle en `docs/VERIFICACION.md`):
    - Desborde de la barra del asistente a 360 px.
    - `RangeError` al optimizar datos que no son imagen.
    - Validación duplicada del monto en gastos.
  - El formulario de gastos conserva el proyecto con el que se abrió aunque no admita gastos, para no fallar.
- Por qué: P-004 era un error conocido; P-005 deja una base verificable antes de nuevas funciones.
- Archivos: `core/formato.dart`, pantallas que mostraban el código, `cotizaciones/componentes/progreso_cotizacion.dart`, `core/imagenes/optimizar_imagen.dart`, `gastos/formulario_gasto.dart`, `test/apoyo/con_cubits.dart`, `test/presentacion/*`, `test/dominio/*`, `docs/VERIFICACION.md`.
- Verificación: `flutter analyze` sin errores ni advertencias; `flutter test` 74 de 74; `flutter build apk --debug` correcto.
- Commit: pendiente.

## 2026-11-25: fase 0, proforma, gastos y respaldo

- Tareas: P-001, P-002, P-003, P-007. Decisiones D-008 a D-011; se abre D-108 (plan de pago con nube).
- Qué:
  - P-001: la proforma del cliente (PDF y vista previa) reparte el margen en cada partida; gastos previstos y mano de obra van en "Mano de obra y ejecución". El desglose interno se ve en la app, en una tarjeta aparte. El reporte de cierre no cambia.
  - P-002: solo cotizaciones aprobadas y obras aceptan gastos. El balance de Inicio incluye las aprobadas, y un gasto ligado a un proyecto que no admite gastos se suma a los generales.
  - P-003: esquema v8; `gastos.proyecto_id` pasa a `ON DELETE SET NULL`. Al eliminar una obra, sus gastos quedan como generales.
  - P-007: respaldo .zip (base, imágenes de materiales y foto de perfil) desde Mi perfil, para compartir; restauración con confirmación, validación del archivo y copia interna previa de los datos actuales. La app se reinicia en el splash tras restaurar.
  - `confirmar.dart` gana `confirmarAccion`, reutilizado por `confirmarEliminacion`.
- Por qué: errores conocidos P-001 a P-003 y riesgo de perder todos los datos al desinstalar.
- Archivos: `dominio/calcular_partidas_cliente.dart`, `dominio/calcular_balance_obras.dart`, `funcionalidades/proformas/*`, `funcionalidades/gastos/formulario_gasto.dart`, `funcionalidades/inicio/resumen_financiero.dart`, `datos/esquema_sqlite.dart`, `datos/repositorio_sqlite.dart`, `funcionalidades/respaldo/*`, `aplicacion/control_datos_app.dart`, `app.dart`, `pubspec.yaml` (`archive`, `file_picker`, `share_plus`).
- Verificación: `flutter analyze` sin errores; `flutter test` 56 aprobadas y las mismas 16 fallas previas; pruebas nuevas de partidas, balance, migración v8 y respaldo; `flutter build apk --debug` compila. No probado en un teléfono real (compartir y elegir archivo quedan para P-006).
- Commit: pendiente.

## 2026-11-25: splash screen animado

- Tarea: P-008
- Qué:
  - El splash nativo queda solo con el color de marca; en Android 12+ usa un ícono transparente.
  - Nueva pantalla de arranque en Flutter: el logo se dibuja por etapas (arco de la C, barras, flecha), luego aparecen el nombre y el lema, con fondo en movimiento.
  - Si los datos tardan más que la animación, aparece una barra de progreso; al entrar, el color de marca se desvanece sobre la app.
  - Respeta la opción del sistema de reducir animaciones.
  - `app.dart` une la apertura del almacenamiento y la carga de ajustes en un solo `Future`.
- Por qué: Android 12+ recorta el ícono del splash en un círculo y `Coti-SplashScreen.png` ocupa todo el lienzo, por eso el logo se veía cortado.
- Archivos: `lib/funcionalidades/arranque/*`, `lib/app.dart`, `pubspec.yaml`, `assets/images/arranque_transparente.png`, `android/app/src/main/res/*` (generados por `flutter_native_splash`).
- Verificación: `flutter analyze` sin errores; `flutter test` con las mismas 16 fallas que antes del cambio (ver P-005); capturas de la animación en 390, 820, 1440 y 844x390 px. No probado en un teléfono real.
- Commit: pendiente.

## 2026-11-25: revisión del proyecto y carpeta de contexto

- Qué:
  - Se revisó el código frente a la propuesta del producto.
  - Se creó `docs/contexto/` con `LEEME.md`, `ESTADO.md`, `PENDIENTES.md`, `CAMBIOS.md` y `DECISIONES.md`.
  - Se añadió en `AGENTS.md` la regla 20 para usar estos archivos.
- Por qué: llevar el control de lo que falta, lo cambiado y lo pendiente sin releer todo el código.
- Hallazgos: los errores P-001 a P-004 y las funcionalidades faltantes están en `ESTADO.md`.
- Archivos: `docs/contexto/*`, `AGENTS.md`.
- Verificación: solo documentación; no se ejecutaron pruebas.
- Commit: pendiente.

## 2026-11-09: modo oscuro, perfil e identidad visual (fbe9fc4)

- Modo oscuro con preferencia de tema: sistema, claro u oscuro.
- Perfil con nombre, apellido y foto. Las preferencias se guardan en SQLite (esquema v7).
- Aviso para agregar el nombre del emisor al exportar una proforma.
- Ícono y pantalla de inicio de Coti.
- Diseño de PDF compartido entre proforma y cierre (`diseno_documento_pdf.dart`).
- `coti_header` reemplaza a `obrapro_header`.

## 2026-11-09: ajustes generales de pantallas (649669a)

- Asistente de cotización en 4 pasos, con progreso y resumen final.
- Mano de obra propia separada y margen fijo del 20 % (esquema v6).
- Búsqueda, filtros y orden en cotizaciones, gastos, materiales y documentos.
- La pestaña "Proforma" pasa a llamarse "Documentos", con proformas y reportes de cierre.
- Reporte de cierre en PDF.
- Fecha y hora en los gastos; las obras finalizadas ya no muestran "Editar".
- Corrección del diálogo de gastos previstos.
- Consultas alternativas en inglés para Wikimedia.

## 2026-11-08: mejoras de cotizaciones (58bb5c2)

- Fechas reales de obra: iniciar, finalizar y alerta de retraso (esquema v2).
- Gastos previstos separados de los registrados, precio sugerido, desglose de proforma y categorías compartidas (v3).
- Selector de unidades de medida con búsqueda.
- Imágenes de materiales desde galería o cámara (v4) y desde Wikimedia Commons con licencias (v5).
- Se eliminó la carpeta `PROTOTIPO`.

## 2026-11-05: versión inicial (cef2953, 1aa4e13)

- Base Flutter con SQLite (esquema v1): proyectos, materiales, partidas y gastos.
- Cálculo de rentabilidad, proforma PDF y navegación adaptable.
- 42 pruebas aprobadas en esa versión, según `VERIFICACION.md`.
