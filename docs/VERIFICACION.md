# Verificación de la primera versión funcional

## Fase 5: publicación y orden del código (25 de noviembre de 2026)

- `flutter analyze` sin errores ni advertencias; `flutter test` 101 de 101.
- `flutter build apk --release` (29,7 MB) y `--debug` correctos; el manifiesto combinado usa el paquete `ec.coti.app`.
- Sin `android/key.properties`, el release se firma con la clave de depuración: sirve para pruebas, no para Google Play.

## Fase 3: trabajo durante la obra (25 de noviembre de 2026)

- `flutter analyze` sin errores ni advertencias; `flutter test` 101 de 101; `flutter build apk --debug` correcto.
- Migración a v11 cubierta por la prueba desde la versión 1.
- Versiones: no se crean en borradores ni al cambiar solo el estado; se crea una al editar el total o las partidas de una proforma enviada.
- PDF de la orden de cambio y secciones de obra revisados en móvil.

## Fase 2: proforma profesional (25 de noviembre de 2026)

- `flutter analyze` sin errores ni advertencias; `flutter test` 92 de 92; `flutter build apk --debug` correcto.
- La migración a v10 recrea `proyectos` e `items_proyecto` con las claves foráneas desactivadas (D-019); la prueba desde v1 conserva proyectos, partidas y gastos.
- Proforma PDF de muestra revisada: emisor y cliente con sus datos, servicio, IVA del 15 %, validez y condiciones, en una sola página.
- Elegir el logo con la galería queda pendiente de prueba en el teléfono (P-006).

## Fase 1: ingresos y cobros (25 de noviembre de 2026)

- `flutter analyze` sin errores ni advertencias; `flutter test` 81 de 81; `flutter build apk --debug` correcto.
- Migración a la versión 9 (tabla `ingresos`) cubierta por la prueba de migración desde la versión 1.
- Movimientos y reporte mensual sin desbordes a 360, 800 y 1440 px; capturas revisadas con fuente real.
- Compartir el PDF del reporte queda pendiente de prueba en el teléfono (P-006).

## Verificación del 25 de noviembre de 2026 (P-005)

- `flutter analyze`: sin errores ni advertencias; quedan 79 sugerencias de estilo (`prefer_const_constructors` y similares).
- `flutter test`: 74 pruebas aprobadas, ninguna fallida.
- `flutter build apk --debug`: compilación correcta, con `archive`, `file_picker` y `share_plus`.
- Pruebas puestas al día:
  - Las pantallas se montan con `PreferenciasCubit` (`test/apoyo/con_cubits.dart`), como en la app.
  - Los ayudantes esperan a que termine el desplazamiento antes de pulsar.
  - Las pruebas del editor recorren el asistente de 4 pasos y confirman el resumen final.
  - El margen sugerido esperado es 20 %, el valor vigente desde 649669a.
- Errores reales corregidos durante la verificación:
  - La barra inferior del asistente desbordaba 1,7 px a 360 px; los botones ahora se encogen.
  - `optimizarImagen` lanzaba `RangeError` con datos que no son imagen; ahora devuelve el aviso esperado.
  - El formulario de gastos repetía la validación del monto; ahora usa `validarImporte`.
- Sin teléfono ni emulador: compartir, imprimir, elegir archivos, cámara y galería siguen pendientes de prueba en dispositivo (P-006).


Última actualización: 9 de noviembre de 2026.

- Flutter 3.32 y Dart 3.8 en Windows.
- `flutter analyze`: sin incidencias.
- `flutter build apk --debug`: compilación final correcta.
- 42 pruebas automatizadas aprobadas en la suite completa.
- Ciclo de obras verificado: inicio, finalización anticipada, fechas reales, alertas de retraso y separación entre cotizaciones y obras.
- Migración SQLite de versión 1 a 2 verificada sin pérdida de proyectos, partidas ni gastos.
- Rentabilidad con ganancias y pérdidas, gastos generales aislados y redondeo exacto a centavos.
- SQLite: persistencia tras reapertura, transacciones revertidas ante fallos, claves foráneas y eliminación en cascada.
- Edición del catálogo sin alterar costos históricos de cotizaciones.
- Formularios de materiales, gastos y cotizaciones con validación y protección de cambios.
- Adaptación a 360, 800, 1280 y 1440 píxeles; formularios con teclado abierto y texto ampliado.
- Capturas revisadas de las cinco pestañas en móvil y del inicio en escritorio.
- PDF de una y varias páginas generado sin conexión; proforma de muestra renderizada y revisada visualmente.
- Fuentes del PDF incluidas localmente con su licencia original.
- Ningún commit ni push realizado.

Las pruebas usan datos de muestra aislados; la aplicación instalada empieza sin registros ficticios. Las capturas y la proforma de prueba están en `build/verificacion/` y no forman parte del repositorio.

No había teléfono ni emulador Android conectado. La integración nativa se comprueba mediante compilación del APK; compartir con otra aplicación e imprimir en una impresora real deben comprobarse en el dispositivo de destino.

Los resultados históricos de 42 pruebas y de compilación del APK corresponden a la base anterior a las entregas 2 a 5; no validan por sí solos la versión actual.

## Entregas 2 y 3 implementadas

Se incorporaron gastos previstos separados de los registrados, sugerencia de precio, desglose de proforma y categorías compartidas. Se añadió el selector buscable de unidades, con equivalencias de escritura y unidades personalizadas. Hay pruebas de reglas, persistencia, presentación y generación de PDF, pero aún no se ejecutaron después de estos cambios. `dart analyze lib test` terminó sin incidencias. La prueba en teléfono Android también está pendiente.

## Entrega 4: imágenes locales de materiales

El formulario permite elegir una foto de galería o tomarla con la cámara, previsualizarla, ampliarla, cambiarla y quitarla. Se optimiza fuera del hilo de interfaz, normaliza orientación y limita el JPEG a 1280 píxeles por lado y 300 KB. El archivo queda en almacenamiento privado y SQLite guarda su referencia relativa. La selección de imágenes se ofrece tanto desde el catálogo como al crear un material desde una cotización. La migración de esquema es la versión 4.

La verificación automatizada y visual de esta entrega sigue pendiente. Falta probar en un teléfono la galería, cámara, guardado, edición, eliminación, cancelación del formulario y recuperación de selección tras recrear la actividad Android.

## Entrega 5: búsqueda Wikimedia Commons

Se añadió una pantalla de búsqueda paginada con consulta editable, previsualización y selección. Solo se aceptan licencias identificadas como dominio público, CC0, CC BY o CC BY-SA; se excluyen licencias no comerciales o sin obras derivadas. Los datos de título, autor, fuente y licencia se conservan en la migración SQLite v5 y aparecen al ampliar la imagen. Las descargas se restringen a HTTPS en Wikimedia, con límites de 8 MB y tiempo de solicitud; la imagen elegida vuelve al mismo optimizador y almacenamiento offline de las fotos locales. Android declara el permiso de internet requerido.

Tras las pruebas de uso se añadió un agente identificable con enlace al proyecto, un máximo de tres conexiones por servidor y reintento de miniaturas fallidas. La búsqueda "correas de hierro" conserva el intento original y, si no encuentra imágenes compatibles, prueba "iron strap hinge" y "strap hinge". Se agregó una prueba para estas equivalencias.

El análisis estático completo (`dart analyze lib test`) terminó sin incidencias en la revisión del 8 de noviembre de 2026. La suite de pruebas, la compilación Android y la prueba manual de consultas, paginación, licencias, descarga y uso sin conexión en un teléfono siguen pendientes; el intento más reciente está documentado en la sección siguiente.

## Revisión del arreglo de búsqueda Wikimedia

El 8 de noviembre de 2026 se volvió a ejecutar `dart analyze lib test`: terminó sin incidencias. `dart format --output=none --set-exit-if-changed lib test` confirmó que los 91 archivos Dart ya están formateados, y `git diff --check` no encontró errores de espacios.

La suite actual y una nueva compilación del APK siguen pendientes. Una copia temporal del SDK permitió iniciar `flutter test --no-pub`, pero el ejecutor no pudo abrir el socket local `127.0.0.1` que usa para comunicarse con las pruebas. Además, Flutter intentó consultar avisos de paquetes en `pub.dev` y el entorno bloqueó la resolución DNS. Los primeros archivos de prueba no llegaron a cargar; los resultados históricos anteriores no sustituyen estas verificaciones.

La función pura de equivalencias sí se ejecutó directamente con Dart: «Correas de hierro» produce las dos consultas inglesas previstas, se normalizan espacios y «mdf» no recibe una equivalencia incorrecta. Esta comprobación no valida la respuesta real de Wikimedia ni sustituye la suite Flutter.

El APK existente se generó a las 19:02 del 8 de noviembre; los cambios actuales de Wikimedia son posteriores, entre las 19:09 y las 19:13, por lo que ese APK no contiene el arreglo. Tampoco se pudo enumerar un dispositivo: `adb devices` no logró iniciar el servidor local de ADB en este entorno.

Falta probar en el teléfono la carga de miniaturas y la búsqueda de «mdf» y «Correas de hierro», además de cámara y galería, persistencia sin conexión, paginación, licencias y manejo de errores de Wikimedia.

## Corrección del diálogo de gastos previstos

El 9 de noviembre de 2026 se corrigió el ciclo de vida de los controladores del diálogo. Ahora pertenecen al estado del propio diálogo y se liberan cuando Flutter lo desmonta, después de la animación de cierre. Se agregó una prueba de interfaz que agrega un gasto de transporte y comprueba el cierre sin excepciones. El análisis estático de los archivos modificados terminó sin incidencias; la prueba de interfaz aún requiere ejecutarse en un entorno donde Flutter pueda abrir su socket local.

## Mano de obra propia y margen de cotización

La mano de obra propia se registra como un cobro opcional en el paso de precio, separado de los pagos previstos a trabajadores. El margen fijo subió al 20 % y se calcula sobre materiales y otros costos previstos; el cobro de mano de obra se suma aparte. El precio sugerido aparece destacado con su desglose y el campo final indica el total que cobrará el usuario. El resumen confirma los datos antes de guardar. El monto se conserva en SQLite mediante la migración de esquema 6 y se muestra en proformas y reportes de cierre. El análisis estático pasó; la suite Flutter y la revisión en teléfono siguen pendientes.

## Obras finalizadas como registro

El detalle de una obra finalizada ya no muestra la acción «Editar» y conserva «Ver proforma». Se añadió una comprobación al flujo de prueba que finaliza una obra y verifica ambas condiciones. El análisis estático del detalle y sus pruebas pasó; la prueba widget aún no se ejecutó por la restricción del socket local.

## Fecha y hora de gastos registrados

El formulario conserva la hora actual al abrirse, permite ajustar fecha y hora por separado y muestra ambas en el historial. SQLite ya guardaba el valor `DateTime` en milisegundos, por lo que el cambio no requiere migración. La prueba de gastos verifica que el registro conserve su marca temporal; el análisis estático se ejecuta en esta revisión.

## Reporte PDF de cierre

Las obras finalizadas muestran «Reporte de cierre» junto a «Ver proforma». El nuevo PDF conserva el desglose cotizado, lista los gastos adicionales con fecha y hora y muestra el resultado luego de restarlos del ajuste comercial. La proforma original permanece sin cambios. La compilación y prueba manual siguen pendientes.

## Archivo de documentos

La pestaña «Proforma» del menú se renombró «Documentos». El archivo permite buscar por cliente, descripción o código, filtrar por estado y rango de fechas, ordenar resultados y cambiar entre proformas y reportes de cierre. El análisis estático de los archivos de navegación y documentos terminó sin incidencias; la prueba visual en móvil, tableta y escritorio queda pendiente.

## Cotizaciones y obras

La acción «Nueva cotización» queda flotante en móvil y alineada al encabezado en pantallas amplias; el estado vacío conserva su acción principal. La lista permite buscar por cliente, proyecto o código, filtrar por estado, período de inicio y tipo de obra, y ordenar resultados. Las tarjetas agrupan cliente, estado, total, fecha y acceso al detalle. El análisis estático terminó sin errores; falta la revisión visual en móvil, tableta y escritorio.

## Gastos

La acción «Registrar gasto» queda flotante en móvil y alineada al encabezado en pantallas amplias; el estado vacío conserva el registro inicial. La lista permite buscar por categoría, nota, proyecto o código, filtrar por tipo de asignación, categoría y período, y ordenar por fecha o importe. El total visible se recalcula con los filtros activos. El análisis estático terminó sin errores; la revisión visual en móvil, tableta y escritorio queda pendiente.

## Materiales

La acción «Nuevo material» queda flotante en móvil y alineada al encabezado en pantallas amplias; el estado vacío mantiene una acción para agregar el primer material. El catálogo permite buscar por nombre o unidad, filtrar por materiales con imagen y por unidad de medida, y ordenar por incorporación aproximada (ID descendente), nombre, unidad o costo. El análisis estático terminó sin errores; falta la revisión visual en móvil, tableta y escritorio.

## Asistente de nueva cotización

El formulario se dividió en cuatro pasos con progreso visible: cliente y fechas, materiales, gastos previstos y precio con revisión. Cliente, descripción, fechas válidas y precio se validan antes de avanzar o guardar; materiales y gastos previstos son opcionales y pueden omitirse. Los datos permanecen en el editor al retroceder. Se conserva la confirmación para descartar cambios y el resumen final se adapta a pantallas estrechas. Falta probar el flujo en teléfono y revisar su presentación en móvil, tableta y escritorio.
