import 'package:coti/core/formato.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el código del documento usa cuatro dígitos', () {
    expect(codigoDocumento(1), 'COT-0001');
    expect(codigoDocumento(12345), 'COT-12345');
  });

  test('la búsqueda acepta el código con tres o cuatro dígitos', () {
    final texto = codigosBusqueda(12);
    expect(texto, contains('cot-012'));
    expect(texto, contains('cot-0012'));
  });
}
