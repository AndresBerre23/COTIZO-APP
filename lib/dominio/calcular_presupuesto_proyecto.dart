import 'calcular_precio_sugerido.dart';
import 'modelos.dart';

class PresupuestoProyecto {
  const PresupuestoProyecto({
    required this.costoMaterialesCentavos,
    required this.costoPrevistoCentavos,
    required this.precioSugeridoCentavos,
    this.precioServiciosCentavos = 0,
  });

  final int costoMaterialesCentavos;
  final int costoPrevistoCentavos;
  final int? precioSugeridoCentavos;
  final int precioServiciosCentavos;
}

PresupuestoProyecto calcularPresupuestoProyecto(
  List<ItemProyecto> partidas,
  List<GastoPrevisto> gastosPrevistos, {
  int cobroManoObraCentavos = 0,
  int margenPuntos = margenSugeridoFijoPuntos,
}) {
  final materiales = partidas.fold<int>(
    0,
    (total, item) => total + item.costoCentavos,
  );
  // Los servicios tienen precio propio y se suman como la mano de obra.
  final servicios = partidas.fold<int>(
    0,
    (total, item) => total + item.precioServicioCentavos,
  );
  final costo = gastosPrevistos.fold<int>(
    materiales,
    (total, gasto) => total + gasto.montoCentavos,
  );
  return PresupuestoProyecto(
    costoMaterialesCentavos: materiales,
    costoPrevistoCentavos: costo,
    precioServiciosCentavos: servicios,
    precioSugeridoCentavos: calcularPrecioSugerido(
      costo,
      cobroManoObraCentavos: cobroManoObraCentavos + servicios,
      margenPuntos: margenPuntos,
    ),
  );
}
