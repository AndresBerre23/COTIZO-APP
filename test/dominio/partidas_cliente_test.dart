import 'package:coti/dominio/calcular_partidas_cliente.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

Proyecto _proyecto(int total, {int manoObra = 0}) => Proyecto(
  id: 1,
  nombreCliente: 'Cliente',
  descripcion: 'Instalación',
  fechaInicio: DateTime(2026, 11, 25),
  totalCotizadoCentavos: total,
  cobroManoObraCentavos: manoObra,
);

ItemProyecto _item(String nombre, double cantidad, int costo) => ItemProyecto(
  proyectoId: 1,
  materialId: 1,
  cantidad: cantidad,
  costoUnitarioAplicadoCentavos: costo,
  nombreMaterial: nombre,
  unidadMedida: 'u',
);

void main() {
  test('reparte el margen y conserva el total exacto', () {
    final partidas = calcularPartidasCliente(
      _proyecto(10001, manoObra: 1000),
      [_item('Cable', 3, 1000), _item('Tubo', 1, 3333)],
      const [
        GastoPrevisto(
          proyectoId: 1,
          categoria: 'Transporte',
          montoCentavos: 500,
        ),
      ],
    );
    expect(partidas.map((p) => p.descripcion), [
      'Cable',
      'Tubo',
      etiquetaManoObraCliente,
    ]);
    expect(partidas.fold<int>(0, (s, p) => s + p.subtotalCentavos), 10001);
    // Cada partida sube en la misma proporción que el total.
    expect(partidas.first.subtotalCentavos, greaterThan(3000));
  });

  test('sin costos registrados, el total va en una sola línea', () {
    final partidas = calcularPartidasCliente(
      _proyecto(5000),
      const [],
      const [],
    );
    expect(partidas.single.subtotalCentavos, 5000);
    expect(partidas.single.descripcion, 'Instalación');
  });

  test('sin total ni costos no genera partidas', () {
    expect(calcularPartidasCliente(_proyecto(0), const [], const []), isEmpty);
  });
}
