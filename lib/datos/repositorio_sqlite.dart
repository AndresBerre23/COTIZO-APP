import 'dart:io';

import 'package:path/path.dart' as rutas;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../dominio/modelos.dart';
import '../dominio/repositorio_local.dart';
import 'esquema_sqlite.dart';
import 'mapeadores_sqlite.dart';
import 'validaciones_datos.dart';

class RepositorioSqlite implements RepositorioLocal {
  RepositorioSqlite(this.base);

  final Database base;

  static Future<RepositorioSqlite> abrir({
    String? ruta,
    DatabaseFactory? fabrica,
  }) async {
    if (fabrica == null && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      fabrica = databaseFactoryFfi;
    }
    final fabricaLocal = fabrica ?? databaseFactory;
    final rutaLocal =
        ruta ??
        rutas.join(await fabricaLocal.getDatabasesPath(), 'cotizo.sqlite');
    final base = await fabricaLocal.openDatabase(
      rutaLocal,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (base) => base.execute('PRAGMA foreign_keys = ON'),
        onCreate: crearEsquema,
      ),
    );
    return RepositorioSqlite(base);
  }

  @override
  Future<DatosLocales> obtenerDatos() => base.transaction((transaccion) async {
    final proyectos = await transaccion.query('proyectos', orderBy: 'id DESC');
    final materiales = await transaccion.query(
      'materiales',
      orderBy: 'nombre COLLATE NOCASE, id',
    );
    final items = await transaccion.query('items_proyecto', orderBy: 'id');
    final gastos = await transaccion.query(
      'gastos',
      orderBy: 'fecha DESC, id DESC',
    );
    return DatosLocales(
      proyectos: List.unmodifiable(proyectos.map(leerProyecto)),
      materiales: List.unmodifiable(materiales.map(leerMaterial)),
      items: List.unmodifiable(items.map(leerItem)),
      gastos: List.unmodifiable(gastos.map(leerGasto)),
    );
  });

  @override
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items,
  ) async {
    validarProyecto(proyecto, items);
    return base.transaction((transaccion) async {
      final id = await _guardar(
        transaccion,
        'proyectos',
        proyecto.id,
        escribirProyecto(proyecto),
      );
      await transaccion.delete(
        'items_proyecto',
        where: 'proyecto_id = ?',
        whereArgs: [id],
      );
      for (final item in items) {
        await _exigirRegistro(transaccion, 'materiales', item.materialId);
        await transaccion.insert('items_proyecto', escribirItem(item, id));
      }
      return id;
    });
  }

  @override
  Future<int> guardarMaterial(MaterialObra material) async {
    validarMaterial(material);
    return base.transaction(
      (transaccion) => _guardar(
        transaccion,
        'materiales',
        material.id,
        escribirMaterial(material),
      ),
    );
  }

  @override
  Future<int> guardarGasto(Gasto gasto) async {
    validarGasto(gasto);
    return base.transaction((transaccion) async {
      if (gasto.proyectoId != null) {
        await _exigirRegistro(transaccion, 'proyectos', gasto.proyectoId!);
      }
      return _guardar(transaccion, 'gastos', gasto.id, escribirGasto(gasto));
    });
  }

  @override
  Future<void> eliminarProyecto(int id) async {
    await base.delete('proyectos', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> eliminarMaterial(int id) => base.transaction((
    transaccion,
  ) async {
    final referencias = await transaccion.query(
      'items_proyecto',
      columns: ['id'],
      where: 'material_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (referencias.isNotEmpty) {
      throw const FormatException(
        'Este material está en una cotización. Puedes editarlo, pero no eliminarlo.',
      );
    }
    await transaccion.delete('materiales', where: 'id = ?', whereArgs: [id]);
  });

  @override
  Future<void> eliminarGasto(int id) async {
    await base.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> cerrar() => base.close();

  Future<int> _guardar(
    DatabaseExecutor transaccion,
    String tabla,
    int id,
    Map<String, Object?> valores,
  ) async {
    if (id == 0) return transaccion.insert(tabla, valores);
    final actualizados = await transaccion.update(
      tabla,
      valores,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (actualizados != 1) {
      throw const FormatException(
        'El registro ya no existe. Actualiza la pantalla.',
      );
    }
    return id;
  }

  Future<void> _exigirRegistro(
    DatabaseExecutor transaccion,
    String tabla,
    int id,
  ) async {
    final registros = await transaccion.query(
      tabla,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (registros.isEmpty) {
      throw const FormatException('El registro relacionado ya no existe.');
    }
  }
}
