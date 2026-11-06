import 'modelos.dart';

int calcularRentabilidad(
  Proyecto proyecto,
  List<ItemProyecto> items,
  List<Gasto> gastos,
) {
  final costoMateriales = items
      .where((item) => item.proyectoId == proyecto.id)
      .fold<int>(0, (total, item) => total + item.subtotalCentavos);
  final costoGastos = gastos
      .where((gasto) => gasto.proyectoId == proyecto.id)
      .fold<int>(0, (total, gasto) => total + gasto.montoCentavos);
  return proyecto.totalCotizadoCentavos - costoMateriales - costoGastos;
}
