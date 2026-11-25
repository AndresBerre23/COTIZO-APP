import 'calcular_rentabilidad.dart';
import 'modelos.dart';

// Resumen del balance estimado de los proyectos que admiten gastos.
class BalanceObras {
  const BalanceObras({
    required this.totalCotizadoCentavos,
    required this.costosCentavos,
    required this.generalesCentavos,
  });

  final int totalCotizadoCentavos;
  final int costosCentavos;
  final int generalesCentavos;

  int get resultadoCentavos =>
      totalCotizadoCentavos - costosCentavos - generalesCentavos;
}

// Todo gasto cuenta: si su proyecto no admite gastos, pasa a generales.
BalanceObras calcularBalanceObras(DatosLocales datos) {
  final proyectos = datos.proyectos.where((p) => p.admiteGastos).toList();
  final ids = {for (final proyecto in proyectos) proyecto.id};
  final cotizado = proyectos.fold<int>(
    0,
    (total, proyecto) => total + proyecto.totalCotizadoCentavos,
  );
  final margen = proyectos.fold<int>(
    0,
    (total, proyecto) =>
        total + calcularRentabilidad(proyecto, datos.items, datos.gastos),
  );
  final generales = datos.gastos
      .where((gasto) => !ids.contains(gasto.proyectoId))
      .fold<int>(0, (total, gasto) => total + gasto.montoCentavos);
  return BalanceObras(
    totalCotizadoCentavos: cotizado,
    costosCentavos: cotizado - margen,
    generalesCentavos: generales,
  );
}
