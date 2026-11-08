# Verificación de la primera versión funcional

Última actualización: 8 de noviembre de 2026.

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

## Entregas 2 y 3 implementadas

Se incorporaron gastos previstos separados de los registrados, sugerencia de precio, desglose de proforma y categorías compartidas. Se añadió el selector buscable de unidades, con equivalencias de escritura y unidades personalizadas. Hay pruebas de reglas, persistencia, presentación y generación de PDF, pero aún no se ejecutaron después de estos cambios. `dart analyze lib test` terminó sin incidencias. La prueba en teléfono Android también está pendiente.

## Entrega 4: imágenes locales de materiales

El formulario permite elegir una foto de galería o tomarla con la cámara, previsualizarla, ampliarla, cambiarla y quitarla. Se optimiza fuera del hilo de interfaz, normaliza orientación y limita el JPEG a 1280 píxeles por lado y 300 KB. El archivo queda en almacenamiento privado y SQLite guarda su referencia relativa. La selección de imágenes se ofrece tanto desde el catálogo como al crear un material desde una cotización. La migración de esquema es la versión 4.

La verificación automatizada y visual de esta entrega sigue pendiente. Falta probar en un teléfono la galería, cámara, guardado, edición, eliminación, cancelación del formulario y recuperación de selección tras recrear la actividad Android.

## Entrega 5: búsqueda Wikimedia Commons

Se añadió una pantalla de búsqueda paginada con consulta editable, previsualización y selección. Solo se aceptan licencias identificadas como dominio público, CC0, CC BY o CC BY-SA; se excluyen licencias no comerciales o sin obras derivadas. Los datos de título, autor, fuente y licencia se conservan en la migración SQLite v5 y aparecen al ampliar la imagen. Las descargas se restringen a HTTPS en Wikimedia, con límites de 8 MB y tiempo de solicitud; la imagen elegida vuelve al mismo optimizador y almacenamiento offline de las fotos locales. Android declara el permiso de internet requerido.

El análisis estático (`dart analyze lib test`) terminó sin incidencias. Quedan pendientes la suite de pruebas, la compilación Android y la prueba manual de consultas, paginación, licencias, descarga y uso sin conexión en un teléfono. Flutter no pudo iniciar la compilación en esta sesión porque necesita crear un archivo de bloqueo dentro del SDK instalado en `C:\dev\flutter`, fuera de las rutas con permiso de escritura.
