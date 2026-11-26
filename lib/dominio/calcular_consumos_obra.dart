import 'modelos.dart';

// Material cotizado frente al consumido en la obra (P-030).
class ComparativoMaterial {
  const ComparativoMaterial({
    required this.nombre,
    required this.unidad,
    required this.cantidadCotizada,
    required this.costoCotizadoCentavos,
    required this.cantidadConsumida,
    required this.costoConsumidoCentavos,
  });

  final String nombre;
  final String unidad;
  final double cantidadCotizada;
  final int costoCotizadoCentavos;
  final double cantidadConsumida;
  final int costoConsumidoCentavos;

  // Positivo si se gastó más de lo cotizado.
  int get diferenciaCentavos => costoConsumidoCentavos - costoCotizadoCentavos;
}

// Agrupa por material del catálogo, o por nombre si el material ya no existe.
List<ComparativoMaterial> calcularComparativoMateriales(
  int proyectoId,
  List<ItemProyecto> items,
  List<Gasto> gastos,
) {
  final grupos = <String, _Acumulado>{};
  String clave(int? materialId, String nombre) =>
      materialId == null ? 'n:${nombre.trim().toLowerCase()}' : 'm:$materialId';

  for (final item in items) {
    if (item.proyectoId != proyectoId || item.esServicio) continue;
    grupos.putIfAbsent(
        clave(item.materialId, item.nombreMaterial),
        () => _Acumulado(item.nombreMaterial, item.unidadMedida),
      )
      ..cantidadCotizada += item.cantidad
      ..costoCotizado += item.subtotalCentavos;
  }
  for (final gasto in gastos) {
    if (gasto.proyectoId != proyectoId || !gasto.esConsumo) continue;
    final nombre = gasto.nombreMaterial ?? gasto.categoria;
    grupos.putIfAbsent(
        clave(gasto.materialId, nombre),
        () => _Acumulado(nombre, ''),
      )
      ..cantidadConsumida += gasto.cantidad!
      ..costoConsumido += gasto.montoCentavos;
  }
  return [
    for (final grupo in grupos.values)
      ComparativoMaterial(
        nombre: grupo.nombre,
        unidad: grupo.unidad,
        cantidadCotizada: grupo.cantidadCotizada,
        costoCotizadoCentavos: grupo.costoCotizado,
        cantidadConsumida: grupo.cantidadConsumida,
        costoConsumidoCentavos: grupo.costoConsumido,
      ),
  ];
}

class _Acumulado {
  _Acumulado(this.nombre, this.unidad);

  final String nombre;
  final String unidad;
  double cantidadCotizada = 0;
  int costoCotizado = 0;
  double cantidadConsumida = 0;
  int costoConsumido = 0;
}
