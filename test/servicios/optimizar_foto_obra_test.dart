import 'dart:math';
import 'dart:typed_data';

import 'package:coti/core/imagenes/optimizar_imagen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as imagen;

void main() {
  test('la foto de obra queda en 1920 px y su miniatura en 400 px', () async {
    // Ruido para simular el detalle de una foto real, difícil de comprimir.
    final azar = Random(7);
    final original = imagen.Image(width: 4000, height: 3000);
    for (final pixel in original) {
      pixel
        ..r = (pixel.x ~/ 8 + azar.nextInt(40)) % 256
        ..g = (pixel.y ~/ 8 + azar.nextInt(40)) % 256
        ..b = azar.nextInt(256);
    }
    final bytes = Uint8List.fromList(imagen.encodeJpg(original, quality: 95));

    final resultado = await optimizarFotoObra(bytes);
    final foto = imagen.decodeImage(resultado.foto)!;
    final miniatura = imagen.decodeImage(resultado.miniatura)!;

    expect(foto.width, lessThanOrEqualTo(1920));
    expect(resultado.foto.lengthInBytes, lessThanOrEqualTo(600 * 1024));
    expect(miniatura.width, lessThanOrEqualTo(400));
    expect(resultado.miniatura.lengthInBytes, lessThanOrEqualTo(60 * 1024));
    // Mucho más liviana que el original.
    expect(resultado.foto.lengthInBytes, lessThan(bytes.lengthInBytes ~/ 3));
  });
}
