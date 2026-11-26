import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:coti/datos/repositorio_sqlite.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:coti/funcionalidades/respaldo/servicios/formato_respaldo.dart';
import 'package:coti/funcionalidades/respaldo/servicios/servicio_respaldo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as rutas;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Gasto _gasto(int monto) => Gasto(
  montoCentavos: monto,
  categoria: 'Otros',
  fecha: DateTime(2026, 11, 25),
);

void main() {
  setUpAll(sqfliteFfiInit);
  late Directory carpeta;
  late ServicioRespaldo servicio;

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('coti_respaldo_');
    servicio = ServicioRespaldo(
      rutaBase: rutas.join(carpeta.path, 'datos', 'cotizo.sqlite'),
      soporte: Directory(rutas.join(carpeta.path, 'soporte')),
    );
  });
  tearDown(() => carpeta.delete(recursive: true));

  Future<RepositorioSqlite> abrir() => RepositorioSqlite.abrir(
    ruta: servicio.rutaBase,
    fabrica: databaseFactoryFfi,
  );

  test('crea y restaura base e imágenes', () async {
    var repositorio = await abrir();
    await repositorio.guardarGasto(_gasto(1500));
    await repositorio.prepararRespaldo();
    final imagen = File(
      rutas.join(servicio.soporte.path, 'imagenes_materiales', 'a.jpg'),
    );
    await imagen.create(recursive: true);
    await imagen.writeAsBytes([1, 2, 3]);
    final zip = await servicio.crear(Directory(rutas.join(carpeta.path, 'z')));

    // Cambios posteriores que la restauración debe revertir.
    await repositorio.guardarGasto(_gasto(999));
    await imagen.delete();
    await repositorio.cerrar();

    final contenido = servicio.leer(await zip.readAsBytes());
    expect(contenido.totalImagenes, 1);
    await servicio.restaurar(contenido);

    repositorio = await abrir();
    final datos = await repositorio.obtenerDatos();
    await repositorio.cerrar();
    expect(datos.gastos.single.montoCentavos, 1500);
    expect(await imagen.readAsBytes(), [1, 2, 3]);
    expect(
      File(
        rutas.join(servicio.soporte.path, 'respaldo_previo.zip'),
      ).existsSync(),
      isTrue,
    );
  });

  test('rechaza archivos que no son respaldos', () {
    expect(() => servicio.leer(utf8.encode('texto')), throwsFormatException);
  });

  test('rechaza respaldos de una versión más nueva', () {
    final bytes = codificarRespaldo(
      base: Uint8List.fromList(ascii.encode('SQLite format 3\u0000')),
      versionEsquema: RepositorioSqlite.versionEsquema + 1,
      archivos: const {},
    );
    expect(() => servicio.leer(bytes), throwsFormatException);
  });

  test('ignora rutas fuera de las carpetas permitidas', () {
    final zip =
        ZipDecoder().decodeBytes(
            codificarRespaldo(
              base: Uint8List.fromList(ascii.encode('SQLite format 3\u0000')),
              versionEsquema: 1,
              archivos: const {},
            ),
          )
          ..addFile(ArchiveFile.bytes('foto_perfil/../../x.jpg', [1]))
          ..addFile(ArchiveFile.bytes('otra/y.jpg', [1]));
    final contenido = servicio.leer(ZipEncoder().encodeBytes(zip));
    expect(contenido.totalImagenes, 0);
  });
}
