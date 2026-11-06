import 'package:cotizo_app/aplicacion/cotizo_cubit.dart';
import 'package:cotizo_app/core/formato.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import '../apoyo/repositorio_lectura.dart';

void main() {
  test('distingue fallo de lectura y permite reintentar', () async {
    final repositorio = RepositorioLectura(const DatosLocales())
      ..fallarLectura = true;
    final cubit = CotizoCubit(repositorio);
    await cubit.cargar();
    expect(cubit.state.falloCarga, isTrue);
    repositorio.fallarLectura = false;
    await cubit.cargar();
    expect(cubit.state.falloCarga, isFalse);
    await cubit.close();
  });

  test(
    'no invita a duplicar una escritura si falla el refresco posterior',
    () async {
      final repositorio = RepositorioLectura(const DatosLocales());
      final cubit = CotizoCubit(repositorio);
      await cubit.cargar();
      repositorio.fallarLectura = true;
      const material = MaterialObra(
        nombre: 'Cable',
        unidadMedida: 'm',
        costoBaseCentavos: 100,
      );
      expect(await cubit.guardarMaterial(material), isTrue);
      expect(cubit.state.falloCarga, isTrue);
      expect(await cubit.guardarMaterial(material), isFalse);
      expect(repositorio.escrituras, 1);
      await cubit.close();
    },
  );

  test('importes con coma o punto y rechazo de valores ambiguos', () {
    expect(leerCentavos('12,35'), 1235);
    expect(leerCentavos('12.35'), 1235);
    for (final valor in [
      'NaN',
      'Infinity',
      '-1',
      '1.234',
      '1,234.50',
      '1e3',
      '',
    ]) {
      expect(leerCentavos(valor), isNull, reason: valor);
    }
    expect(leerCantidad('0,125'), .125);
    expect(leerCantidad('0'), isNull);
    expect(leerCantidad('1.0001'), isNull);
    expect(validarCosto('0'), isNull);
    expect(validarCosto('-1'), isNotNull);
    expect(validarImporte('0'), isNotNull);
    expect(dinero(-123456), '-\$ 1.234,56');
  });
}
