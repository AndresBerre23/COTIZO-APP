import 'modelos.dart';

// Dinero que entró y salió en un mes calendario (P-013, P-014).
class ResumenMes {
  const ResumenMes({
    required this.mes,
    required this.ingresosPorCategoria,
    required this.gastosPorCategoria,
  });

  // Primer día del mes.
  final DateTime mes;

  // Ordenados de mayor a menor importe.
  final Map<String, int> ingresosPorCategoria;
  final Map<String, int> gastosPorCategoria;

  int get ingresosCentavos =>
      ingresosPorCategoria.values.fold(0, (total, monto) => total + monto);
  int get gastosCentavos =>
      gastosPorCategoria.values.fold(0, (total, monto) => total + monto);
  int get balanceCentavos => ingresosCentavos - gastosCentavos;
  bool get vacio => ingresosPorCategoria.isEmpty && gastosPorCategoria.isEmpty;
}

ResumenMes calcularResumenMes(DatosLocales datos, DateTime fecha) {
  final inicio = DateTime(fecha.year, fecha.month);
  final fin = DateTime(fecha.year, fecha.month + 1);
  bool enMes(Movimiento m) =>
      !m.fecha.isBefore(inicio) && m.fecha.isBefore(fin);
  return ResumenMes(
    mes: inicio,
    ingresosPorCategoria: _porCategoria(datos.ingresos.where(enMes)),
    gastosPorCategoria: _porCategoria(datos.gastos.where(enMes)),
  );
}

Map<String, int> _porCategoria(Iterable<Movimiento> movimientos) {
  final totales = <String, int>{};
  for (final movimiento in movimientos) {
    totales.update(
      movimiento.categoria,
      (total) => total + movimiento.montoCentavos,
      ifAbsent: () => movimiento.montoCentavos,
    );
  }
  final orden = totales.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map.fromEntries(orden);
}
