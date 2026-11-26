import 'package:sqflite/sqflite.dart';

// Fase 3: consumos de material, adicionales y versiones de proforma.
Future<void> migrarV11(DatabaseExecutor base) async {
  // Un consumo es un gasto con detalle de material (P-030).
  const columnasGasto = [
    'material_id INTEGER REFERENCES materiales(id) ON DELETE SET NULL',
    'cantidad REAL CHECK (cantidad IS NULL OR cantidad > 0)',
    'costo_unitario INTEGER CHECK (costo_unitario IS NULL OR costo_unitario >= 0)',
    'nombre_material TEXT',
  ];
  for (final columna in columnasGasto) {
    await base.execute('ALTER TABLE gastos ADD COLUMN $columna');
  }
  await base.execute('''
    CREATE TABLE adicionales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
      descripcion TEXT NOT NULL,
      monto INTEGER NOT NULL CHECK (monto > 0),
      fecha INTEGER NOT NULL
    )
  ''');
  await base.execute(
    'CREATE INDEX indice_adicionales_proyecto ON adicionales(proyecto_id)',
  );
  await base.execute('''
    CREATE TABLE versiones_proforma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
      numero INTEGER NOT NULL CHECK (numero > 0),
      fecha INTEGER NOT NULL,
      contenido TEXT NOT NULL,
      UNIQUE (proyecto_id, numero)
    )
  ''');
}
