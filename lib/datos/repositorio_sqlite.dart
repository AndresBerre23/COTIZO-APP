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
        version: 7,
        onConfigure: (base) => base.execute('PRAGMA foreign_keys = ON'),
        onCreate: crearEsquema,
        onUpgrade: migrarEsquema,
      ),
    );
    return RepositorioSqlite(base);
  }

  @override
  Future<void> iniciarObra(int proyectoId, DateTime fechaInicioReal) =>
      base.transaction((transaccion) async {
        final proyecto = await _obtenerProyecto(transaccion, proyectoId);
        if (proyecto.estado == EstadoProyecto.finalizado || proyecto.esObra) {
          throw const FormatException(
            'Esta obra ya fue iniciada o finalizada.',
          );
        }
        if (proyecto.fechaFin == null) {
          throw const FormatException(
            'Define la fecha final prevista antes de iniciar la obra.',
          );
        }
        _validarFechaReal(fechaInicioReal);
        await transaccion.update(
          'proyectos',
          {
            'estado': EstadoProyecto.aprobado.name,
            'fecha_inicio_real': fechaInicioReal.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [proyectoId],
        );
      });

  @override
  Future<void> finalizarObra(int proyectoId, DateTime fechaFinReal) =>
      base.transaction((transaccion) async {
        final proyecto = await _obtenerProyecto(transaccion, proyectoId);
        if (!proyecto.estaEnCurso) {
          throw const FormatException('Esta obra no está en curso.');
        }
        _validarFechaReal(fechaFinReal);
        if (fechaFinReal.isBefore(proyecto.fechaInicioReal!)) {
          throw const FormatException(
            'La finalización no puede ser anterior al inicio real.',
          );
        }
        await transaccion.update(
          'proyectos',
          {
            'estado': EstadoProyecto.finalizado.name,
            'fecha_fin_real': fechaFinReal.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [proyectoId],
        );
      });

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
    return DatosLocales(
      proyectos: List.unmodifiable(proyectos.map(leerProyecto)),
      materiales: List.unmodifiable(materiales.map(leerMaterial)),
      items: List.unmodifiable(items.map(leerItem)),
      gastos: List.unmodifiable(gastos.map(leerGasto)),
      gastosPrevistos: List.unmodifiable(
        gastosPrevistos.map(leerGastoPrevisto),
      ),
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
    final fila = filas.single;
    return PreferenciasApp(
      nombre: fila['nombre'] as String,
      apellido: fila['apellido'] as String,
      fotoRuta: fila['foto_ruta'] as String?,
      modoTema: ModoTema.values.firstWhere(
        (modo) => modo.name == fila['modo_tema'],
        orElse: () => ModoTema.sistema,
      ),
      omitirAvisoNombre: fila['omitir_aviso_nombre'] == 1,
    );
  }

  @override
  Future<void> guardarPreferencias(PreferenciasApp preferencias) async {
    await base.insert('preferencias_app', {
      'id': 1,
      'nombre': preferencias.nombre.trim(),
      'apellido': preferencias.apellido.trim(),
      'foto_ruta': preferencias.fotoRuta,
      'modo_tema': preferencias.modoTema.name,
      'omitir_aviso_nombre': preferencias.omitirAvisoNombre ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto>? gastosPrevistos,
  }) async {
    validarProyecto(proyecto, items, gastosPrevistos ?? const []);
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

  Future<Proyecto> _obtenerProyecto(
    DatabaseExecutor transaccion,
    int id,
  ) async {
    final filas = await transaccion.query(
      'proyectos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) {
      throw const FormatException('La cotización ya no existe.');
    }
    return leerProyecto(filas.single);
  }

  void _validarFechaReal(DateTime fecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final valor = DateTime(fecha.year, fecha.month, fecha.day);
    if (valor.isAfter(hoy)) {
      throw const FormatException('La fecha real no puede estar en el futuro.');
    }
  }
}
