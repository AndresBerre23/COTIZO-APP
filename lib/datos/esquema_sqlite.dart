import 'package:sqflite/sqflite.dart';

Future<void> crearEsquema(Database base, int version) async {
  await base.execute('''
    CREATE TABLE proyectos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre_cliente TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      fecha_inicio INTEGER NOT NULL,
      fecha_fin INTEGER,
      estado TEXT NOT NULL CHECK (
        estado IN ('borrador', 'enviado', 'aprobado', 'finalizado')
      ),
      total_cotizado INTEGER NOT NULL CHECK (total_cotizado >= 0),
      CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
    )
  ''');
  await base.execute('''
    CREATE TABLE materiales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      unidad_medida TEXT NOT NULL,
      costo_base INTEGER NOT NULL CHECK (costo_base >= 0)
    )
  ''');
  await base.execute('''
    CREATE TABLE items_proyecto (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materiales(id) ON DELETE RESTRICT,
      cantidad REAL NOT NULL CHECK (cantidad > 0),
      costo_unitario_aplicado INTEGER NOT NULL CHECK (costo_unitario_aplicado >= 0),
      subtotal INTEGER NOT NULL CHECK (subtotal >= 0),
      nombre_material TEXT NOT NULL,
      unidad_medida TEXT NOT NULL
    )
  ''');
  await base.execute('''
    CREATE TABLE gastos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER REFERENCES proyectos(id) ON DELETE CASCADE,
      monto INTEGER NOT NULL CHECK (monto > 0),
      categoria TEXT NOT NULL,
      fecha INTEGER NOT NULL,
      nota TEXT NOT NULL
    )
  ''');
  await base.execute(
    'CREATE INDEX indice_items_proyecto ON items_proyecto(proyecto_id)',
  );
  await base.execute(
    'CREATE INDEX indice_items_material ON items_proyecto(material_id)',
  );
  await base.execute(
    'CREATE INDEX indice_gastos_proyecto ON gastos(proyecto_id)',
  );
  await base.execute('CREATE INDEX indice_gastos_fecha ON gastos(fecha)');
}
