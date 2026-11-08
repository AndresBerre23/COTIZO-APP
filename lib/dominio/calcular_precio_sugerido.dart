int? calcularPrecioSugerido(int costoCentavos, int? margenPuntos) {
  if (costoCentavos <= 0 || margenPuntos == null) return null;
  if (margenPuntos < 0 || margenPuntos >= 10000) return null;
  final denominador = 10000 - margenPuntos;
  return (costoCentavos * 10000 + denominador - 1) ~/ denominador;
}
