import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as rutas;
import 'package:path_provider/path_provider.dart';

// Guarda imágenes en una carpeta privada; la base solo guarda el nombre.
class AlmacenImagenLocal {
  const AlmacenImagenLocal(this.carpeta);

  final String carpeta;

  Future<String> guardar(Uint8List bytes) async {
    final directorio = await _directorio();
    final nombre = '${DateTime.now().microsecondsSinceEpoch}-${_sufijo()}.jpg';
    final archivo = File(rutas.join(directorio.path, nombre));
    try {
      await archivo.writeAsBytes(bytes, flush: true);
      return nombre;
    } catch (_) {
      if (await archivo.exists()) await archivo.delete();
      rethrow;
    }
  }

  Future<File> obtenerArchivo(String ruta) async =>
      File(rutas.join((await _directorio()).path, _validarRuta(ruta)));

  Future<void> eliminar(String? ruta) async {
    if (ruta == null) return;
    final archivo = await obtenerArchivo(ruta);
    if (await archivo.exists()) await archivo.delete();
  }

  Future<Directory> _directorio() async {
    final soporte = await getApplicationSupportDirectory();
    final directorio = Directory(rutas.join(soporte.path, carpeta));
    await directorio.create(recursive: true);
    return directorio;
  }

  String _validarRuta(String ruta) {
    if (ruta.isEmpty || rutas.basename(ruta) != ruta) {
      throw const FormatException('La referencia de imagen no es válida.');
    }
    return ruta;
  }

  String _sufijo() => List.generate(
    8,
    (_) => Random.secure().nextInt(16).toRadixString(16),
  ).join();
}

class AlmacenLogoNegocio extends AlmacenImagenLocal {
  const AlmacenLogoNegocio() : super('logo_negocio');
}
