import 'package:sqflite/sqflite.dart';

import '../dominio/modelos.dart';
import 'mapeadores_sqlite.dart';
import 'utilidades_sqlite.dart';
import 'validaciones_datos.dart';

// Ciclo de obra y adicionales (P-031), separados del repositorio principal.
mixin OperacionesObraSqlite {
  Database get base;

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

  Future<int> guardarAdicional(Adicional adicional) async {
    validarAdicional(adicional);
    return base.transaction((transaccion) async {
      await exigirRegistro(transaccion, 'proyectos', adicional.proyectoId);
      return guardarRegistro(
        transaccion,
        'adicionales',
        adicional.id,
        escribirAdicional(adicional),
      );
    });
  }

  Future<void> eliminarAdicional(int id) async {
    await base.delete('adicionales', where: 'id = ?', whereArgs: [id]);
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
