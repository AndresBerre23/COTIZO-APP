import 'package:sqflite/sqflite.dart';

import 'migracion_v10.dart';
import 'migracion_v11.dart';
import 'migracion_v13.dart';

Future<void> crearEsquema(Database base, int version) async {
  await _crearTablaPreferencias(base);
  await base.execute('''
    CREATE TABLE proyectos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre_cliente TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      fecha_inicio INTEGER NOT NULL,
      fecha_fin INTEGER,
      fecha_inicio_real INTEGER,
      fecha_fin_real INTEGER,
      estado TEXT NOT NULL CHECK (
        estado IN ('borrador', 'enviado', 'aprobado', 'finalizado')
      ),
      total_cotizado INTEGER NOT NULL CHECK (total_cotizado >= 0),
      margen_deseado_puntos INTEGER,
      cobro_mano_obra INTEGER NOT NULL DEFAULT 0 CHECK (cobro_mano_obra >= 0),
      CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
    )
  ''');
  await base.execute('''
    CREATE TABLE materiales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      unidad_medida TEXT NOT NULL,
      costo_base INTEGER NOT NULL CHECK (costo_base >= 0),
      imagen_ruta TEXT,
      atribucion_titulo TEXT,
      atribucion_autor TEXT,
      atribucion_fuente TEXT,
      atribucion_licencia TEXT,
      atribucion_licencia_url TEXT
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
      proyecto_id INTEGER REFERENCES proyectos(id) ON DELETE SET NULL,
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
  await base.execute('''
    CREATE TABLE gastos_previstos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
      categoria TEXT NOT NULL,
      monto INTEGER NOT NULL CHECK (monto > 0),
      descripcion TEXT NOT NULL
    )
  ''');
  await base.execute(
    'CREATE INDEX indice_gastos_previstos_proyecto ON gastos_previstos(proyecto_id)',
  );
  await _crearTablaIngresos(base);
  // Las instalaciones nuevas recorren el mismo paso que las migradas.
  await migrarV10(base);
  await migrarV11(base);
  await _migrarV12(base);
  await migrarV13(base);
}

Future<void> migrarEsquema(
  Database base,
  int versionAnterior,
  int versionNueva,
) async {
  if (versionAnterior < 2) {
    await base.execute(
      'ALTER TABLE proyectos ADD COLUMN fecha_inicio_real INTEGER',
    );
    await base.execute(
      'ALTER TABLE proyectos ADD COLUMN fecha_fin_real INTEGER',
    );
  }
  if (versionAnterior < 3) {
    await base.execute('''
      CREATE TABLE gastos_previstos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
        categoria TEXT NOT NULL,
        monto INTEGER NOT NULL CHECK (monto > 0),
        descripcion TEXT NOT NULL
      )
    ''');
    await base.execute(
      'CREATE INDEX indice_gastos_previstos_proyecto ON gastos_previstos(proyecto_id)',
    );
    await base.execute(
      'ALTER TABLE proyectos ADD COLUMN margen_deseado_puntos INTEGER',
    );
  }
  if (versionAnterior < 4) {
    await base.execute('ALTER TABLE materiales ADD COLUMN imagen_ruta TEXT');
  }
  if (versionAnterior < 5) {
    await base.execute(
      'ALTER TABLE materiales ADD COLUMN atribucion_titulo TEXT',
    );
    await base.execute(
      'ALTER TABLE materiales ADD COLUMN atribucion_autor TEXT',
    );
    await base.execute(
      'ALTER TABLE materiales ADD COLUMN atribucion_fuente TEXT',
    );
    await base.execute(
      'ALTER TABLE materiales ADD COLUMN atribucion_licencia TEXT',
    );
    await base.execute(
      'ALTER TABLE materiales ADD COLUMN atribucion_licencia_url TEXT',
    );
  }
  if (versionAnterior < 6) {
    await base.execute(
      'ALTER TABLE proyectos ADD COLUMN cobro_mano_obra INTEGER NOT NULL DEFAULT 0 CHECK (cobro_mano_obra >= 0)',
    );
  }
  if (versionAnterior < 7) await _crearTablaPreferencias(base);
  if (versionAnterior < 8) await _conservarGastosAlEliminar(base);
  if (versionAnterior < 9) await _crearTablaIngresos(base);
  if (versionAnterior < 10) await migrarV10(base);
  if (versionAnterior < 11) await migrarV11(base);
  if (versionAnterior < 12) await _migrarV12(base);
  if (versionAnterior < 13) await migrarV13(base);
}

// Marca del tutorial de bienvenida.
Future<void> _migrarV12(DatabaseExecutor base) => base.execute(
  'ALTER TABLE preferencias_app ADD COLUMN tutorial_visto INTEGER NOT NULL '
  'DEFAULT 0 CHECK (tutorial_visto IN (0, 1))',
);

// Cobros y otros ingresos (P-010).
Future<void> _crearTablaIngresos(DatabaseExecutor base) async {
  await base.execute('''
    CREATE TABLE ingresos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER REFERENCES proyectos(id) ON DELETE SET NULL,
      monto INTEGER NOT NULL CHECK (monto > 0),
      categoria TEXT NOT NULL,
      metodo TEXT NOT NULL CHECK (
        metodo IN ('efectivo', 'transferencia', 'tarjeta', 'otro')
      ),
      fecha INTEGER NOT NULL,
      nota TEXT NOT NULL
    )
  ''');
  await base.execute(
    'CREATE INDEX indice_ingresos_proyecto ON ingresos(proyecto_id)',
  );
  await base.execute('CREATE INDEX indice_ingresos_fecha ON ingresos(fecha)');
}

// SQLite no permite cambiar una clave foránea: se recrea la tabla (D-010).
Future<void> _conservarGastosAlEliminar(DatabaseExecutor base) async {
  await base.execute('''
    CREATE TABLE gastos_v8 (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER REFERENCES proyectos(id) ON DELETE SET NULL,
      monto INTEGER NOT NULL CHECK (monto > 0),
      categoria TEXT NOT NULL,
      fecha INTEGER NOT NULL,
      nota TEXT NOT NULL
    )
  ''');
  await base.execute('''
    INSERT INTO gastos_v8 (id, proyecto_id, monto, categoria, fecha, nota)
    SELECT id, proyecto_id, monto, categoria, fecha, nota FROM gastos
  ''');
  await base.execute('DROP TABLE gastos');
  await base.execute('ALTER TABLE gastos_v8 RENAME TO gastos');
  await base.execute(
    'CREATE INDEX indice_gastos_proyecto ON gastos(proyecto_id)',
  );
  await base.execute('CREATE INDEX indice_gastos_fecha ON gastos(fecha)');
}

Future<void> _crearTablaPreferencias(DatabaseExecutor base) => base.execute('''
  CREATE TABLE preferencias_app (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    nombre TEXT NOT NULL DEFAULT '',
    apellido TEXT NOT NULL DEFAULT '',
    foto_ruta TEXT,
    modo_tema TEXT NOT NULL DEFAULT 'sistema' CHECK (
      modo_tema IN ('sistema', 'claro', 'oscuro')
    ),
    omitir_aviso_nombre INTEGER NOT NULL DEFAULT 0 CHECK (
      omitir_aviso_nombre IN (0, 1)
    )
  )
''');
