import 'package:flutter/material.dart';

enum OrigenImagenMaterial { galeria, camara, internet }

Future<OrigenImagenMaterial?> mostrarOpcionesOrigenImagen(
  BuildContext context,
) => showModalBottomSheet<OrigenImagenMaterial>(
  context: context,
  builder: (context) => SafeArea(
    child: Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Elegir de galería'),
          onTap: () => Navigator.pop(context, OrigenImagenMaterial.galeria),
        ),
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text('Tomar foto'),
          onTap: () => Navigator.pop(context, OrigenImagenMaterial.camara),
        ),
        ListTile(
          leading: const Icon(Icons.public_outlined),
          title: const Text('Buscar en internet'),
          onTap: () => Navigator.pop(context, OrigenImagenMaterial.internet),
        ),
      ],
    ),
  ),
);
