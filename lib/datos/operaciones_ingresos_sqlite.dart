import 'package:sqflite/sqflite.dart';

import '../dominio/modelos.dart';
import 'mapeadores_sqlite.dart';
import 'operaciones_fotos_sqlite.dart';
import 'utilidades_sqlite.dart';
import 'validaciones_datos.dart';

// Operaciones de ingresos, separadas para no agrandar el repositorio (P-010).
mixin OperacionesIngresosSqlite {
  Database get base;

  Future<int> guardarIngreso(Ingreso ingreso) async {
    validarIngreso(ingreso);
    return base.transaction((transaccion) async {
      if (ingreso.proyectoId != null) {
        await exigirRegistro(transaccion, 'proyectos', ingreso.proyectoId!);
      }
      return guardarRegistro(transaccion, 'ingresos', ingreso.id, {
        ...escribirIngreso(ingreso),
        'origen': await origenDeProyecto(transaccion, ingreso.proyectoId),
      });
    });
  }

  Future<void> eliminarIngreso(int id) async {
    await base.delete('ingresos', where: 'id = ?', whereArgs: [id]);
  }
}
