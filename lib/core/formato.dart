String dinero(int centavos) {
  final absoluto = centavos.abs();
  final entero = (absoluto ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (coincidencia) => '.',
  );
  return '${centavos < 0 ? '-' : ''}\$ $entero,${(absoluto % 100).toString().padLeft(2, '0')}';
}

// Código visible de una cotización, igual en la app y en el PDF.
String codigoDocumento(int id) => 'COT-${id.toString().padLeft(4, '0')}';

// Texto de búsqueda que acepta el código con 3 o 4 dígitos.
String codigosBusqueda(int id) =>
    'cot-${id.toString().padLeft(3, '0')} ${codigoDocumento(id).toLowerCase()} $id';

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

// Ejemplo: "noviembre de 2026".
String mesLargo(DateTime fecha) =>
    '${_meses[fecha.month - 1]} de ${fecha.year}';

// Cantidad sin ceros sobrantes y con coma decimal: 18.0 -> "18".
String cantidadCorta(double cantidad) {
  var texto = cantidad.toStringAsFixed(3);
  texto = texto.replaceFirst(RegExp(r'\.?0+$'), '');
  return texto.replaceAll('.', ',');
}

String fechaCorta(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

String horaCorta(DateTime fecha) =>
    '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

String fechaHoraCorta(DateTime fecha) =>
    '${fechaCorta(fecha)} · ${horaCorta(fecha)}';

int? leerCentavos(String texto) {
  final normalizado = texto.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(normalizado)) return null;
  final partes = normalizado.split('.');
  return int.parse(partes[0]) * 100 +
      (partes.length == 2 ? int.parse(partes[1].padRight(2, '0')) : 0);
}

double? leerCantidad(String texto) {
  final normalizado = texto.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,6}(\.\d{1,3})?$').hasMatch(normalizado)) return null;
  final cantidad = double.tryParse(normalizado);
  return cantidad != null && cantidad > 0 ? cantidad : null;
}

String? validarImporte(String? texto) {
  final centavos = leerCentavos(texto ?? '');
  return centavos == null || centavos <= 0
      ? 'Ingresa un monto mayor a cero, con hasta 2 decimales.'
      : null;
}

String? validarCosto(String? texto) => leerCentavos(texto ?? '') == null
    ? 'Ingresa un costo válido con hasta 2 decimales.'
    : null;

String? validarRequerido(String? texto) =>
    texto == null || texto.trim().isEmpty ? 'Completa este campo.' : null;
