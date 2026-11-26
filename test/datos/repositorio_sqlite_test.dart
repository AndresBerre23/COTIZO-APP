import 'dart:io';

import 'package:coti/datos/repositorio_sqlite.dart';
import 'package:coti/dominio/calcular_rentabilidad.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as rutas;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late RepositorioSqlite repositorio;
  late int materialId;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    repositorio = await RepositorioSqlite.abrir(
      ruta: inMemoryDatabasePath,
      fabrica: databaseFactoryFfi,
    );
    materialId = await repositorio.guardarMaterial(
      const MaterialObra(
        nombre: 'Cable',
        unidadMedida: 'm',
        costoBaseCentavos: 125,
      ),
    );
  });
  tearDown(() => repositorio.cerrar());

  test('persiste perfil y preferencias de apariencia', () async {
    const preferencias = PreferenciasApp(
      nombre: 'Ana',
      apellido: 'Pérez',
      fotoRuta: 'foto-perfil.jpg',
      modoTema: ModoTema.oscuro,
      omitirAvisoNombre: true,
    );

    await repositorio.guardarPreferencias(preferencias);
    final guardadas = await repositorio.obtenerPreferencias();

    expect(guardadas.nombre, 'Ana');
    expect(guardadas.apellido, 'Pérez');
    expect(guardadas.fotoRuta, 'foto-perfil.jpg');
    expect(guardadas.modoTema, ModoTema.oscuro);
    expect(guardadas.omitirAvisoNombre, isTrue);
  });

  test(
    'guarda relaciones y conserva precios históricos al editar el catálogo',
    () async {
      final id = await repositorio.guardarProyecto(_proyecto(), [
        _item(materialId),
      ]);
      await repositorio.guardarGasto(_gasto(id, 250));
      await repositorio.guardarGasto(_gasto(null, 1000));
      await repositorio.guardarMaterial(
        MaterialObra(
          id: materialId,
          nombre: 'Cable actualizado',
          unidadMedida: 'rollo',
          costoBaseCentavos: 9999,
        ),
      );
      final datos = await repositorio.obtenerDatos();
      expect(datos.items.single.nombreMaterial, 'Cable');
      expect(datos.items.single.unidadMedida, 'm');
      expect(datos.items.single.costoUnitarioAplicadoCentavos, 125);
      expect(datos.items.single.subtotalCentavos, 313);
      expect(datos.items.single.proyectoId, id);
      expect(datos.materiales.single.costoBaseCentavos, 9999);
      expect(
        calcularRentabilidad(datos.proyectos.single, datos.items, datos.gastos),
        4437,
      );
      expect(() => datos.proyectos.clear(), throwsUnsupportedError);
    },
  );

  test('persiste origen y licencia de la imagen del material', () async {
    const atribucion = AtribucionImagenMaterial(
      titulo: 'Ladrillo cerámico',
      autor: 'Autora de prueba',
      fuenteUrl: 'https://commons.wikimedia.org/wiki/File:Ladrillo.jpg',
      licencia: 'CC BY-SA 4.0',
      licenciaUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    );
    await repositorio.guardarMaterial(
      MaterialObra(
        id: materialId,
        nombre: 'Ladrillo',
        unidadMedida: 'Unidad',
        costoBaseCentavos: 125,
        imagenRuta: 'imagen-guardada.jpg',
        atribucionImagen: atribucion,
      ),
    );

    final material = (await repositorio.obtenerDatos()).materiales.single;
    expect(material.imagenRuta, 'imagen-guardada.jpg');
    expect(material.atribucionImagen?.titulo, atribucion.titulo);
    expect(material.atribucionImagen?.autor, atribucion.autor);
    expect(material.atribucionImagen?.fuenteUrl, atribucion.fuenteUrl);
    expect(material.atribucionImagen?.licencia, atribucion.licencia);
    expect(material.atribucionImagen?.licenciaUrl, atribucion.licenciaUrl);
  });

  test(
    'editar un proyecto preserva sus gastos y sustituye solo el detalle',
    () async {
      final id = await repositorio.guardarProyecto(_proyecto(), [
        _item(materialId),
      ]);
      final gastoId = await repositorio.guardarGasto(_gasto(id, 250));
      await repositorio.guardarProyecto(_proyecto(id: id, total: 8000), [
        _item(materialId, cantidad: 4),
      ]);
      final datos = await repositorio.obtenerDatos();
      expect(datos.proyectos.single.id, id);
      expect(datos.proyectos.single.totalCotizadoCentavos, 8000);
      expect(datos.gastos.single.id, gastoId);
      expect(datos.items.single.cantidad, 4);
    },
  );

  test(
    'persiste gastos previstos sin mezclarlos con gastos registrados',
    () async {
      final proyectoId = await repositorio.guardarProyecto(_proyecto(), []);
      const previsto = GastoPrevisto(
        categoria: 'Transporte de materiales',
        montoCentavos: 2500,
        descripcion: 'Entrega de arena',
      );
      await repositorio.guardarProyecto(
        _proyecto(id: proyectoId),
        [],
        gastosPrevistos: const [previsto],
      );
      await repositorio.guardarGasto(_gasto(proyectoId, 800));

      var datos = await repositorio.obtenerDatos();
      expect(datos.gastosPrevistos.single.montoCentavos, 2500);
      expect(datos.gastos.single.montoCentavos, 800);

      await repositorio.guardarProyecto(_proyecto(id: proyectoId), []);
      datos = await repositorio.obtenerDatos();
      expect(datos.gastosPrevistos.single.descripcion, 'Entrega de arena');

      await repositorio.guardarProyecto(
        _proyecto(id: proyectoId),
        [],
        gastosPrevistos: const [],
      );
      expect((await repositorio.obtenerDatos()).gastosPrevistos, isEmpty);
    },
  );

  test('revierte cabecera y detalle si un material no existe', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), [
      _item(materialId),
    ]);
    await expectLater(
      repositorio.guardarProyecto(_proyecto(id: id, total: 99999), [
        _item(materialId),
        _item(999999),
      ]),
      throwsFormatException,
    );
    await expectLater(
      repositorio.guardarProyecto(_proyecto(), [_item(999999)]),
      throwsFormatException,
    );
    final datos = await repositorio.obtenerDatos();
    expect(datos.proyectos.length, 1);
    expect(datos.proyectos.single.totalCotizadoCentavos, 5000);
    expect(datos.items.length, 1);
    expect(datos.items.single.materialId, materialId);
  });

  test('impide borrar materiales usados y proyectos con dinero', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), [
      _item(materialId),
    ]);
    await repositorio.guardarGasto(_gasto(id, 250));
    await repositorio.guardarGasto(_gasto(null, 1000));
    await expectLater(
      repositorio.eliminarMaterial(materialId),
      throwsFormatException,
    );
    // Con gastos no se elimina; se conserva todo (D-025).
    await expectLater(repositorio.eliminarProyecto(id), throwsFormatException);
    var datos = await repositorio.obtenerDatos();
    expect(datos.proyectos, hasLength(1));
    final gastoDelProyecto = datos.gastos.firstWhere(
      (gasto) => gasto.proyectoId == id,
    );
    expect(gastoDelProyecto.origen, startsWith('COT-'));
    // Sin dinero registrado sí se elimina, con sus partidas.
    await repositorio.eliminarGasto(gastoDelProyecto.id);
    await repositorio.eliminarProyecto(id);
    datos = await repositorio.obtenerDatos();
    expect(datos.proyectos, isEmpty);
    expect(datos.items, isEmpty);
    await repositorio.eliminarMaterial(materialId);
    expect((await repositorio.obtenerDatos()).materiales, isEmpty);
  });

  test('guarda ingresos con su origen y protege su proyecto', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), [
      _item(materialId),
    ]);
    final ingresoId = await repositorio.guardarIngreso(
      Ingreso(
        proyectoId: id,
        montoCentavos: 5000,
        categoria: 'Anticipo',
        metodo: MetodoPago.transferencia,
        fecha: DateTime(2026, 11, 20),
        nota: 'Primer pago',
      ),
    );
    var datos = await repositorio.obtenerDatos();
    expect(datos.ingresos.single.id, ingresoId);
    expect(datos.ingresos.single.metodo, MetodoPago.transferencia);
    expect(datos.ingresosDeProyecto(id).single.montoCentavos, 5000);
    await expectLater(
      repositorio.guardarIngreso(
        Ingreso(montoCentavos: 0, categoria: 'Venta', fecha: DateTime.now()),
      ),
      throwsFormatException,
    );
    await expectLater(repositorio.eliminarProyecto(id), throwsFormatException);
    datos = await repositorio.obtenerDatos();
    expect(datos.ingresos.single.proyectoId, id);
    expect(datos.ingresos.single.origen, contains('Cliente Álvarez'));
    await repositorio.eliminarIngreso(ingresoId);
    expect((await repositorio.obtenerDatos()).ingresos, isEmpty);
  });

  test('guarda cliente, servicios, IVA y estados nuevos', () async {
    final id = await repositorio.guardarProyecto(
      Proyecto(
        nombreCliente: 'Ana Ruiz',
        descripcion: 'Instalación',
        fechaInicio: DateTime(2026, 11, 25),
        fechaFin: DateTime(2026, 11, 30),
        fechaCreacion: DateTime(2026, 11, 25, 9),
        totalCotizadoCentavos: 10000,
        ivaPuntos: 1500,
        validezDias: 30,
        formaPago: 'Contado',
        condiciones: 'Garantía de 6 meses',
      ),
      [
        _item(materialId),
        const ItemProyecto(
          esServicio: true,
          cantidad: 1,
          costoUnitarioAplicadoCentavos: 3000,
          nombreMaterial: 'Instalación',
          unidadMedida: 'servicio',
        ),
      ],
      cliente: const Cliente(nombre: 'Ana Ruiz', telefono: '0999999999'),
    );
    var datos = await repositorio.obtenerDatos();
    final proyecto = datos.proyectos.single;
    expect(datos.clientes.single.telefono, '0999999999');
    expect(proyecto.clienteId, datos.clientes.single.id);
    expect(proyecto.ivaPuntos, 1500);
    expect(proyecto.validezDias, 30);
    expect(proyecto.condiciones, 'Garantía de 6 meses');
    expect(proyecto.fechaCreacion, DateTime(2026, 11, 25, 9));
    final servicio = datos.items.firstWhere((item) => item.esServicio);
    expect(servicio.materialId, isNull);
    await repositorio.guardarProyecto(
      proyecto.conEstado(EstadoProyecto.rechazado),
      datos.itemsDeProyecto(id),
    );
    datos = await repositorio.obtenerDatos();
    expect(datos.proyectos.single.estado, EstadoProyecto.rechazado);
    expect(datos.proyectos.single.clienteId, isNotNull);
    await repositorio.eliminarCliente(datos.clientes.single.id);
    datos = await repositorio.obtenerDatos();
    expect(datos.proyectos.single.clienteId, isNull);
    expect(datos.proyectos.single.nombreCliente, 'Ana Ruiz');
  });

  test('persiste datos del negocio y ajustes de cotización', () async {
    await repositorio.guardarPreferencias(
      const PreferenciasApp(
        negocio: DatosNegocio(
          nombreComercial: 'Taller Ruiz',
          identificacion: '1799',
        ),
        ivaPuntos: null,
        margenPuntos: 3500,
        validezDias: 8,
        formaPago: 'Transferencia',
      ),
    );
    final leidas = await repositorio.obtenerPreferencias();
    expect(leidas.nombreEmisor, 'Taller Ruiz');
    expect(leidas.negocio.identificacion, '1799');
    expect(leidas.ivaPuntos, isNull);
    expect(leidas.margenPuntos, 3500);
    expect(leidas.validezDias, 8);
    expect(leidas.formaPago, 'Transferencia');
  });

  test('guarda consumos de material y adicionales de una obra', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), [
      _item(materialId),
    ]);
    await repositorio.guardarGasto(
      Gasto(
        proyectoId: id,
        montoCentavos: 375,
        categoria: Gasto.categoriaConsumo,
        fecha: DateTime(2026, 11, 20),
        materialId: materialId,
        cantidad: 3,
        costoUnitarioCentavos: 125,
        nombreMaterial: 'Cable',
      ),
    );
    final adicionalId = await repositorio.guardarAdicional(
      Adicional(
        proyectoId: id,
        descripcion: 'Punto extra',
        montoCentavos: 2000,
        fecha: DateTime(2026, 11, 21),
      ),
    );
    var datos = await repositorio.obtenerDatos();
    final consumo = datos.gastos.single;
    expect(consumo.esConsumo, isTrue);
    expect(consumo.cantidad, 3);
    expect(consumo.materialId, materialId);
    expect(datos.adicionalesDeProyecto(id).single.montoCentavos, 2000);
    await repositorio.eliminarAdicional(adicionalId);
    datos = await repositorio.obtenerDatos();
    expect(datos.adicionales, isEmpty);
  });

  test('versiona la proforma enviada solo si cambia lo comercial', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), [
      _item(materialId),
    ]);
    // En borrador, editar no crea versiones.
    await repositorio.guardarProyecto(_proyecto(id: id, total: 6000), [
      _item(materialId),
    ]);
    var datos = await repositorio.obtenerDatos();
    expect(datos.versiones, isEmpty);
    final enviado = datos.proyectos.single.conEstado(EstadoProyecto.enviado);
    await repositorio.guardarProyecto(enviado, datos.itemsDeProyecto(id));
    datos = await repositorio.obtenerDatos();
    // Cambiar solo el estado tampoco crea versiones.
    expect(datos.versiones, isEmpty);
    await repositorio.guardarProyecto(
      _proyecto(id: id, total: 9000).conEstado(EstadoProyecto.enviado),
      [_item(materialId, cantidad: 4)],
    );
    datos = await repositorio.obtenerDatos();
    final version = datos.versionesDeProyecto(id).single;
    expect(version.numero, 1);
    expect(version.proyecto.totalCotizadoCentavos, 6000);
    expect(version.items.single.cantidad, 2.5);
    expect(datos.proyectos.single.totalCotizadoCentavos, 9000);
  });

  test('guarda fotos de obra y las borra con su proyecto sin dinero', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), []);
    final fotoId = await repositorio.guardarFoto(
      FotoObra(
        proyectoId: id,
        ruta: 'a.jpg',
        miniatura: 'a-m.jpg',
        fecha: DateTime(2026, 11, 25, 10),
      ),
    );
    var datos = await repositorio.obtenerDatos();
    expect(datos.fotosDeProyecto(id).single.ruta, 'a.jpg');
    await repositorio.guardarFoto(datos.fotos.single.conNota('Acabado final'));
    datos = await repositorio.obtenerDatos();
    expect(datos.fotos.single.id, fotoId);
    expect(datos.fotos.single.nota, 'Acabado final');
    await repositorio.eliminarProyecto(id);
    expect((await repositorio.obtenerDatos()).fotos, isEmpty);
  });

  test('edita y elimina gastos sin duplicarlos', () async {
    final id = await repositorio.guardarGasto(_gasto(null, 1000));
    await repositorio.guardarGasto(
      Gasto(
        id: id,
        montoCentavos: 300,
        categoria: 'Alimentación',
        fecha: DateTime(2026, 11, 6),
        nota: 'Corregido',
      ),
    );
    expect((await repositorio.obtenerDatos()).gastos.single.montoCentavos, 300);
    await repositorio.eliminarGasto(id);
    expect((await repositorio.obtenerDatos()).gastos, isEmpty);
  });

  test('rechaza cantidades inválidas y gastos huérfanos', () async {
    for (final cantidad in [
      0.0,
      -1.0,
      0.0001,
      1.0001,
      double.nan,
      double.infinity,
    ]) {
      await expectLater(
        repositorio.guardarProyecto(_proyecto(), [
          _item(materialId, cantidad: cantidad),
        ]),
        throwsFormatException,
      );
    }
    await expectLater(
      repositorio.guardarGasto(_gasto(9999, 200)),
      throwsFormatException,
    );
    await expectLater(
      repositorio.guardarGasto(_gasto(null, 0)),
      throwsFormatException,
    );
    expect((await repositorio.obtenerDatos()).proyectos, isEmpty);
  });

  test('mantiene los datos al cerrar y abrir un archivo SQLite', () async {
    final carpeta = await Directory.systemTemp.createTemp('cotizo_sqlite_');
    final ruta = rutas.join(carpeta.path, 'persistencia.sqlite');
    RepositorioSqlite? local;
    try {
      local = await RepositorioSqlite.abrir(
        ruta: ruta,
        fabrica: databaseFactoryFfi,
      );
      final id = await local.guardarProyecto(_proyecto(), []);
      await local.guardarGasto(_gasto(id, 200));
      await local.cerrar();
      local = await RepositorioSqlite.abrir(
        ruta: ruta,
        fabrica: databaseFactoryFfi,
      );
      final datos = await local.obtenerDatos();
      expect(datos.proyectos.single.id, id);
      expect(datos.proyectos.single.nombreCliente, 'Cliente Álvarez');
      expect(datos.gastos.single.proyectoId, id);
    } finally {
      await local?.cerrar();
      await databaseFactoryFfi.deleteDatabase(ruta);
      await carpeta.delete();
    }
  });

  test('inicia y finaliza una obra sin reemplazar sus partidas', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), [
      _item(materialId),
    ]);
    await repositorio.iniciarObra(id, DateTime(2026, 11, 6));
    var datos = await repositorio.obtenerDatos();
    expect(datos.proyectos.single.estado, EstadoProyecto.aprobado);
    expect(datos.proyectos.single.fechaInicioReal, DateTime(2026, 11, 6));
    expect(datos.proyectos.single.estaEnCurso, isTrue);
    expect(datos.items.single.materialId, materialId);

    await repositorio.finalizarObra(id, DateTime(2026, 11, 7));
    datos = await repositorio.obtenerDatos();
    expect(datos.proyectos.single.estado, EstadoProyecto.finalizado);
    expect(datos.proyectos.single.fechaFinReal, DateTime(2026, 11, 7));
    expect(datos.proyectos.single.fechaFin, DateTime(2026, 11, 15));
    expect(datos.items, hasLength(1));
  });

  test('rechaza transiciones y fechas reales inválidas', () async {
    final id = await repositorio.guardarProyecto(_proyecto(), []);
    await expectLater(
      repositorio.finalizarObra(id, DateTime(2026, 11, 6)),
      throwsFormatException,
    );
    await expectLater(
      repositorio.iniciarObra(id, DateTime.now().add(const Duration(days: 2))),
      throwsFormatException,
    );
    await repositorio.iniciarObra(id, DateTime(2026, 11, 6));
    await expectLater(
      repositorio.iniciarObra(id, DateTime(2026, 11, 6)),
      throwsFormatException,
    );
    await expectLater(
      repositorio.finalizarObra(id, DateTime(2026, 11, 5)),
      throwsFormatException,
    );
  });

  test(
    'exige fecha final prevista antes de iniciar una cotización histórica',
    () async {
      final id = await repositorio.guardarProyecto(_proyecto(), []);
      await repositorio.base.update(
        'proyectos',
        {'fecha_fin': null},
        where: 'id = ?',
        whereArgs: [id],
      );
      await expectLater(
        repositorio.iniciarObra(id, DateTime(2026, 11, 6)),
        throwsFormatException,
      );
      final proyecto = (await repositorio.obtenerDatos()).proyectos.single;
      expect(proyecto.fechaFin, isNull);
      expect(proyecto.fechaInicioReal, isNull);
    },
  );

  test('migra una base v1 sin perder relaciones ni inventar fechas', () async {
    final carpeta = await Directory.systemTemp.createTemp('cotizo_migracion_');
    final ruta = rutas.join(carpeta.path, 'version1.sqlite');
    RepositorioSqlite? local;
    try {
      final antigua = await databaseFactoryFfi.openDatabase(
        ruta,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (base, _) => _crearEsquemaVersion1(base),
        ),
      );
      await antigua.insert('proyectos', {
        'id': 7,
        'nombre_cliente': 'Cliente histórico',
        'descripcion': 'Trabajo conservado',
        'fecha_inicio': DateTime(2025, 1, 1).millisecondsSinceEpoch,
        'fecha_fin': DateTime(2025, 1, 10).millisecondsSinceEpoch,
        'estado': 'finalizado',
        'total_cotizado': 5000,
      });
      await antigua.insert('materiales', {
        'id': 3,
        'nombre': 'Cable',
        'unidad_medida': 'm',
        'costo_base': 100,
      });
      await antigua.insert('items_proyecto', {
        'proyecto_id': 7,
        'material_id': 3,
        'cantidad': 2.0,
        'costo_unitario_aplicado': 100,
        'subtotal': 200,
        'nombre_material': 'Cable',
        'unidad_medida': 'm',
      });
      await antigua.insert('gastos', {
        'proyecto_id': 7,
        'monto': 50,
        'categoria': 'Transporte',
        'fecha': DateTime(2025, 1, 2).millisecondsSinceEpoch,
        'nota': '',
      });
      await antigua.close();

      local = await RepositorioSqlite.abrir(
        ruta: ruta,
        fabrica: databaseFactoryFfi,
      );
      final datos = await local.obtenerDatos();
      expect(datos.proyectos.single.id, 7);
      expect(datos.proyectos.single.fechaInicioReal, isNull);
      expect(datos.proyectos.single.fechaFinReal, isNull);
      expect(datos.proyectos.single.esObra, isTrue);
      expect(datos.items.single.proyectoId, 7);
      expect(datos.gastos.single.proyectoId, 7);
      expect(datos.materiales.single.imagenRuta, isNull);
      expect(datos.materiales.single.atribucionImagen, isNull);

      // La migración v13 guarda el origen de los gastos existentes.
      expect(
        datos.gastos.single.origen,
        startsWith('COT-0007 · Cliente histórico'),
      );
      await expectLater(local.eliminarProyecto(7), throwsFormatException);
    } finally {
      await local?.cerrar();
      await databaseFactoryFfi.deleteDatabase(ruta);
      await carpeta.delete();
    }
  });
}

Future<void> _crearEsquemaVersion1(Database base) async {
  await base.execute('''
    CREATE TABLE proyectos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre_cliente TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      fecha_inicio INTEGER NOT NULL,
      fecha_fin INTEGER,
      estado TEXT NOT NULL,
      total_cotizado INTEGER NOT NULL
    )
  ''');
  await base.execute('''
    CREATE TABLE materiales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      unidad_medida TEXT NOT NULL,
      costo_base INTEGER NOT NULL
    )
  ''');
  await base.execute('''
    CREATE TABLE items_proyecto (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materiales(id) ON DELETE RESTRICT,
      cantidad REAL NOT NULL,
      costo_unitario_aplicado INTEGER NOT NULL,
      subtotal INTEGER NOT NULL,
      nombre_material TEXT NOT NULL,
      unidad_medida TEXT NOT NULL
    )
  ''');
  await base.execute('''
    CREATE TABLE gastos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto_id INTEGER REFERENCES proyectos(id) ON DELETE CASCADE,
      monto INTEGER NOT NULL,
      categoria TEXT NOT NULL,
      fecha INTEGER NOT NULL,
      nota TEXT NOT NULL
    )
  ''');
}

Proyecto _proyecto({int id = 0, int total = 5000}) => Proyecto(
  id: id,
  nombreCliente: 'Cliente Álvarez',
  descripcion: 'Instalación eléctrica',
  fechaInicio: DateTime(2026, 11, 5),
  fechaFin: DateTime(2026, 11, 15),
  totalCotizadoCentavos: total,
);

ItemProyecto _item(int materialId, {double cantidad = 2.5}) => ItemProyecto(
  materialId: materialId,
  cantidad: cantidad,
  costoUnitarioAplicadoCentavos: 125,
  nombreMaterial: 'Cable',
  unidadMedida: 'm',
);

Gasto _gasto(int? proyectoId, int monto) => Gasto(
  proyectoId: proyectoId,
  montoCentavos: monto,
  categoria: 'Transporte',
  fecha: DateTime(2026, 11, 5),
);
