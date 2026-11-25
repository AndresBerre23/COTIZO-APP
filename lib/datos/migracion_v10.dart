import 'package:sqflite/sqflite.dart';

// Fase 2: clientes, datos de proforma, estados nuevos y partidas de servicio.
// Requiere las claves foráneas desactivadas: recrea tablas referenciadas.
Future<void> migrarV10(DatabaseExecutor base) async {
  await base.execute('''
    CREATE TABLE clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      identificacion TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      correo TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT ''
    )
  ''');
  await _recrearProyectos(base);
  await _recrearItems(base);
  await _ampliarPreferencias(base);
}

Future<void> _recrearProyectos(DatabaseExecutor base) async {
  await base.execute('''
    CREATE TABLE proyectos_v10 (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre_cliente TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      fecha_inicio INTEGER NOT NULL,
      fecha_fin INTEGER,
      fecha_inicio_real INTEGER,
      fecha_fin_real INTEGER,
      estado TEXT NOT NULL CHECK (
        estado IN (
          'borrador', 'enviado', 'aprobado', 'finalizado',
          'rechazado', 'cancelado'
        )
      ),
      total_cotizado INTEGER NOT NULL CHECK (total_cotizado >= 0),
      margen_deseado_puntos INTEGER,
      cobro_mano_obra INTEGER NOT NULL DEFAULT 0 CHECK (cobro_mano_obra >= 0),
      fecha_creacion INTEGER NOT NULL,
      cliente_id INTEGER REFERENCES clientes(id) ON DELETE SET NULL,
      iva_puntos INTEGER CHECK (
        iva_puntos IS NULL OR iva_puntos BETWEEN 0 AND 10000
      ),
      validez_dias INTEGER NOT NULL DEFAULT 15 CHECK (
        validez_dias BETWEEN 1 AND 365
      ),
      forma_pago TEXT NOT NULL DEFAULT '',
      condiciones TEXT NOT NULL DEFAULT '',
      CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
    )
  ''');
  // Las cotizaciones previas no tenían IVA: se conservan sus totales.
  await base.execute('''
    INSERT INTO proyectos_v10 (
      id, nombre_cliente, descripcion, fecha_inicio, fecha_fin,
      fecha_inicio_real, fecha_fin_real, estado, total_cotizado,
      margen_deseado_puntos, cobro_mano_obra, fecha_creacion
    )
    SELECT id, nombre_cliente, descripcion, fecha_inicio, fecha_fin,
      fecha_inicio_real, fecha_fin_real, estado, total_cotizado,
      margen_deseado_puntos, cobro_mano_obra, fecha_inicio
    FROM proyectos
  ''');
  await base.execute('DROP TABLE proyectos');
  await base.execute('ALTER TABLE proyectos_v10 RENAME TO proyectos');
  await base.execute(
    'CREATE INDEX indice_proyectos_cliente ON proyectos(cliente_id)',
  );
}

Future<void> _recrearItems(DatabaseExecutor base) async {
  await base.execute('''
    CREATE TABLE items_v10 (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
      material_id INTEGER REFERENCES materiales(id) ON DELETE RESTRICT,
      es_servicio INTEGER NOT NULL DEFAULT 0 CHECK (es_servicio IN (0, 1)),
      cantidad REAL NOT NULL CHECK (cantidad > 0),
      costo_unitario_aplicado INTEGER NOT NULL CHECK (costo_unitario_aplicado >= 0),
      subtotal INTEGER NOT NULL CHECK (subtotal >= 0),
      nombre_material TEXT NOT NULL,
      unidad_medida TEXT NOT NULL,
      CHECK (es_servicio = 1 OR material_id IS NOT NULL)
    )
  ''');
  await base.execute('''
    INSERT INTO items_v10 (
      id, proyecto_id, material_id, cantidad, costo_unitario_aplicado,
      subtotal, nombre_material, unidad_medida
    )
    SELECT id, proyecto_id, material_id, cantidad, costo_unitario_aplicado,
      subtotal, nombre_material, unidad_medida
    FROM items_proyecto
  ''');
  await base.execute('DROP TABLE items_proyecto');
  await base.execute('ALTER TABLE items_v10 RENAME TO items_proyecto');
  await base.execute(
    'CREATE INDEX indice_items_proyecto ON items_proyecto(proyecto_id)',
  );
  await base.execute(
    'CREATE INDEX indice_items_material ON items_proyecto(material_id)',
  );
}

Future<void> _ampliarPreferencias(DatabaseExecutor base) async {
  const columnas = [
    "nombre_comercial TEXT NOT NULL DEFAULT ''",
    "identificacion TEXT NOT NULL DEFAULT ''",
    "telefono TEXT NOT NULL DEFAULT ''",
    "correo TEXT NOT NULL DEFAULT ''",
    "direccion TEXT NOT NULL DEFAULT ''",
    'logo_ruta TEXT',
    'iva_puntos INTEGER DEFAULT 1500',
    'margen_puntos INTEGER NOT NULL DEFAULT 2000',
    'validez_dias INTEGER NOT NULL DEFAULT 15',
    "forma_pago TEXT NOT NULL DEFAULT ''",
    "condiciones TEXT NOT NULL DEFAULT ''",
  ];
  for (final columna in columnas) {
    await base.execute('ALTER TABLE preferencias_app ADD COLUMN $columna');
  }
}
