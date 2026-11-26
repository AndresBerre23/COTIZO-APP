import 'dart:typed_data';

import 'package:coti/funcionalidades/materiales/servicios/optimizar_imagen_material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as imagen;

void main() {
  test('reduce dimensiones y peso de una imagen de referencia', () async {
    final original = imagen.Image(width: 1600, height: 900);
    for (final pixel in original) {
      pixel
        ..r = pixel.x % 256
        ..g = pixel.y % 256
        ..b = (pixel.x + pixel.y) % 256;
    }
    final bytes = Uint8List.fromList(imagen.encodePng(original));

    final optimizada = await optimizarImagenMaterial(bytes);
    final leida = imagen.decodeImage(optimizada)!;

    expect(leida.width, lessThanOrEqualTo(1280));
    expect(leida.height, lessThanOrEqualTo(1280));
    expect(optimizada.lengthInBytes, lessThanOrEqualTo(300 * 1024));
  });

  test('rechaza datos que no contienen una imagen compatible', () async {
    await expectLater(
      optimizarImagenMaterial(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });
}
