import 'package:sqflite/sqflite.dart';

// Inserta si el id es 0; si no, actualiza y exige que el registro exista.
Future<int> guardarRegistro(
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

Future<void> exigirRegistro(
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
