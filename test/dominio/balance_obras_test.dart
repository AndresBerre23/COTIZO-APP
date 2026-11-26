import 'package:coti/dominio/calcular_balance_obras.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

Proyecto _proyecto(int id, EstadoProyecto estado) => Proyecto(
  id: id,
  nombreCliente: 'Cliente $id',
  descripcion: 'Trabajo',
  fechaInicio: DateTime(2026, 11, 25),
  estado: estado,
  totalCotizadoCentavos: 10000,
);

Gasto _gasto(int? proyectoId, int monto) => Gasto(
  proyectoId: proyectoId,
  montoCentavos: monto,
  categoria: 'Otros',
  fecha: DateTime(2026, 11, 25),
);

void main() {
  test('todo gasto registrado cuenta en el balance', () {
    final balance = calcularBalanceObras(
      DatosLocales(
        proyectos: [
          _proyecto(1, EstadoProyecto.aprobado),
          _proyecto(2, EstadoProyecto.borrador),
        ],
        gastos: [_gasto(1, 1000), _gasto(2, 300), _gasto(null, 200)],
      ),
    );
    expect(balance.totalCotizadoCentavos, 10000);
    expect(balance.costosCentavos, 1000);
    // El gasto del borrador se suma a los generales.
    expect(balance.generalesCentavos, 500);
    expect(balance.resultadoCentavos, 8500);
  });

  test('solo aprobadas y obras admiten gastos', () {
    expect(_proyecto(1, EstadoProyecto.aprobado).admiteGastos, isTrue);
    expect(_proyecto(1, EstadoProyecto.enviado).admiteGastos, isFalse);
    expect(_proyecto(1, EstadoProyecto.finalizado).admiteGastos, isTrue);
  });
}
