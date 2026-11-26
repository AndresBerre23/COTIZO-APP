import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

// Estructura del archivo .zip de respaldo (D-011).
abstract final class FormatoRespaldo {
  static const version = 1;
  static const manifiesto = 'coti-respaldo.json';
  static const base = 'cotizo.sqlite';
  static const carpetas = [
    'imagenes_materiales',
    'foto_perfil',
    'logo_negocio',
    'fotos_obra',
  ];
  static final _cabeceraSqlite = ascii.encode('SQLite format 3');
}

// Contenido validado de un respaldo, listo para restaurar.
class ContenidoRespaldo {
  const ContenidoRespaldo({
    required this.creado,
    required this.versionEsquema,
    required this.base,
    required this.archivos,
  });

  final DateTime creado;
  final int versionEsquema;
  final Uint8List base;

  // Clave: carpeta; valor: nombre de archivo y bytes.
  final Map<String, Map<String, Uint8List>> archivos;

  int get totalImagenes =>
      archivos.values.fold(0, (total, carpeta) => total + carpeta.length);
}

Uint8List codificarRespaldo({
  required Uint8List base,
  required int versionEsquema,
  required Map<String, Map<String, Uint8List>> archivos,
  DateTime? creado,
}) {
  final zip = Archive()
    ..addFile(
      ArchiveFile.string(
        FormatoRespaldo.manifiesto,
        jsonEncode({
          'aplicacion': 'Coti',
          'formato': FormatoRespaldo.version,
          'version_esquema': versionEsquema,
          'creado': (creado ?? DateTime.now()).toIso8601String(),
        }),
      ),
    )
    ..addFile(ArchiveFile.bytes(FormatoRespaldo.base, base));
  archivos.forEach((carpeta, contenido) {
    contenido.forEach((nombre, bytes) {
      zip.addFile(ArchiveFile.bytes('$carpeta/$nombre', bytes));
    });
  });
  return ZipEncoder().encodeBytes(zip);
}

// Lanza FormatException con un mensaje para el usuario si no es válido.
ContenidoRespaldo decodificarRespaldo(
  List<int> bytes, {
  required int versionEsquemaActual,
}) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    throw const FormatException('El archivo no es un respaldo de Coti.');
  }
  final manifiesto = zip.findFile(FormatoRespaldo.manifiesto);
  final base = zip.findFile(FormatoRespaldo.base);
  if (manifiesto == null || base == null) {
    throw const FormatException('El archivo no es un respaldo de Coti.');
  }
  final datos = _leerManifiesto(manifiesto.content);
  final versionEsquema = datos['version_esquema'];
  if (datos['formato'] != FormatoRespaldo.version || versionEsquema is! int) {
    throw const FormatException('El formato del respaldo no es compatible.');
  }
  if (versionEsquema > versionEsquemaActual) {
    throw const FormatException(
      'El respaldo se creó con una versión más nueva de Coti. '
      'Actualiza la app e inténtalo de nuevo.',
    );
  }
  final bytesBase = Uint8List.fromList(base.content);
  if (!_esSqlite(bytesBase)) {
    throw const FormatException('El respaldo está dañado.');
  }
  return ContenidoRespaldo(
    creado: DateTime.tryParse('${datos['creado']}') ?? DateTime(1970),
    versionEsquema: versionEsquema,
    base: bytesBase,
    archivos: _leerCarpetas(zip),
  );
}

Map<String, Object?> _leerManifiesto(List<int> contenido) {
  try {
    final datos = jsonDecode(utf8.decode(contenido));
    if (datos is Map<String, Object?>) return datos;
  } catch (_) {}
  throw const FormatException('El respaldo está dañado.');
}

bool _esSqlite(Uint8List bytes) {
  final cabecera = FormatoRespaldo._cabeceraSqlite;
  if (bytes.length < cabecera.length) return false;
  for (var i = 0; i < cabecera.length; i++) {
    if (bytes[i] != cabecera[i]) return false;
  }
  return true;
}

// Solo acepta archivos planos dentro de las carpetas conocidas.
Map<String, Map<String, Uint8List>> _leerCarpetas(Archive zip) {
  final resultado = {
    for (final carpeta in FormatoRespaldo.carpetas)
      carpeta: <String, Uint8List>{},
  };
  for (final archivo in zip.files) {
    if (!archivo.isFile) continue;
    final partes = archivo.name.split('/');
    if (partes.length != 2) continue;
    final [carpeta, nombre] = partes;
    final valido = RegExp(r'^[\w.-]+$').hasMatch(nombre) && nombre != '..';
    if (!resultado.containsKey(carpeta) || !valido) continue;
    resultado[carpeta]![nombre] = Uint8List.fromList(archivo.content);
  }
  return resultado;
}
