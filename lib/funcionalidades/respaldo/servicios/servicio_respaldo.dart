import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as rutas;
import 'package:path_provider/path_provider.dart';

import '../../../datos/repositorio_sqlite.dart';
import 'formato_respaldo.dart';

// Crea y restaura respaldos .zip con la base de datos y las imágenes.
class ServicioRespaldo {
  const ServicioRespaldo({
    required this.rutaBase,
    required this.soporte,
    this.versionEsquema = RepositorioSqlite.versionEsquema,
  });

  final String rutaBase;
  final Directory soporte;
  final int versionEsquema;

  static Future<ServicioRespaldo> predeterminado() async => ServicioRespaldo(
    rutaBase: await RepositorioSqlite.rutaPredeterminada(),
    soporte: await getApplicationSupportDirectory(),
  );

  // La base debe estar consolidada o cerrada antes de llamar.
  Future<File> crear(Directory destino, {DateTime? ahora}) async {
    final fecha = ahora ?? DateTime.now();
    final bytes = codificarRespaldo(
      base: await File(rutaBase).readAsBytes(),
      versionEsquema: versionEsquema,
      archivos: await _leerCarpetas(),
      creado: fecha,
    );
    await destino.create(recursive: true);
    final archivo = File(
      rutas.join(destino.path, 'coti-respaldo-${_marca(fecha)}.zip'),
    );
    return archivo.writeAsBytes(bytes, flush: true);
  }

  ContenidoRespaldo leer(List<int> bytes) =>
      decodificarRespaldo(bytes, versionEsquemaActual: versionEsquema);

  // Requiere la base cerrada. Guarda antes una copia de los datos actuales.
  Future<void> restaurar(ContenidoRespaldo contenido) async {
    if (await File(rutaBase).exists()) {
      final previo = await crear(Directory(rutas.join(soporte.path, 'previo')));
      final destino = File(rutas.join(soporte.path, 'respaldo_previo.zip'));
      if (await destino.exists()) await destino.delete();
      await previo.rename(destino.path);
    }
    for (final sufijo in ['', '-wal', '-shm', '-journal']) {
      final archivo = File('$rutaBase$sufijo');
      if (await archivo.exists()) await archivo.delete();
    }
    await File(rutaBase).parent.create(recursive: true);
    await File(rutaBase).writeAsBytes(contenido.base, flush: true);
    for (final carpeta in FormatoRespaldo.carpetas) {
      final directorio = Directory(rutas.join(soporte.path, carpeta));
      if (await directorio.exists()) await directorio.delete(recursive: true);
      await directorio.create(recursive: true);
      for (final MapEntry(key: nombre, value: bytes)
          in (contenido.archivos[carpeta] ?? const {}).entries) {
        await File(
          rutas.join(directorio.path, nombre),
        ).writeAsBytes(bytes, flush: true);
      }
    }
  }

  Future<Map<String, Map<String, Uint8List>>> _leerCarpetas() async {
    final resultado = <String, Map<String, Uint8List>>{};
    for (final carpeta in FormatoRespaldo.carpetas) {
      final directorio = Directory(rutas.join(soporte.path, carpeta));
      final archivos = <String, Uint8List>{};
      if (await directorio.exists()) {
        await for (final entrada in directorio.list()) {
          if (entrada is File) {
            archivos[rutas.basename(entrada.path)] = await entrada
                .readAsBytes();
          }
        }
      }
      resultado[carpeta] = archivos;
    }
    return resultado;
  }

  static String _marca(DateTime fecha) {
    String dos(int valor) => valor.toString().padLeft(2, '0');
    return '${fecha.year}${dos(fecha.month)}${dos(fecha.day)}-'
        '${dos(fecha.hour)}${dos(fecha.minute)}';
  }
}
