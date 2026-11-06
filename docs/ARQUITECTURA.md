# Arquitectura inicial implementada

## 1. Estructura de directorios

Organización por funcionalidad en presentación, con dominio y persistencia compartidos. Las cotizaciones y gastos necesitan consultar las mismas relaciones; el repositorio local centraliza la consistencia sin acoplar los widgets a SQL.

```text
lib/
  main.dart
  app.dart
  dominio/
    entidades/
      proyecto.dart
      material_obra.dart
      item_proyecto.dart
      gasto.dart
    modelos.dart
    datos_locales.dart
    repositorio_local.dart
    calcular_rentabilidad.dart
  datos/
    esquema_sqlite.dart
    mapeadores_sqlite.dart
    validaciones_datos.dart
    repositorio_sqlite.dart
  aplicacion/
    cotizo_cubit.dart
  funcionalidades/
    cotizaciones/
      componentes/
      cotizaciones_pagina.dart
      editor_proyecto_pagina.dart
      detalle_proyecto_pagina.dart
      formulario_partida.dart
    materiales/
    gastos/
    inicio/
    proformas/
      servicio_pdf.dart
      vista_proforma.dart
  core/
    formato.dart
    theme/app_theme.dart
  widgets/
  screens/
test/
  dominio/
  datos/
  aplicacion/
  servicios/
  presentacion/
```

Flujo de dependencias: pantalla → Cubit → interfaz RepositorioLocal → implementación SQLite. El cálculo de rentabilidad depende únicamente de entidades. PDF es un servicio de infraestructura utilizado desde presentación. Los widgets reciben modelos y delegan la persistencia.

BLoC/Cubit satisface la alternativa BLoC del stack solicitado; no se usa Riverpod ni generación de código. La elección reduce archivos generados y mantiene las reglas fuera de los widgets.

## 2. Entidades e interfaz SQL

Cada clase tiene su propio archivo, propiedades finales y constructor con parámetros nombrados. `id = 0` identifica un registro nuevo; SQLite asigna su identificador. `MaterialObra` representa la entidad Material y evita el conflicto con `Material` de Flutter.

| Entidad | Campos Dart | Relación |
| --- | --- | --- |
| Proyecto | id, nombreCliente, descripcion, fechaInicio, fechaFin?, estado, totalCotizadoCentavos | Tiene partidas y gastos |
| MaterialObra | id, nombre, unidadMedida, costoBaseCentavos | Referenciado por partidas |
| ItemProyecto | id, proyectoId, materialId, cantidad, costoUnitarioAplicadoCentavos, subtotalCentavos | Une proyecto y material |
| Gasto | id, proyectoId?, montoCentavos, categoria, fecha, nota | Proyecto opcional; null representa gasto general |

`ItemProyecto` añade `nombreMaterial` y `unidadMedida` como instantáneas históricas. Editar el catálogo no modifica las propuestas guardadas. `subtotalCentavos` se calcula a partir de cantidad y costo aplicado; el mapeador persiste el resultado, sin aceptar un subtotal independiente del cálculo.

Los montos se almacenan como enteros en centavos. Por ejemplo, USD 12,35 se representa como `1235`. La interfaz acepta coma o punto decimal, hasta dos decimales monetarios y tres para cantidades, sin separadores de miles. Las fechas se persisten como milisegundos y se presentan en español. `fechaFin` puede quedar vacía.

El SQL ejecutable está en `lib/datos/esquema_sqlite.dart`:

- `proyectos`: estado restringido a los cuatro valores, fechas coherentes e importe no negativo.
- `materiales`: nombre, unidad y costo base.
- `items_proyecto`: claves foráneas, cantidad positiva, costo aplicado, subtotal e instantáneas.
- `gastos`: monto positivo y relación opcional con proyecto.
- Índices en las relaciones y fecha de gastos.

`PRAGMA foreign_keys = ON` se activa en cada apertura. Guardar proyecto y partidas es una transacción. Eliminar un proyecto borra sus partidas y gastos asociados después de la confirmación en la interfaz. Los materiales del catálogo permanecen. Un material utilizado no se puede eliminar; sí se puede editar. No se usa `INSERT OR REPLACE`, para evitar borrados en cascada al editar.

`lib/dominio/repositorio_local.dart` expone lectura de datos, guardado y eliminación de cada entidad, además de cierre. `RepositorioSqlite.abrir()` selecciona SQLite nativo en Android; admite ruta y fábrica inyectables para pruebas. El archivo local se llama `cotizo.sqlite`, con versión de esquema 1.

## 3. Rentabilidad

Implementación: `lib/dominio/calcular_rentabilidad.dart`.

```dart
final rentabilidadCentavos = calcularRentabilidad(
  proyecto,
  datos.items,
  datos.gastos,
);
```

La función aplica exactamente:

```text
rentabilidad = total cotizado
             - suma de subtotales de las partidas del proyecto
             - suma de gastos asociados al proyecto
```

Filtra por `proyectoId`, excluye gastos generales y registros de otros proyectos, y permite resultados negativos. Los materiales representan el costo estimado aplicado; para interpretar el resultado como rentabilidad real deben registrarse los costos efectivamente incurridos, incluyendo mano de obra. No hay impuestos, cobros ni gastos inferidos.

El resumen general usa solo proyectos aprobados o finalizados. Después de sumar su rentabilidad descuenta gastos generales una sola vez. Los borradores y enviados continúan visibles como proyectos activos, pero no inflan ese balance.

## 4. Generación de PDF

Implementación completa: `lib/funcionalidades/proformas/servicio_pdf.dart`.

```dart
final servicio = ServicioPdf();
final bytes = await servicio.generar(proyecto, items);
final archivo = await servicio.guardarEn(directorio, proyecto, items);
```

`generar` devuelve `Future<Uint8List>` con el documento listo para compartir. `guardarEn` devuelve `Future<File>` en un directorio elegido por el llamador. La pantalla utiliza `Printing.sharePdf` y `Printing.layoutPdf`.

Incluye identificador, cliente, descripción, fechas, estado, cantidades, unidades, valores aplicados y total cotizado. La diferencia entre las partidas y el total manual se identifica como ajuste al total cotizado, sin inventar impuestos o servicios. Los gastos y márgenes internos no se agregan al documento.

El documento admite varias páginas y usa fuentes Roboto incluidas en `assets/fuentes/`, con su licencia original. No utiliza fuentes de Google descargadas durante la ejecución. La propuesta indica que no es una factura.

## Estado, rendimiento y extensión

La aplicación carga SQLite al abrir y conserva una instantánea de datos en Cubit. Cambiar de pestaña no consulta la red. Cada mutación confirma SQLite y actualiza la instantánea; los formularios bloquean envíos repetidos. Los fallos de lectura tienen reintento y no se presentan como una base vacía.

La carga local y la apertura del archivo requieren tiempo de ejecución; no se promete latencia literalmente cero. Para volúmenes muy grandes, el siguiente paso es paginar consultas por funcionalidad e introducir suscripciones selectivas. El MVP evita esa complejidad manteniendo límites claros entre repositorio, dominio y UI.

Las fuentes de referencia de los paquetes son sus documentaciones oficiales: [SQLite](https://pub.dev/packages/sqflite), [BLoC](https://pub.dev/packages/flutter_bloc), [pdf](https://pub.dev/packages/pdf) y [printing](https://pub.dev/packages/printing).
