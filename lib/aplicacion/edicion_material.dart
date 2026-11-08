import 'dart:typed_data';

import '../dominio/modelos.dart';

class EdicionMaterial {
  const EdicionMaterial({
    required this.material,
    this.imagenNueva,
    this.atribucionNueva,
    this.quitarImagen = false,
  });

  final MaterialObra material;
  final Uint8List? imagenNueva;
  final AtribucionImagenMaterial? atribucionNueva;
  final bool quitarImagen;
}
