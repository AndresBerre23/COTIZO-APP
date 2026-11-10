import 'package:cotizo_app/dominio/calcular_desglose_proforma.dart';
import 'package:cotizo_app/dominio/calcular_presupuesto_proyecto.dart';
import 'package:cotizo_app/dominio/calcular_precio_sugerido.dart';
import 'package:cotizo_app/dominio/calcular_rentabilidad.dart';
import 'package:cotizo_app/dominio/categorias_gasto.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'comparte ocho categorías simples entre gastos previstos y registrados',
    () {
      expect(categoriasGasto, hasLength(8));
      expect(categoriasGasto, contains('Transporte de materiales'));
      expect(categoriasGasto, contains('Transporte propio'));
    },
  );

  test(
    'sugiere el precio con margen fijo del 15 % y redondeo hacia arriba',
    () {
      expect(calcularPrecioSugerido(10000), 11765);
      expect(calcularPrecioSugerido(1), 2);
      expect(calcularPrecioSugerido(0), isNull);
    },
  );

  test('desglosa gastos previstos y ajuste sin mezclar gastos reales', () {
    final proyecto = Proyecto(
      id: 1,
      nombreCliente: 'Cliente',
      descripcion: 'Instalación',
      fechaInicio: DateTime(2026, 11, 8),
      fechaFin: DateTime(2026, 11, 8),
      totalCotizadoCentavos: 20000,
    );
    const item = ItemProyecto(
      proyectoId: 1,
      materialId: 1,
      cantidad: 1,
      costoUnitarioAplicadoCentavos: 10000,
      nombreMaterial: 'Material',
      unidadMedida: 'unidad',
    );
    const previsto = GastoPrevisto(
      proyectoId: 1,
      categoria: 'Transporte propio',
      montoCentavos: 10000,
    );
    final registrado = Gasto(
      proyectoId: 1,
      montoCentavos: 8000,
      categoria: 'Alimentación',
      fecha: DateTime(2026, 11, 8),
    );

    final desglose = calcularDesgloseProforma(proyecto, [item], [previsto]);
    final presupuesto = calcularPresupuestoProyecto([item], [previsto]);

    expect(desglose.totalMaterialesCentavos, 10000);
    expect(desglose.totalGastosPrevistosCentavos, 10000);
    expect(desglose.ajusteComercialCentavos, 0);
    expect(presupuesto.costoMaterialesCentavos, 10000);
    expect(presupuesto.costoPrevistoCentavos, 20000);
    expect(presupuesto.precioSugeridoCentavos, 23530);
    expect(calcularRentabilidad(proyecto, [item], [registrado]), 2000);

    final descuento = Proyecto(
      id: proyecto.id,
      nombreCliente: proyecto.nombreCliente,
      descripcion: proyecto.descripcion,
      fechaInicio: proyecto.fechaInicio,
      fechaFin: proyecto.fechaFin,
      totalCotizadoCentavos: 18000,
    );
    expect(
      calcularDesgloseProforma(
        descuento,
        [item],
        [previsto],
      ).ajusteComercialCentavos,
      -2000,
    );
  });
}
