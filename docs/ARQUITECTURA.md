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
    unidades_medida.dart
  datos/
    almacen_imagenes_materiales.dart
    esquema_sqlite.dart
    mapeadores_sqlite.dart
    validaciones_datos.dart
    repositorio_sqlite.dart
  aplicacion/
    cotizo_cubit.dart
    edicion_material.dart
  funcionalidades/
    cotizaciones/
      componentes/
      cotizaciones_pagina.dart
      editor_proyecto_pagina.dart
      detalle_proyecto_pagina.dart
      formulario_partida.dart
    materiales/
      componentes/
      servicios/
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
| Proyecto | id, nombreCliente, descripcion, fechaInicio, fechaFin?, fechaInicioReal?, fechaFinReal?, margenDeseadoPuntos?, estado, totalCotizadoCentavos, cobroManoObraCentavos | Tiene partidas, gastos previstos y registrados; conserva planificación, ejecución y el cobro de mano de obra propia |
| MaterialObra | id, nombre, unidadMedida, costoBaseCentavos, imagenRuta?, atribucionImagen? | Referenciado por partidas; imagen y licencia quedan en almacenamiento local y SQLite |
| ItemProyecto | id, proyectoId, materialId, cantidad, costoUnitarioAplicadoCentavos, subtotalCentavos | Une proyecto y material |
| Gasto | id, proyectoId?, montoCentavos, categoria, fecha y hora, nota | Guarda fecha y hora local; proyecto opcional y null representa gasto general |
| GastoPrevisto | id, proyectoId, categoria, montoCentavos, descripcion | Pertenece a una cotización; no representa un desembolso |

`ItemProyecto` añade `nombreMaterial` y `unidadMedida` como instantáneas históricas. Editar el catálogo no modifica las propuestas guardadas. `subtotalCentavos` se calcula a partir de cantidad y costo aplicado; el mapeador persiste el resultado, sin aceptar un subtotal independiente del cálculo.

El selector reutilizable de `MaterialFormulario` ofrece unidades agrupadas y búsqueda por nombre, símbolo y equivalencias como `m2`/`m²` y `galon`/`galón`. Admite unidades personalizadas, conserva las unidades históricas y no realiza conversiones.

Los montos se almacenan como enteros en centavos. Por ejemplo, USD 12,35 se representa como `1235`. La interfaz acepta coma o punto decimal, hasta dos decimales monetarios y tres para cantidades, sin separadores de miles. Las fechas se persisten como milisegundos y se presentan en español. Las cotizaciones nuevas exigen inicio y fin previstos; los registros antiguos sin `fechaFin` se conservan y pueden seguir editándose, pero deben completar la fecha final antes de iniciar la obra.

Una cotización se convierte en obra al registrar `fechaInicioReal`; esta operación también la marca como aprobada. `fechaFinReal` cierra la ejecución sin sustituir las fechas previstas. “En curso” y “Retrasada” son fases derivadas, por lo que no añaden estados redundantes al esquema. Los proyectos finalizados antes de esta migración permanecen como obras históricas con fechas reales desconocidas.

El SQL ejecutable está en `lib/datos/esquema_sqlite.dart`:

- `proyectos`: estado restringido a los cuatro valores, fechas coherentes e importe no negativo.
- `materiales`: nombre, unidad, costo base, referencia de imagen y atribución/licencia opcionales.
- `items_proyecto`: claves foráneas, cantidad positiva, costo aplicado, subtotal e instantáneas.
- `gastos`: monto positivo y relación opcional con proyecto.
- `gastos_previstos`: presupuesto separado de los gastos registrados.
- Índices en las relaciones y fecha de gastos.

`PRAGMA foreign_keys = ON` se activa en cada apertura. Guardar proyecto, partidas y gastos previstos es una transacción. Omitir la lista de gastos previstos al actualizar conserva el presupuesto existente; pasar una lista la sustituye. Eliminar un proyecto borra sus partidas y gastos asociados después de la confirmación en la interfaz. Los materiales del catálogo permanecen. Un material utilizado no se puede eliminar; sí se puede editar. No se usa `INSERT OR REPLACE`, para evitar borrados en cascada al editar.

`lib/dominio/repositorio_local.dart` expone lectura, guardado, eliminación e inicio/finalización de obras. Estas dos transiciones actualizan solamente la cabecera y preservan partidas y gastos. `RepositorioSqlite.abrir()` selecciona SQLite nativo en Android; admite ruta y fábrica inyectables para pruebas. El archivo local se llama `cotizo.sqlite`, con versión de esquema 6 y migraciones desde las versiones anteriores.

Las fotos del catálogo se seleccionan desde galería, cámara o Wikimedia Commons; se decodifican y optimizan en un isolate con orientación normalizada, sin metadatos, hasta 1280 píxeles por lado y 300 KB. Se guardan como JPEG en `Application Support/imagenes_materiales`; SQLite conserva el nombre relativo y, cuando corresponde, la atribución. Al reemplazar una imagen, la anterior se mantiene hasta confirmar el guardado del material. Cancelar el formulario no crea archivos persistentes.

La búsqueda web consulta la API de Wikimedia Commons, pide resultados del espacio de archivos y lee URL, licencia y atribución mediante `imageinfo`. Solo muestra dominio público, CC0, CC BY y CC BY-SA; descarta licencias no comerciales o sin obras derivadas. Las URL de miniaturas/descargas deben ser HTTPS de `upload.wikimedia.org`; las solicitudes usan un agente identificable, limitan las conexiones concurrentes por servidor, el tamaño y el tiempo, y las imágenes seleccionadas pasan por el mismo optimizador y almacenamiento offline. Para consultas conocidas en español, se intenta un término equivalente en inglés cuando la consulta original no devuelve imágenes compatibles. El título, autor, fuente y licencia permanecen en SQLite y aparecen al ampliar la imagen.

## 3. Rentabilidad

Implementación: `lib/dominio/calcular_rentabilidad.dart`.

```dart
final rentabilidadCentavos = calcularRentabilidad(
  proyecto,
  datos.items,
  datos.gastos,
);
```

La función aplica exactamente a los costos registrados:

```text
rentabilidad = total cotizado
             - suma de subtotales de las partidas del proyecto
             - suma de gastos asociados al proyecto
```

Filtra por `proyectoId`, excluye gastos generales y registros de otros proyectos, y permite resultados negativos. Los gastos previstos permanecen fuera de este cálculo y de los desembolsos registrados. El editor calcula `costo previsto = materiales + gastos previstos`. El precio sugerido aplica un margen del 20 % sobre esos costos y suma aparte el cobro de mano de obra propia. El usuario puede aplicar la sugerencia y seguir editando el precio. El resumen separa ese cobro del margen restante y de la ganancia prevista total. No hay impuestos ni gastos inferidos.

El resumen general usa solo obras iniciadas o finalizadas. Después de sumar su rentabilidad descuenta gastos generales una sola vez. Las cotizaciones aprobadas que todavía no iniciaron no inflan ese balance.

## 4. Generación de PDF

Implementación completa: `lib/funcionalidades/proformas/servicio_pdf.dart`.

```dart
final servicio = ServicioPdf();
final bytes = await servicio.generar(proyecto, items);
final archivo = await servicio.guardarEn(directorio, proyecto, items);
```

`generar` devuelve `Future<Uint8List>` con el documento listo para compartir. `guardarEn` devuelve `Future<File>` en un directorio elegido por el llamador. La pantalla utiliza `Printing.sharePdf` y `Printing.layoutPdf`.

La proforma incluye identificador, cliente, descripción, fechas, estado, cantidades, unidades, valores aplicados, cada gasto previsto y el total cotizado. El ajuste comercial se calcula como total elegido menos materiales y gastos previstos, y puede ser positivo o negativo. En obras finalizadas, el detalle permite abrir un reporte de cierre separado que repite el desglose cotizado, detalla los gastos adicionales registrados con fecha y hora, y calcula el resultado restándolos del ajuste comercial. El formulario de gastos indica registrar solo costos adicionales; así no se descuentan de nuevo materiales o gastos ya incluidos en la proforma.

El documento admite varias páginas y usa fuentes Roboto incluidas en `assets/fuentes/`, con su licencia original. No utiliza fuentes de Google descargadas durante la ejecución. La propuesta indica que no es una factura.

La pestaña de navegación se llama «Documentos» y muestra un archivo con pestañas para proformas y cierres. Busca por cliente, descripción o código; filtra por estado y rango de fechas; y permite ordenar por código reciente, cliente, fecha o importe. En proformas, las fechas usan el inicio previsto; en cierres, la fecha de finalización real. El orden reciente usa el ID descendente, que refleja el orden de inserción mientras el modelo no almacene fecha de creación.

## Estado, rendimiento y extensión

La aplicación carga SQLite al abrir y conserva una instantánea de datos en Cubit. Cambiar de pestaña no consulta la red. Cada mutación confirma SQLite y actualiza la instantánea; los formularios bloquean envíos repetidos. Los fallos de lectura tienen reintento y no se presentan como una base vacía.

La carga local y la apertura del archivo requieren tiempo de ejecución; no se promete latencia literalmente cero. Para volúmenes muy grandes, el siguiente paso es paginar consultas por funcionalidad e introducir suscripciones selectivas. El MVP evita esa complejidad manteniendo límites claros entre repositorio, dominio y UI.

Las fuentes de referencia de los paquetes y la API son sus documentaciones oficiales: [SQLite](https://pub.dev/packages/sqflite), [BLoC](https://pub.dev/packages/flutter_bloc), [image](https://pub.dev/packages/image), [image_picker](https://pub.dev/packages/image_picker), [path_provider](https://pub.dev/packages/path_provider), [búsqueda MediaWiki](https://www.mediawiki.org/wiki/API:Search), [información de imágenes](https://www.mediawiki.org/wiki/API:Imageinfo), [pdf](https://pub.dev/packages/pdf) y [printing](https://pub.dev/packages/printing).
