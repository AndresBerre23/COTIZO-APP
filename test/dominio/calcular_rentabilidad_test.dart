import 'package:cotizo_app/dominio/calcular_rentabilidad.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final proyecto = Proyecto(
    id: 1,
    nombreCliente: 'Cliente',
    descripcion: 'Instalación',
    fechaInicio: DateTime(2026, 11, 5),
    totalCotizadoCentavos: 10000,
  );

  test('resta materiales y gastos asociados, excluyendo gastos generales', () {
    final items = [_item(1, 2.5, 1000), _item(2, 10, 5000)];
    final gastos = [_gasto(1, 1200), _gasto(null, 3000), _gasto(2, 90000)];
    expect(calcularRentabilidad(proyecto, items, gastos), 6300);
  });

  test('conserva pérdidas y permite un proyecto sin costos', () {
    expect(calcularRentabilidad(proyecto, [], []), 10000);
    expect(calcularRentabilidad(proyecto, [_item(1, 3, 5000)], []), -5000);
  });

  test('redondea cada subtotal a centavos', () {
    expect(_item(1, 0.15, 10).subtotalCentavos, 2);
    expect(_item(1, 0.29, 50).subtotalCentavos, 15);
    expect(_item(1, 0.001, 1500).subtotalCentavos, 2);
    expect(calcularRentabilidad(proyecto, [_item(1, 0.15, 10)], []), 9998);
  });
}

ItemProyecto _item(int proyectoId, double cantidad, int precio) => ItemProyecto(
  proyectoId: proyectoId,
  materialId: 1,
  cantidad: cantidad,
  costoUnitarioAplicadoCentavos: precio,
  nombreMaterial: 'Cable',
  unidadMedida: 'm',
);

Gasto _gasto(int? proyectoId, int monto) => Gasto(
  proyectoId: proyectoId,
  montoCentavos: monto,
  categoria: 'Transporte',
  fecha: DateTime(2026, 11, 5),
);
