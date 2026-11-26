import 'package:coti/funcionalidades/materiales/busqueda_wikimedia/consultas_alternativas_wikimedia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('amplía la búsqueda de correas de hierro con términos relacionados', () {
    expect(obtenerConsultasAlternativasWikimedia('Correas de hierro'), [
      'iron strap hinge',
      'strap hinge',
    ]);
  });

  test(
    'normaliza espacios y conserva vacías las búsquedas sin equivalencia',
    () {
      expect(obtenerConsultasAlternativasWikimedia('  Correa   de hierro '), [
        'iron strap hinge',
        'strap hinge',
      ]);
      expect(obtenerConsultasAlternativasWikimedia('mdf'), isEmpty);
    },
  );
}
