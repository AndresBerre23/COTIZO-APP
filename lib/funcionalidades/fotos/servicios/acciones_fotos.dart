import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/formato.dart';
import '../../../datos/almacen_fotos_obra.dart';
import '../../../dominio/modelos.dart';

// Pide fotos a la cámara (una) o a la galería (varias).
Future<List<Uint8List>> elegirFotos(ImageSource origen) async {
  final selector = ImagePicker();
  // El selector reduce las fotos enormes; la optimización final la hace Coti.
  const lado = 2560.0;
  final archivos = origen == ImageSource.camera
      ? [
          ?await selector.pickImage(
            source: ImageSource.camera,
            maxWidth: lado,
            maxHeight: lado,
            imageQuality: 95,
            requestFullMetadata: false,
          ),
        ]
      : await selector.pickMultiImage(
          maxWidth: lado,
          maxHeight: lado,
          imageQuality: 95,
          requestFullMetadata: false,
        );
  return [for (final archivo in archivos) await archivo.readAsBytes()];
}

// Comparte las fotos por WhatsApp u otra app, con una descripción.
Future<void> compartirFotos(List<FotoObra> fotos, Proyecto? proyecto) async {
  if (fotos.isEmpty) return;
  const almacen = AlmacenFotosObra();
  final archivos = [
    for (final foto in fotos)
      XFile(
        (await almacen.obtenerArchivo(foto.ruta)).path,
        mimeType: 'image/jpeg',
      ),
  ];
  final titulo = proyecto == null
      ? 'Fotos de obra'
      : '${proyecto.descripcion} · ${proyecto.nombreCliente}';
  final fechas = fotos.map((f) => fechaCorta(f.fecha)).toSet().join(', ');
  await SharePlus.instance.share(
    ShareParams(files: archivos, text: '$titulo ($fechas)', subject: titulo),
  );
}
