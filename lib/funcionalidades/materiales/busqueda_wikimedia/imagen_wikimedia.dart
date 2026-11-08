import 'dart:typed_data';

import '../../../dominio/modelos.dart';

class ImagenWikimedia {
  const ImagenWikimedia({
    required this.titulo,
    required this.miniaturaUrl,
    required this.descargaUrl,
    required this.atribucion,
  });

  final String titulo;
  final Uri miniaturaUrl;
  final Uri descargaUrl;
  final AtribucionImagenMaterial atribucion;
}

class PaginaImagenesWikimedia {
  const PaginaImagenesWikimedia({
    required this.imagenes,
    required this.siguienteOffset,
  });

  final List<ImagenWikimedia> imagenes;
  final int? siguienteOffset;
}

class ImagenWikimediaElegida {
  const ImagenWikimediaElegida({required this.bytes, required this.atribucion});

  final Uint8List bytes;
  final AtribucionImagenMaterial atribucion;
}

class ErrorWikimedia implements Exception {
  const ErrorWikimedia(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
