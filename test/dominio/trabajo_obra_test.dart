import 'package:coti/dominio/calcular_cobros_proyecto.dart';
import 'package:coti/dominio/calcular_consumos_obra.dart';
import 'package:coti/dominio/calcular_desglose_proforma.dart';
import 'package:coti/dominio/calcular_rentabilidad.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

final _proyecto = Proyecto(
  id: 1,
  nombreCliente: 'Cliente',
  descripcion: 'Obra',
  fechaInicio: DateTime(2026, 11, 1),
  totalCotizadoCentavos: 20000,
  ivaPuntos: 1500,
);

const _cable = ItemProyecto(
  proyectoId: 1,
  materialId: 7,
  cantidad: 10,
  costoUnitarioAplicadoCentavos: 500,
  nombreMaterial: 'Cable',
  unidadMedida: 'm',
);

Gasto _consumo(double cantidad, int costo) => Gasto(
  proyectoId: 1,
  montoCentavos: calcularSubtotal(cantidad, costo),
  categoria: Gasto.categoriaConsumo,
  fecha: DateTime(2026, 11, 3),
  materialId: 7,
  cantidad: cantidad,
  costoUnitarioCentavos: costo,
  nombreMaterial: 'Cable',
);

final _adicional = Adicional(
  proyectoId: 1,
  descripcion: 'Tomacorriente extra',
  montoCentavos: 4000,
  fecha: DateTime(2026, 11, 4),
);

void main() {
  test('sin consumos, la rentabilidad usa el material cotizado', () {
    expect(calcularRentabilidad(_proyecto, [_cable], []), 15000);
  });

  test('con consumos, el material real reemplaza al cotizado', () {
    final consumos = [_consumo(12, 550)];
    // 20000 - 6600 de consumo real; el cotizado (5000) ya no se descuenta.
    expect(calcularRentabilidad(_proyecto, [_cable], consumos), 13400);
    final comparativo = calcularComparativoMateriales(1, [_cable], consumos);
    expect(comparativo.single.cantidadCotizada, 10);
    expect(comparativo.single.cantidadConsumida, 12);
    expect(comparativo.single.diferenciaCentavos, 1600);
  });

  test('los adicionales suman a la rentabilidad, al cobro y al cierre', () {
    expect(
      calcularRentabilidad(_proyecto, [_cable], [], adicionales: [_adicional]),
      19000,
    );
    final cobros = calcularCobrosProyecto(
      _proyecto,
      const [],
      adicionales: [_adicional],
    );
    // 20000 + 15 % = 23000; 4000 + 15 % = 4600.
    expect(cobros.totalCentavos, 27600);
    final desglose = calcularDesgloseProforma(_proyecto, [_cable], const []);
    expect(
      calcularResultadoCierre(desglose, [
        _consumo(12, 550),
      ], adicionalesCobradosCentavos: 4000),
      20000 + 4000 - 6600,
    );
  });

  test('una devolución reduce lo cobrado y no es costo de la obra', () {
    final devolucion = Gasto(
      proyectoId: 1,
      montoCentavos: 3000,
      categoria: Gasto.categoriaDevolucion,
      fecha: DateTime(2026, 11, 5),
      nota: 'Obra cancelada',
    );
    final cobros = calcularCobrosProyecto(
      _proyecto,
      [
        Ingreso(
          proyectoId: 1,
          montoCentavos: 10000,
          categoria: 'Anticipo',
          fecha: DateTime(2026, 11, 2),
        ),
      ],
      gastos: [devolucion],
    );
    expect(cobros.cobradoCentavos, 7000);
    expect(calcularRentabilidad(_proyecto, [_cable], [devolucion]), 15000);
  });
}
