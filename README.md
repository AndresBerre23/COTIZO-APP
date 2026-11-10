# Coti

Aplicación Flutter para cotizar trabajos, mantener un catálogo propio de materiales y registrar gastos sin conexión. Los datos se guardan en SQLite en el dispositivo. No requiere cuenta ni claves; la búsqueda opcional de imágenes consulta Wikimedia Commons cuando hay internet.

## Uso

1. En **Materiales**, registra nombre, unidad, costo de referencia e imagen opcional desde la galería, la cámara o Wikimedia Commons. La foto se optimiza y se conserva en el dispositivo; las imágenes de Commons muestran su autoría y licencia. El selector permite buscar unidades habituales o escribir otra; no convierte cantidades.
2. En **Cotizaciones**, crea un proyecto con cliente, descripción, inicio previsto y fin previsto. Añade materiales, cantidades y costos aplicados. También puedes crear materiales desde el editor.
3. Agrega gastos previstos como alimentación, pagos a trabajadores o transporte. En el paso del precio puedes agregar aparte el cobro por tu mano de obra; la sugerencia aplica un margen fijo del 20 % a los costos y suma ese cobro por separado.
4. Revisa el desglose y confirma antes de guardar. Los gastos previstos no se registran como desembolsos ni se mezclan con la rentabilidad calculada a partir de gastos reales.
5. Abre el detalle para editar la cotización o marcarla como Borrador, Enviada o Aprobada. Usa **Iniciar obra** cuando el cliente acepte el trabajo; las fechas reales se guardan sin modificar las previstas.
6. Consulta las obras en curso y finalizadas desde la vista **Obras**. Inicio muestra únicamente obras activas y avisa cuando superan el fin previsto.
7. En **Gastos**, registra desembolsos y asígnalos a un proyecto o déjalos como gastos generales.
8. Consulta la rentabilidad registrada en el detalle y exporta la propuesta desde **Proforma**.

No registres otra vez como gasto los materiales ya incluidos en las partidas: se descontarían dos veces. El catálogo conserva precios de referencia; esta versión no descuenta existencias físicas de un almacén.

## Arquitectura y archivos

La entrega técnica está en [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md), en el orden: estructura, entidades y SQL, rentabilidad, servicio PDF.

- `lib/dominio`: entidades y reglas independientes de Flutter y SQLite.
- `lib/datos`: esquema, mapeadores, validaciones y repositorio SQLite.
- `lib/aplicacion`: BLoC/Cubit, carga inicial y actualización del estado.
- `lib/funcionalidades`: pantallas y componentes separados por responsabilidad.
- `lib/screens`: puntos de entrada compatibles con el prototipo.
- `lib/core` y `lib/widgets`: formato, tema y componentes compartidos.

## Desarrollo

Validado con Flutter 3.32 / Dart 3.8. El proyecto nativo disponible es Android. Los widgets se adaptan también a tablet, portátil y escritorio; SQLite incluye soporte FFI para pruebas y futuros ejecutables de escritorio. No hay ejecutable web ni proyecto iOS configurado.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

La primera instalación de dependencias necesita conexión. El uso de la aplicación, la base de datos y la generación del PDF no la necesitan. Android usa NDK 27.0.12077973. La firma de producción y el identificador definitivo deben configurarse antes de publicar.

`pubspec.lock` se conserva para repetir las versiones resueltas. `.env` y variantes privadas están excluidos de Git; no existen secretos necesarios para esta versión.

## Verificación

Resultados y límites de la revisión: [docs/VERIFICACION.md](docs/VERIFICACION.md).

Las pruebas cubren rentabilidad, cantidades fraccionarias, importes, persistencia tras reapertura, claves foráneas, transacciones, precios históricos, edición y eliminación, formularios, navegación adaptable y generación multipágina de PDF.

Los archivos de captura y los binarios generados quedan en `build/`, excluido de Git. Para generar capturas durante las pruebas de presentación en PowerShell:

```powershell
$env:CAPTURAR_UI = '1'
flutter test test/presentacion/aplicacion_responsive_test.dart
Remove-Item Env:CAPTURAR_UI
```

## Alcance local

El balance de inicio usa proyectos aprobados o finalizados, resta sus materiales y gastos, y después resta los gastos generales. No representa flujo de caja ni cobros confirmados. La rentabilidad individual incluye únicamente gastos de ese proyecto.

Los datos permanecen tras cerrar y volver a abrir la aplicación. Desinstalarla o borrar sus datos puede eliminar SQLite. El PDF es una propuesta comercial, no una copia restaurable de la base. Sincronización, respaldos, impuestos y control de existencias quedan fuera de esta primera versión.
