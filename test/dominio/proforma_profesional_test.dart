import 'package:cotizo_app/dominio/calcular_cobros_proyecto.dart';
import 'package:cotizo_app/dominio/calcular_desglose_proforma.dart';
import 'package:cotizo_app/dominio/calcular_partidas_cliente.dart';
import 'package:cotizo_app/dominio/calcular_precio_sugerido.dart';
import 'package:cotizo_app/dominio/calcular_presupuesto_proyecto.dart';
import 'package:cotizo_app/dominio/calcular_rentabilidad.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

const _material = ItemProyecto(
  proyectoId: 1,
  materialId: 1,
  cantidad: 1,
  costoUnitarioAplicadoCentavos: 8000,
  nombreMaterial: 'Cable',
  unidadMedida: 'm',
);

const _servicio = ItemProyecto(
  proyectoId: 1,
  esServicio: true,
  cantidad: 2,
  costoUnitarioAplicadoCentavos: 2500,
  nombreMaterial: 'Instalación',
  unidadMedida: 'punto',
);

Proyecto _proyecto({int total = 15000, int? iva}) => Proyecto(
  id: 1,
  nombreCliente: 'Cliente',
  descripcion: 'Obra',
  fechaInicio: DateTime(2026, 11, 1),
  fechaCreacion: DateTime(2026, 11, 25),
  totalCotizadoCentavos: total,
  ivaPuntos: iva,
  validezDias: 15,
);

void main() {
  test('el servicio no es costo y conserva su precio para el cliente', () {
    expect(_servicio.costoCentavos, 0);
    expect(_servicio.precioServicioCentavos, 5000);
    final proyecto = _proyecto();
    // 15000 - 8000 de material = 7000 de resultado: el servicio es ingreso.
    expect(calcularRentabilidad(proyecto, [_material, _servicio], []), 7000);
    final partidas = calcularPartidasCliente(proyecto, [
      _material,
      _servicio,
    ], []);
    final instalacion = partidas.firstWhere(
      (p) => p.descripcion == 'Instalación',
    );
    expect(instalacion.subtotalCentavos, 5000);
    expect(partidas.fold<int>(0, (s, p) => s + p.subtotalCentavos), 15000);
    final desglose = calcularDesgloseProforma(proyecto, [
      _material,
      _servicio,
    ], []);
    expect(desglose.totalMaterialesCentavos, 8000);
    expect(desglose.totalServiciosCentavos, 5000);
    expect(desglose.ajusteComercialCentavos, 2000);
  });

  test('el precio sugerido usa el margen configurado y suma servicios', () {
    expect(calcularPrecioSugerido(7000, margenPuntos: 3000), 10000);
    final presupuesto = calcularPresupuestoProyecto(
      [_material, _servicio],
      const [],
      margenPuntos: 2000,
    );
    expect(presupuesto.costoMaterialesCentavos, 8000);
    expect(presupuesto.precioServiciosCentavos, 5000);
    expect(presupuesto.precioSugeridoCentavos, 10000 + 5000);
  });

  test('calcula IVA, total, validez y saldo con IVA', () {
    final proyecto = _proyecto(total: 10000, iva: 1500);
    expect(proyecto.ivaCentavos, 1500);
    expect(proyecto.totalConIvaCentavos, 11500);
    expect(proyecto.validaHasta, DateTime(2026, 12, 10));
    expect(_proyecto(iva: null).ivaCentavos, 0);
    final cobros = calcularCobrosProyecto(proyecto, [
      Ingreso(
        proyectoId: 1,
        montoCentavos: 5000,
        categoria: 'Anticipo',
        fecha: DateTime(2026, 11, 26),
      ),
    ]);
    expect(cobros.saldoCentavos, 6500);
  });

  test('rechazadas y canceladas no admiten gastos ni quedan en curso', () {
    final cancelada = Proyecto(
      id: 2,
      nombreCliente: 'C',
      descripcion: 'D',
      fechaInicio: DateTime(2026, 11, 1),
      fechaInicioReal: DateTime(2026, 11, 2),
      estado: EstadoProyecto.cancelado,
      totalCotizadoCentavos: 100,
    );
    expect(cancelada.estaEnCurso, isFalse);
    expect(cancelada.etapa, 'Cancelado');
    expect(
      _proyecto().conEstado(EstadoProyecto.rechazado).admiteGastos,
      isFalse,
    );
  });
}
