import 'modelos.dart';

class DesgloseProforma {
  const DesgloseProforma({
    required this.totalMaterialesCentavos,
    required this.totalGastosPrevistosCentavos,
    required this.cobroManoObraCentavos,
    required this.ajusteComercialCentavos,
    this.totalServiciosCentavos = 0,
  });

  final int totalMaterialesCentavos;
  final int totalGastosPrevistosCentavos;
  final int cobroManoObraCentavos;
  final int ajusteComercialCentavos;
  final int totalServiciosCentavos;
}

DesgloseProforma calcularDesgloseProforma(
  Proyecto proyecto,
  List<ItemProyecto> items,
  List<GastoPrevisto> gastosPrevistos,
) {
  final materiales = items.fold<int>(
    0,
    (total, item) => total + item.costoCentavos,
  );
  final servicios = items.fold<int>(
    0,
    (total, item) => total + item.precioServicioCentavos,
  );
  final gastos = gastosPrevistos.fold<int>(
    0,
    (total, gasto) => total + gasto.montoCentavos,
  );
  return DesgloseProforma(
    totalMaterialesCentavos: materiales,
    totalGastosPrevistosCentavos: gastos,
    cobroManoObraCentavos: proyecto.cobroManoObraCentavos,
    totalServiciosCentavos: servicios,
    ajusteComercialCentavos:
        proyecto.totalCotizadoCentavos -
        materiales -
        gastos -
        proyecto.cobroManoObraCentavos -
        servicios,
  );
}

// Con consumos registrados, el material cotizado ya no se descuenta (D-020).
int calcularResultadoCierre(
  DesgloseProforma proforma,
  List<Gasto> gastosAdicionales, {
  int adicionalesCobradosCentavos = 0,
}) =>
    proforma.ajusteComercialCentavos +
    proforma.cobroManoObraCentavos +
    proforma.totalServiciosCentavos +
    adicionalesCobradosCentavos +
    (gastosAdicionales.any((gasto) => gasto.esConsumo)
        ? proforma.totalMaterialesCentavos
        : 0) -
    gastosAdicionales
        .where((gasto) => !gasto.esDevolucion)
        .fold<int>(0, (total, gasto) => total + gasto.montoCentavos);
