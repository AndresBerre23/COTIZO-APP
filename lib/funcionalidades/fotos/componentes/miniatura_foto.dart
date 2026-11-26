import 'dart:io';

import 'package:flutter/material.dart';

import '../../../datos/almacen_fotos_obra.dart';
import '../../../dominio/modelos.dart';

// Miniatura de una foto de obra, cuadrada y con esquinas redondeadas.
class MiniaturaFoto extends StatelessWidget {
  const MiniaturaFoto({super.key, required this.foto, required this.alTocar});

  final FotoObra foto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final fondo = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      button: true,
      label:
          'Foto del ${foto.fecha.day}/${foto.fecha.month}/${foto.fecha.year}',
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: fondo,
            child: FutureBuilder<File>(
              future: const AlmacenFotosObra().obtenerArchivo(foto.miniatura),
              builder: (context, archivo) => archivo.hasData
                  ? Image.file(
                      archivo.data!,
                      fit: BoxFit.cover,
                      cacheWidth: 400,
                      errorBuilder: (_, _, _) => const _SinImagen(),
                    )
                  : const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SinImagen extends StatelessWidget {
  const _SinImagen();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Icon(Icons.broken_image_outlined));
}
