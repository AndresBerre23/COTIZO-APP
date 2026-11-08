import 'dart:typed_data';

import '../../../dominio/modelos.dart';

class CambioImagenMaterial {
  const CambioImagenMaterial({
    this.bytes,
    this.atribucion,
    this.quitar = false,
  });

  final Uint8List? bytes;
  final AtribucionImagenMaterial? atribucion;
  final bool quitar;
}
