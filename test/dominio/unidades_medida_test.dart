import 'package:coti/dominio/unidades_medida.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('incluye las unidades agrupadas previstas para construcción', () {
    expect(
      gruposUnidadesMedida.expand((grupo) => grupo.unidades),
      hasLength(25),
    );
  });

  test('busca símbolos equivalentes sin convertir la unidad elegida', () {
    expect(buscarUnidadesMedida('m2').single.nombre, 'm²');
    expect(buscarUnidadesMedida('m3').single.nombre, 'm³');
    expect(buscarUnidadesMedida('galon').single.nombre, 'galón');
    expect(esUnidadPredefinida('libra'), isTrue);
    expect(esUnidadPredefinida('cubeta personalizada'), isFalse);
  });

  test('reconoce escritura histórica de unidades predefinidas', () {
    expect(esUnidadPredefinida('unidad'), isTrue);
    expect(esUnidadPredefinida('M2'), isTrue);
  });
}
