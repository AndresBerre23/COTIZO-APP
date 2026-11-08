import 'calcular_precio_sugerido.dart';
import 'modelos.dart';

class PresupuestoProyecto {
  const PresupuestoProyecto({
    required this.costoMaterialesCentavos,
    required this.costoPrevistoCentavos,
    required this.precioSugeridoCentavos,
  });

  final int costoMaterialesCentavos;
  final int costoPrevistoCentavos;
  final int? precioSugeridoCentavos;
}

PresupuestoProyecto calcularPresupuestoProyecto(
  List<ItemProyecto> partidas,
  List<GastoPrevisto> gastosPrevistos,
  int? margenDeseadoPuntos,
) {
  final materiales = partidas.fold<int>(
    0,
    (total, item) => total + item.subtotalCentavos,
  );
  final costo = gastosPrevistos.fold<int>(
    materiales,
    (total, gasto) => total + gasto.montoCentavos,
  );
  return PresupuestoProyecto(
    costoMaterialesCentavos: materiales,
    costoPrevistoCentavos: costo,
    precioSugeridoCentavos: calcularPrecioSugerido(costo, margenDeseadoPuntos),
  );
}
