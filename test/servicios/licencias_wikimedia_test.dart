import 'package:coti/funcionalidades/materiales/busqueda_wikimedia/licencias_wikimedia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admite licencias abiertas que permiten reutilización', () {
    expect(admiteLicenciaWikimedia('CC BY 4.0'), isTrue);
    expect(admiteLicenciaWikimedia('CC BY-SA 4.0'), isTrue);
    expect(admiteLicenciaWikimedia('CC0 1.0'), isTrue);
    expect(admiteLicenciaWikimedia('Public domain'), isTrue);
  });

  test('excluye licencias no comerciales o sin obras derivadas', () {
    expect(admiteLicenciaWikimedia('CC BY-NC 4.0'), isFalse);
    expect(admiteLicenciaWikimedia('CC BY-ND 4.0'), isFalse);
    expect(admiteLicenciaWikimedia('CC BY-NC-ND 4.0'), isFalse);
    expect(admiteLicenciaWikimedia('Unknown'), isFalse);
  });
}
