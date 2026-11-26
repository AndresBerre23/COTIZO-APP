import 'dart:io';

import 'package:path/path.dart' as rutas;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../dominio/modelos.dart';
import '../dominio/repositorio_local.dart';
import 'esquema_sqlite.dart';
import 'mapeadores_sqlite.dart';
import 'operaciones_clientes_sqlite.dart';
import 'operaciones_fotos_sqlite.dart';
import 'operaciones_ingresos_sqlite.dart';
import 'operaciones_obra_sqlite.dart';
import 'utilidades_sqlite.dart';
import 'validaciones_datos.dart';
import 'versiones_proforma_sqlite.dart';

class RepositorioSqlite
    with
        OperacionesIngresosSqlite,
        OperacionesClientesSqlite,
        OperacionesObraSqlite,
        OperacionesFotosSqlite
    implements RepositorioLocal {
  RepositorioSqlite(this.base);

  @override
  final Database base;

  static const versionEsquema = 13;

  static DatabaseFactory _fabrica(DatabaseFactory? fabrica) {
    if (fabrica == null && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }
    return fabrica ?? databaseFactory;
  }

  // Ruta del archivo de datos que usa la app por defecto.
  // El archivo conserva el nombre histórico para no perder datos instalados.
  static Future<String> rutaPredeterminada({DatabaseFactory? fabrica}) async =>
      rutas.join(await _fabrica(fabrica).getDatabasesPath(), 'cotizo.sqlite');

  static Future<RepositorioSqlite> abrir({
    String? ruta,
    DatabaseFactory? fabrica,
  }) async {
    final fabricaLocal = _fabrica(fabrica);
    final rutaLocal = ruta ?? await rutaPredeterminada(fabrica: fabricaLocal);
    final base = await fabricaLocal.openDatabase(
      rutaLocal,
      options: OpenDatabaseOptions(
        version: versionEsquema,
        onCreate: crearEsquema,
        onUpgrade: migrarEsquema,
      ),
    );
    // Se activan después de migrar: las migraciones recrean tablas referenciadas.
    await base.execute('PRAGMA foreign_keys = ON');
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
    final gastosPrevistos = await transaccion.query(
      'gastos_previstos',
      orderBy: 'id',
    );
    final adicionales = await transaccion.query(
      'adicionales',
      orderBy: 'fecha, id',
    );
    final versiones = await transaccion.query('versiones_proforma');
    final fotos = await transaccion.query('fotos_obra');
    final clientes = await transaccion.query(
      'clientes',
      orderBy: 'nombre COLLATE NOCASE, id',
    );
    final ingresos = await transaccion.query(
      'ingresos',
      orderBy: 'fecha DESC, id DESC',
    );
    return DatosLocales(
      proyectos: List.unmodifiable(proyectos.map(leerProyecto)),
      materiales: List.unmodifiable(materiales.map(leerMaterial)),
      items: List.unmodifiable(items.map(leerItem)),
      gastos: List.unmodifiable(gastos.map(leerGasto)),
      gastosPrevistos: List.unmodifiable(
        gastosPrevistos.map(leerGastoPrevisto),
      ),
      ingresos: List.unmodifiable(ingresos.map(leerIngreso)),
      clientes: List.unmodifiable(clientes.map(leerCliente)),
      adicionales: List.unmodifiable(adicionales.map(leerAdicional)),
      versiones: List.unmodifiable(versiones.map(leerVersion)),
      fotos: List.unmodifiable(fotos.map(leerFoto)),
    );
  });

  @override
  Future<PreferenciasApp> obtenerPreferencias() async {
    final filas = await base.query(
      'preferencias_app',
      where: 'id = 1',
      limit: 1,
    );
    if (filas.isEmpty) return const PreferenciasApp();
    return leerPreferencias(filas.single);
  }

  @override
  Future<void> guardarPreferencias(PreferenciasApp preferencias) async {
    await base.insert(
      'preferencias_app',
      escribirPreferencias(preferencias),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto>? gastosPrevistos,
    Cliente? cliente,
  }) async {
    validarProyecto(proyecto, items, gastosPrevistos ?? const []);
    if (cliente != null) validarCliente(cliente);
    return base.transaction((transaccion) async {
      await conservarVersionPrevia(transaccion, proyecto, items);
      // Crea o actualiza el cliente y lo enlaza a la cotización (P-021).
      final clienteId = cliente == null
          ? proyecto.clienteId
          : await guardarRegistro(
              transaccion,
              'clientes',
              cliente.id,
              escribirCliente(cliente),
            );
      final id = await guardarRegistro(transaccion, 'proyectos', proyecto.id, {
        ...escribirProyecto(proyecto),
        'cliente_id': clienteId,
      });
      await transaccion.delete(
        'items_proyecto',
        where: 'proyecto_id = ?',
        whereArgs: [id],
      );
      for (final item in items) {
        if (!item.esServicio) {
          await exigirRegistro(transaccion, 'materiales', item.materialId!);
        }
        await transaccion.insert('items_proyecto', escribirItem(item, id));
      }
      if (gastosPrevistos != null) {
        await transaccion.delete(
          'gastos_previstos',
          where: 'proyecto_id = ?',
          whereArgs: [id],
        );
        for (final gasto in gastosPrevistos) {
          await transaccion.insert(
            'gastos_previstos',
            escribirGastoPrevisto(gasto, id),
          );
        }
      }
      return id;
    });
  }

  @override
  Future<int> guardarMaterial(MaterialObra material) async {
    validarMaterial(material);
    return base.transaction(
      (transaccion) => guardarRegistro(
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
        await exigirRegistro(transaccion, 'proyectos', gasto.proyectoId!);
      }
      return guardarRegistro(transaccion, 'gastos', gasto.id, {
        ...escribirGasto(gasto),
        'origen': await origenDeProyecto(transaccion, gasto.proyectoId),
      });
    });
  }

  @override
  Future<void> eliminarProyecto(int id) => base.transaction((t) async {
    final conDinero = await t.rawQuery(
      'SELECT 1 FROM gastos WHERE proyecto_id = ? '
      'UNION SELECT 1 FROM ingresos WHERE proyecto_id = ? LIMIT 1',
      [id, id],
    );
    if (conDinero.isNotEmpty) {
      throw const FormatException(
        'Tiene cobros o gastos registrados. Cancélala para conservar su historial.',
      );
    }
    await t.delete('proyectos', where: 'id = ?', whereArgs: [id]);
  });

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

  @override
  Future<void> prepararRespaldo() async {
    // Vuelca el registro WAL, si existe, al archivo principal.
    await base.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}
