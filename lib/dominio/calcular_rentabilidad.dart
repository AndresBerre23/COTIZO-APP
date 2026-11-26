import 'modelos.dart';

// Con consumos registrados, el material real reemplaza al cotizado (D-020).
bool tieneConsumos(int proyectoId, List<Gasto> gastos) =>
    gastos.any((gasto) => gasto.proyectoId == proyectoId && gasto.esConsumo);

// Precio sin IVA de los adicionales de un proyecto (P-031).
int totalAdicionales(int proyectoId, List<Adicional> adicionales) => adicionales
    .where((adicional) => adicional.proyectoId == proyectoId)
    .fold(0, (total, adicional) => total + adicional.montoCentavos);

int calcularRentabilidad(
  Proyecto proyecto,
  List<ItemProyecto> items,
  List<Gasto> gastos, {
  List<Adicional> adicionales = const [],
}) {
  final costoMateriales = tieneConsumos(proyecto.id, gastos)
      ? 0
      : items
            .where((item) => item.proyectoId == proyecto.id)
            .fold<int>(0, (total, item) => total + item.costoCentavos);
  // Una devolución reduce lo cobrado, no es un costo de la obra.
  final costoGastos = gastos
      .where((gasto) => gasto.proyectoId == proyecto.id && !gasto.esDevolucion)
      .fold<int>(0, (total, gasto) => total + gasto.montoCentavos);
  return proyecto.totalCotizadoCentavos +
      totalAdicionales(proyecto.id, adicionales) -
      costoMateriales -
      costoGastos;
}
