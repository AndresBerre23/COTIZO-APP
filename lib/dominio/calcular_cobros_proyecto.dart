import 'modelos.dart';

// Lo cobrado de un proyecto y lo que falta cobrar (P-011).
class CobrosProyecto {
  const CobrosProyecto({
    required this.totalCentavos,
    required this.cobradoCentavos,
  });

  final int totalCentavos;
  final int cobradoCentavos;

  // Negativo si se cobró más de lo cotizado.
  int get saldoCentavos => totalCentavos - cobradoCentavos;

  double get avance => totalCentavos <= 0
      ? (cobradoCentavos > 0 ? 1 : 0)
      : (cobradoCentavos / totalCentavos).clamp(0, 1).toDouble();
}

CobrosProyecto calcularCobrosProyecto(
  Proyecto proyecto,
  List<Ingreso> ingresos,
) => CobrosProyecto(
  // El cliente paga el total con IVA.
  totalCentavos: proyecto.totalConIvaCentavos,
  cobradoCentavos: ingresos
      .where((ingreso) => ingreso.proyectoId == proyecto.id)
      .fold(0, (total, ingreso) => total + ingreso.montoCentavos),
);
