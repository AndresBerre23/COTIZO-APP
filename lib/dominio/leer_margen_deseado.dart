int? leerMargenDeseadoPuntos(String texto) {
  final normalizado = texto.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,2}(\.\d{1,2})?$').hasMatch(normalizado)) return null;
  final partes = normalizado.split('.');
  final entero = int.parse(partes.first);
  final decimales = partes.length == 2
      ? int.parse(partes.last.padRight(2, '0'))
      : 0;
  final puntos = entero * 100 + decimales;
  return puntos < 10000 ? puntos : null;
}

String? validarMargenDeseado(String? texto) {
  if (texto == null || texto.trim().isEmpty) return null;
  return leerMargenDeseadoPuntos(texto) == null
      ? 'Ingresa un margen entre 0 y 99,99 %, con hasta 2 decimales.'
      : null;
}
