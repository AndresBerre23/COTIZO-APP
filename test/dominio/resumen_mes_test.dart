import 'package:cotizo_app/dominio/calcular_cobros_proyecto.dart';
import 'package:cotizo_app/dominio/calcular_resumen_mes.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

Ingreso _ingreso(
  int monto,
  DateTime fecha, {
  int? proyectoId,
  String c = 'Abono',
}) => Ingreso(
  proyectoId: proyectoId,
  montoCentavos: monto,
  categoria: c,
  fecha: fecha,
);

Gasto _gasto(int monto, DateTime fecha, String categoria) =>
    Gasto(montoCentavos: monto, categoria: categoria, fecha: fecha);

void main() {
  test('resume solo el mes pedido y agrupa por categoría', () {
    final datos = DatosLocales(
      ingresos: [
        _ingreso(5000, DateTime(2026, 11, 1), c: 'Anticipo'),
        _ingreso(2000, DateTime(2026, 11, 30, 23, 59), c: 'Abono'),
        _ingreso(9999, DateTime(2026, 12, 1)),
      ],
      gastos: [
        _gasto(1000, DateTime(2026, 11, 5), 'Otros'),
        _gasto(3000, DateTime(2026, 11, 6), 'Herramientas'),
        _gasto(500, DateTime(2026, 11, 7), 'Otros'),
        _gasto(700, DateTime(2026, 10, 31), 'Otros'),
      ],
    );
    final resumen = calcularResumenMes(datos, DateTime(2026, 11, 15));
    expect(resumen.ingresosCentavos, 7000);
    expect(resumen.gastosCentavos, 4500);
    expect(resumen.balanceCentavos, 2500);
    expect(resumen.gastosPorCategoria.keys.first, 'Herramientas');
    expect(resumen.gastosPorCategoria['Otros'], 1500);
  });

  test('calcula lo cobrado y el saldo pendiente de un proyecto', () {
    final proyecto = Proyecto(
      id: 3,
      nombreCliente: 'Cliente',
      descripcion: 'Obra',
      fechaInicio: DateTime(2026, 11, 1),
      totalCotizadoCentavos: 10000,
    );
    final cobros = calcularCobrosProyecto(proyecto, [
      _ingreso(4000, DateTime(2026, 11, 2), proyectoId: 3),
      _ingreso(1000, DateTime(2026, 11, 3), proyectoId: 3),
      _ingreso(9000, DateTime(2026, 11, 3), proyectoId: 4),
    ]);
    expect(cobros.cobradoCentavos, 5000);
    expect(cobros.saldoCentavos, 5000);
    expect(cobros.avance, 0.5);
  });
}
