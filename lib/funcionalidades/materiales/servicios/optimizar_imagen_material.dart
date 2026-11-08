import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imagen;

Future<Uint8List> optimizarImagenMaterial(Uint8List bytes) =>
    compute(_optimizarImagen, bytes);

Uint8List _optimizarImagen(Uint8List bytes) {
  final original = imagen.decodeImage(bytes);
  if (original == null) {
    throw const FormatException(
      'El archivo seleccionado no es una imagen válida.',
    );
  }
  var resultado = imagen.bakeOrientation(original);
  resultado
    ..exif = imagen.ExifData()
    ..iccProfile = null
    ..textData = null;
  if (resultado.width > 1280 || resultado.height > 1280) {
    resultado = imagen.copyResize(
      resultado,
      width: resultado.width >= resultado.height ? 1280 : null,
      height: resultado.height > resultado.width ? 1280 : null,
      interpolation: imagen.Interpolation.average,
    );
  }
  for (var intento = 0; intento < 12; intento++) {
    final comprimida = Uint8List.fromList(
      imagen.encodeJpg(resultado, quality: intento < 5 ? 88 - intento * 8 : 48),
    );
    if (comprimida.lengthInBytes <= 300 * 1024) return comprimida;
    if (resultado.width <= 320 && resultado.height <= 320) break;
    resultado = resultado.width >= resultado.height
        ? imagen.copyResize(
            resultado,
            width: (resultado.width * 0.8).round().clamp(1, 1280).toInt(),
            interpolation: imagen.Interpolation.average,
          )
        : imagen.copyResize(
            resultado,
            height: (resultado.height * 0.8).round().clamp(1, 1280).toInt(),
            interpolation: imagen.Interpolation.average,
          );
  }
  throw const FormatException(
    'No se pudo reducir la imagen al tamaño máximo de 300 KB.',
  );
}
