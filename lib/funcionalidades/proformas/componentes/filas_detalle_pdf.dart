import '../../../core/formato.dart';
import '../../../dominio/calcular_partidas_cliente.dart';
import '../../../dominio/modelos.dart';

// Filas del detalle para el cliente: precios finales, sin costos ni margen.
List<List<String>> filasCliente(
  Proyecto proyecto,
  List<ItemProyecto> items,
  List<GastoPrevisto> gastosPrevistos,
) => [
  for (final linea in calcularPartidasCliente(proyecto, items, gastosPrevistos))
    [
      linea.descripcion,
      cantidadCorta(linea.cantidad),
      linea.unidad,
      dinero(linea.unitarioCentavos),
      dinero(linea.subtotalCentavos),
    ],
];

// Filas del reporte de cierre, con el costo real de cada material.
List<List<String>> filasCostoInterno(List<ItemProyecto> items) => [
  for (final item in items)
    [
      item.nombreMaterial,
      cantidadCorta(item.cantidad),
      item.unidadMedida,
      dinero(item.costoUnitarioAplicadoCentavos),
      dinero(item.subtotalCentavos),
    ],
];
