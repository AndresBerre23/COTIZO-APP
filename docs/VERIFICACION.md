# Verificación de la primera versión funcional

Fecha: 5 de noviembre de 2026.

- Flutter 3.32 y Dart 3.8 en Windows.
- `flutter analyze`: sin incidencias.
- `flutter build apk --debug`: compilación final correcta.
- 35 pruebas automatizadas aprobadas en la suite completa.
- Reejecutadas 17 pruebas de estado y formularios tras unificar la validación de costos; todas aprobadas.
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
