import 'package:cotizo_app/datos/validaciones_datos.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rechaza una suma de materiales superior al límite', () {
    final proyecto = Proyecto(
      nombreCliente: 'Cliente',
      descripcion: 'Proyecto',
      fechaInicio: DateTime(2026, 11, 5),
      fechaFin: DateTime(2026, 11, 15),
      totalCotizadoCentavos: 10000,
    );
    const item = ItemProyecto(
      materialId: 1,
      cantidad: 1,
      costoUnitarioAplicadoCentavos: 750000000000,
      nombreMaterial: 'Material',
      unidadMedida: 'u',
    );
    expect(() => validarProyecto(proyecto, [item]), returnsNormally);
    expect(
      () => validarProyecto(proyecto, [item, item]),
      throwsFormatException,
    );
  });

  test('conserva cotizaciones históricas sin fecha final prevista', () {
    final historica = Proyecto(
      id: 4,
      nombreCliente: 'Cliente histórico',
      descripcion: 'Trabajo anterior',
      fechaInicio: DateTime(2024, 1, 1),
      totalCotizadoCentavos: 10000,
    );

    expect(() => validarProyecto(historica, []), returnsNormally);
    expect(
      () => validarProyecto(
        Proyecto(
          nombreCliente: 'Cliente nuevo',
          descripcion: 'Cotización nueva',
          fechaInicio: DateTime(2026, 11, 8),
          totalCotizadoCentavos: 10000,
        ),
        [],
      ),
      throwsFormatException,
    );
  });
}
