import 'package:sqflite/sqflite.dart';

// Origen de cada movimiento, fotos de obra y bloqueo de la app.
Future<void> migrarV13(DatabaseExecutor base) async {
  await base.execute(
    'ALTER TABLE preferencias_app ADD COLUMN bloqueo_activo INTEGER NOT NULL '
    'DEFAULT 0 CHECK (bloqueo_activo IN (0, 1))',
  );
  // Copia legible del proyecto de un movimiento, para no perder su contexto.
  await base.execute('ALTER TABLE gastos ADD COLUMN origen TEXT');
  await base.execute('ALTER TABLE ingresos ADD COLUMN origen TEXT');
  await base.execute('''
    UPDATE gastos SET origen = (
      SELECT printf('COT-%04d · %s · %s', p.id, p.nombre_cliente, p.descripcion)
      FROM proyectos p WHERE p.id = gastos.proyecto_id
    ) WHERE proyecto_id IS NOT NULL
  ''');
  await base.execute('''
    UPDATE ingresos SET origen = (
      SELECT printf('COT-%04d · %s · %s', p.id, p.nombre_cliente, p.descripcion)
      FROM proyectos p WHERE p.id = ingresos.proyecto_id
    ) WHERE proyecto_id IS NOT NULL
  ''');
  await base.execute('''
    CREATE TABLE fotos_obra (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
      ruta TEXT NOT NULL,
      miniatura TEXT NOT NULL,
      fecha INTEGER NOT NULL,
      nota TEXT NOT NULL DEFAULT ''
    )
  ''');
  await base.execute(
    'CREATE INDEX indice_fotos_proyecto ON fotos_obra(proyecto_id, fecha)',
  );
}
