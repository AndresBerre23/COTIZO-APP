import 'modelos.dart';

class DesgloseProforma {
  const DesgloseProforma({
    required this.totalMaterialesCentavos,
    required this.totalGastosPrevistosCentavos,
    required this.ajusteComercialCentavos,
  });

  final int totalMaterialesCentavos;
  final int totalGastosPrevistosCentavos;
  final int ajusteComercialCentavos;
}

DesgloseProforma calcularDesgloseProforma(
  Proyecto proyecto,
  List<ItemProyecto> items,
  List<GastoPrevisto> gastosPrevistos,
) {
  final materiales = items.fold<int>(
    0,
    (total, item) => total + item.subtotalCentavos,
  );
  final gastos = gastosPrevistos.fold<int>(
    0,
    (total, gasto) => total + gasto.montoCentavos,
  );
  return DesgloseProforma(
    totalMaterialesCentavos: materiales,
    totalGastosPrevistosCentavos: gastos,
    ajusteComercialCentavos:
        proyecto.totalCotizadoCentavos - materiales - gastos,
  );
}
