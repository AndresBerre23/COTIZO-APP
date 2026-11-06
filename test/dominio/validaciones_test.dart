import 'package:cotizo_app/datos/validaciones_datos.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rechaza una suma de materiales superior al límite', () {
    final proyecto = Proyecto(
      nombreCliente: 'Cliente',
      descripcion: 'Proyecto',
      fechaInicio: DateTime(2026, 11, 5),
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
}
