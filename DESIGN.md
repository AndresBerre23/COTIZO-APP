# Sistema visual de Coti

## Intención

Herramienta para profesionales independientes que cotizan trabajos y registran pequeños gastos durante la jornada. Prioriza rapidez de captura, claridad de importes y continuidad sin conexión. Su vocabulario es cliente, proyecto, partida, material, gasto, costo aplicado y rentabilidad.

Se conserva la base del prototipo: fondo claro azulado, tarjetas blancas, azul cobalto para jerarquía, azul para acciones, verde menta para señales positivas y rojo para pérdidas o errores. Las superficies recuerdan hojas de cotización y fichas de trabajo; los totales monoespaciados permiten revisar cifras.

## Paleta

| Token existente | Color | Uso |
| --- | --- | --- |
| canvas | #F9F9FF | Fondo |
| surface | #FFFFFF | Tarjetas y formularios |
| ink | #111C2D | Texto principal |
| muted | #444651 | Texto secundario |
| outline | #C5C5D3 | Bordes |
| cobalt | #1E3A8A | Marca y cifras principales |
| blue | #316BF3 | Acciones y progreso de costos |
| mint | #6FFBBE | Señales positivas |
| softBlue | #E7EEFF | Superficies secundarias |
| error | #BA1A1A | Pérdidas y errores |

## Componentes

- Tarjetas reutilizables con radio 20, borde fino y sombra suave del prototipo.
- Formularios con borde redondeado de 12 y errores junto al campo.
- Espaciados en múltiplos de 4: 8, 12, 16, 20, 24 y 32.
- Texto principal de 16, títulos de sección de 20 y totales entre 28 y 36.
- Tipografía de sistema conservando el comportamiento del prototipo; cifras en familia monoespaciada. El prototipo declaraba Inter sin incluir una fuente y usa la alternativa del sistema.
- Estados vacíos con mensaje específico y acción contextual, sin cifras ficticias.
- Cabecera con indicador Local en lugar de GPS, notificaciones o identidad simulados.

## Composición adaptable

Navegación inferior en móvil y tablet; barra lateral desde 840 px. Ancho máximo del contenido de 1120 px. El editor usa dos columnas desde 900 px disponibles y una columna por debajo. Los importes y metadatos se distribuyen con Wrap cuando necesitan varias líneas. Formularios y diálogos permiten desplazamiento con teclado abierto.

La señal propia del producto es la relación entre total cotizado, materiales aplicados y gastos: aparece en el inicio, editor, detalle y proforma. Los indicadores describen consumo del presupuesto, sin simular avance de obra. No hay gráficos decorativos ni métricas inventadas.

Las transiciones y controles usan Material 3. Los botones muestran estados de guardado y los errores permiten reintentar. Se conservan patrones existentes para futuras pantallas.
