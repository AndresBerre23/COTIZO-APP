import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../dominio/modelos.dart';
import 'detalle_atribucion_imagen.dart';
import 'imagen_material.dart';

Future<void> mostrarVistaPreviaImagenMaterial(
  BuildContext context, {
  required String? ruta,
  required Uint8List? bytes,
  required AtribucionImagenMaterial? atribucion,
}) => showDialog<void>(
  context: context,
  builder: (context) => Dialog(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InteractiveViewer(
            child: bytes == null
                ? ImagenMaterial(ruta: ruta, ancho: 360)
                : Image.memory(bytes, fit: BoxFit.contain),
          ),
          DetalleAtribucionImagen(atribucion: atribucion),
        ],
      ),
    ),
  ),
);
