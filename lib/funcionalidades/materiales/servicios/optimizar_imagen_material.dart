import 'dart:typed_data';

import '../../../core/imagenes/optimizar_imagen.dart';

Future<Uint8List> optimizarImagenMaterial(Uint8List bytes) =>
    optimizarImagen(bytes);
