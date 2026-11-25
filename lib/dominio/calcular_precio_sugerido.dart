// Margen con el que nacen las cotizaciones si el usuario no define otro.
const margenSugeridoFijoPuntos = 2000;

// Precio que deja el margen indicado sobre el precio de venta (P-025).
int? calcularPrecioSugerido(
  int costoCentavos, {
  int cobroManoObraCentavos = 0,
  int margenPuntos = margenSugeridoFijoPuntos,
}) {
  if (costoCentavos < 0 || cobroManoObraCentavos < 0) return null;
  if (margenPuntos < 0 || margenPuntos >= 10000) return null;
  if (costoCentavos == 0) {
    return cobroManoObraCentavos == 0 ? null : cobroManoObraCentavos;
  }
  final denominador = 10000 - margenPuntos;
  return (costoCentavos * 10000 + denominador - 1) ~/ denominador +
      cobroManoObraCentavos;
}
