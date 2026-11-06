import 'dart:io';

import 'package:cotizo_app/datos/repositorio_sqlite.dart';
import 'package:cotizo_app/dominio/calcular_rentabilidad.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as rutas;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late RepositorioSqlite repositorio;
  late int materialId;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    repositorio = await RepositorioSqlite.abrir(
      ruta: inMemoryDatabasePath,
      fabrica: databaseFactoryFfi,
    );
    materialId = await repositorio.guardarMaterial(
      const MaterialObra(
        nombre: 'Cable',
        unidadMedida: 'm',
        costoBaseCentavos: 125,
      ),
    );
  });
  tearDown(() => repositorio.cerrar());

  test(
    'guarda relaciones y conserva precios históricos al editar el catálogo',
    () async {
      final id = await repositorio.guardarProyecto(_proyecto(), [
        _item(materialId),
      ]);
      await repositorio.guardarGasto(_gasto(id, 250));
      await repositorio.guardarGasto(_gasto(null, 1000));
      await repositorio.guardarMaterial(
        MaterialObra(
          id: materialId,
          nombre: 'Cable actualizado',
          unidadMedida: 'rollo',
          costoBaseCentavos: 9999,
        ),
      );
      final datos = await repositorio.obtenerDatos();
      expect(datos.items.single.nombreMaterial, 'Cable');
      expect(datos.items.single.unidadMedida, 'm');
      expect(datos.items.single.costoUnitarioAplicadoCentavos, 125);
      expect(datos.items.single.subtotalCentavos, 313);
      expect(datos.items.single.proyectoId, id);
      expect(datos.materiales.single.costoBaseCentavos, 9999);
      expect(
        calcularRentabilidad(datos.proyectos.single, datos.items, datos.gastos),
        4437,
      );
      expect(() => datos.proyectos.clear(), throwsUnsupportedError);
    },
  );

  test(
    'editar un proyecto preserva sus gastos y sustituye solo el detalle',
    () async {
      final id = await repositorio.guardarProyecto(_proyecto(), [
        _item(materialId),
      ]);
      final gastoId = await repositorio.guardarGasto(_gasto(id, 250));
      await repositorio.guardarProyecto(_proyecto(id: id, total: 8000), [
        _item(materialId, cantidad: 4),
      ]);
      final datos = await repositorio.obtenerDatos();
      expect(datos.proyectos.single.id, id);
      expect(datos.proyectos.single.totalCotizadoCentavos, 8000);
      expect(datos.gastos.single.id, gastoId);
      expect(datos.items.single.cantidad, 4);
    },
  );

  test('revierte cabecera y detalle si un material no existe', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), [
      _item(materialId),
    ]);
    await expectLater(
      repositorio.guardarProyecto(_proyecto(id: id, total: 99999), [
        _item(materialId),
        _item(999999),
      ]),
      throwsFormatException,
    );
    await expectLater(
      repositorio.guardarProyecto(_proyecto(), [_item(999999)]),
      throwsFormatException,
    );
    final datos = await repositorio.obtenerDatos();
    expect(datos.proyectos.length, 1);
    expect(datos.proyectos.single.totalCotizadoCentavos, 5000);
    expect(datos.items.length, 1);
    expect(datos.items.single.materialId, materialId);
  });

  test(
    'impide borrar materiales usados y elimina dependencias de un proyecto',
    () async {
      final id = await repositorio.guardarProyecto(_proyecto(), [
        _item(materialId),
      ]);
      await repositorio.guardarGasto(_gasto(id, 250));
      await repositorio.guardarGasto(_gasto(null, 1000));
      await expectLater(
        repositorio.eliminarMaterial(materialId),
        throwsFormatException,
      );
      await repositorio.eliminarProyecto(id);
      final datos = await repositorio.obtenerDatos();
      expect(datos.proyectos, isEmpty);
      expect(datos.items, isEmpty);
      expect(datos.gastos.single.proyectoId, isNull);
      await repositorio.eliminarMaterial(materialId);
      expect((await repositorio.obtenerDatos()).materiales, isEmpty);
    },
  );

  test('edita y elimina gastos sin duplicarlos', () async {
    final id = await repositorio.guardarGasto(_gasto(null, 1000));
    await repositorio.guardarGasto(
      Gasto(
        id: id,
        montoCentavos: 300,
        categoria: 'Alimentación',
        fecha: DateTime(2026, 11, 6),
        nota: 'Corregido',
      ),
    );
    expect((await repositorio.obtenerDatos()).gastos.single.montoCentavos, 300);
    await repositorio.eliminarGasto(id);
    expect((await repositorio.obtenerDatos()).gastos, isEmpty);
  });

  test('rechaza cantidades inválidas y gastos huérfanos', () async {
    for (final cantidad in [
      0.0,
      -1.0,
      0.0001,
      1.0001,
      double.nan,
      double.infinity,
    ]) {
      await expectLater(
        repositorio.guardarProyecto(_proyecto(), [
          _item(materialId, cantidad: cantidad),
        ]),
        throwsFormatException,
      );
    }
    await expectLater(
      repositorio.guardarGasto(_gasto(9999, 200)),
      throwsFormatException,
    );
    await expectLater(
      repositorio.guardarGasto(_gasto(null, 0)),
      throwsFormatException,
    );
    expect((await repositorio.obtenerDatos()).proyectos, isEmpty);
  });

  test('mantiene los datos al cerrar y abrir un archivo SQLite', () async {
    final carpeta = await Directory.systemTemp.createTemp('cotizo_sqlite_');
    final ruta = rutas.join(carpeta.path, 'persistencia.sqlite');
    RepositorioSqlite? local;
    try {
      local = await RepositorioSqlite.abrir(
        ruta: ruta,
        fabrica: databaseFactoryFfi,
      );
      final id = await local.guardarProyecto(_proyecto(), []);
      await local.guardarGasto(_gasto(id, 200));
      await local.cerrar();
      local = await RepositorioSqlite.abrir(
        ruta: ruta,
        fabrica: databaseFactoryFfi,
      );
      final datos = await local.obtenerDatos();
      expect(datos.proyectos.single.id, id);
      expect(datos.proyectos.single.nombreCliente, 'Cliente Álvarez');
      expect(datos.gastos.single.proyectoId, id);
    } finally {
      await local?.cerrar();
      await databaseFactoryFfi.deleteDatabase(ruta);
      await carpeta.delete();
    }
  });
}

Proyecto _proyecto({int id = 0, int total = 5000}) => Proyecto(
  id: id,
  nombreCliente: 'Cliente Álvarez',
  descripcion: 'Instalación eléctrica',
  fechaInicio: DateTime(2026, 11, 5),
  totalCotizadoCentavos: total,
);

ItemProyecto _item(int materialId, {double cantidad = 2.5}) => ItemProyecto(
  materialId: materialId,
  cantidad: cantidad,
  costoUnitarioAplicadoCentavos: 125,
  nombreMaterial: 'Cable',
  unidadMedida: 'm',
);

Gasto _gasto(int? proyectoId, int monto) => Gasto(
  proyectoId: proyectoId,
  montoCentavos: monto,
  categoria: 'Transporte',
  fecha: DateTime(2026, 11, 5),
);
