import 'package:sqflite/sqflite.dart';

import '../dominio/modelos.dart';
import 'utilidades_sqlite.dart';

// Fotos de obra; los archivos los maneja el almacén de imágenes.
mixin OperacionesFotosSqlite {
  Database get base;

  Future<int> guardarFoto(FotoObra foto) async {
    if (foto.nota.length > 500) {
      throw const FormatException('La nota admite hasta 500 caracteres.');
    }
    return base.transaction((transaccion) async {
      await exigirRegistro(transaccion, 'proyectos', foto.proyectoId);
      return guardarRegistro(transaccion, 'fotos_obra', foto.id, {
        'proyecto_id': foto.proyectoId,
        'ruta': foto.ruta,
        'miniatura': foto.miniatura,
        'fecha': foto.fecha.millisecondsSinceEpoch,
        'nota': foto.nota.trim(),
      });
    });
  }

  Future<void> eliminarFoto(int id) async {
    await base.delete('fotos_obra', where: 'id = ?', whereArgs: [id]);
  }
}

FotoObra leerFoto(Map<String, Object?> fila) => FotoObra(
  id: fila['id'] as int,
  proyectoId: fila['proyecto_id'] as int,
  ruta: fila['ruta'] as String,
  miniatura: fila['miniatura'] as String,
  fecha: DateTime.fromMillisecondsSinceEpoch(fila['fecha'] as int),
  nota: fila['nota'] as String,
);

// Texto que identifica al proyecto de un movimiento aunque luego se borre.
Future<String?> origenDeProyecto(
  DatabaseExecutor transaccion,
  int? proyectoId,
) async {
  if (proyectoId == null) return null;
  final filas = await transaccion.query(
    'proyectos',
    columns: ['id', 'nombre_cliente', 'descripcion'],
    where: 'id = ?',
    whereArgs: [proyectoId],
  );
  if (filas.isEmpty) return null;
  final fila = filas.single;
  final codigo = 'COT-${(fila['id'] as int).toString().padLeft(4, '0')}';
  return '$codigo · ${fila['nombre_cliente']} · ${fila['descripcion']}';
}
