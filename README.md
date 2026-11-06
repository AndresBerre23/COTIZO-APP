# ObraPro / Cotizo

Aplicación Flutter para cotizar trabajos, mantener un catálogo propio de materiales y registrar gastos sin conexión. Los datos se guardan en SQLite en el dispositivo. No requiere cuenta, API, claves ni consultas de precios por internet.

## Uso

1. En **Materiales**, registra un nombre, unidad y costo de referencia.
2. En **Cotizaciones**, crea un proyecto con cliente, descripción y fechas. Añade materiales, cantidades y costos aplicados. También puedes crear materiales desde el editor.
3. Define el **total cotizado**: el importe completo que cobrará el cliente, incluyendo trabajo y margen.
4. Abre el detalle para editar la cotización o cambiar su estado: Borrador, Enviado, Aprobado o Finalizado. El estado Enviado es manual; no envía mensajes.
5. En **Gastos**, registra transporte, mano de obra u otros desembolsos. Asígnalos a un proyecto o déjalos como gastos generales.
6. Consulta la rentabilidad en el detalle y exporta la propuesta desde **Proforma**.

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
