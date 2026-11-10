const margenSugeridoFijoPuntos = 2000;

int? calcularPrecioSugerido(
  int costoCentavos, {
  int cobroManoObraCentavos = 0,
}) {
  if (costoCentavos < 0 || cobroManoObraCentavos < 0) return null;
  if (costoCentavos == 0) {
    return cobroManoObraCentavos == 0 ? null : cobroManoObraCentavos;
  }
  const denominador = 10000 - margenSugeridoFijoPuntos;
  return (costoCentavos * 10000 + denominador - 1) ~/ denominador +
      cobroManoObraCentavos;
}
