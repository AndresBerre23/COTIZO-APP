import 'package:sqflite/sqflite.dart';

import '../dominio/modelos.dart';
import 'mapeadores_sqlite.dart';
import 'utilidades_sqlite.dart';
import 'validaciones_datos.dart';

// Operaciones de la lista de clientes (P-021).
mixin OperacionesClientesSqlite {
  Database get base;

  Future<int> guardarCliente(Cliente cliente) async {
    validarCliente(cliente);
    return base.transaction(
      (transaccion) => guardarRegistro(
        transaccion,
        'clientes',
        cliente.id,
        escribirCliente(cliente),
      ),
    );
  }

  // Las cotizaciones conservan el nombre copiado del cliente.
  Future<void> eliminarCliente(int id) async {
    await base.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }
}
