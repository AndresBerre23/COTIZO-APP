import 'package:flutter/material.dart';

import '../../../dominio/modelos.dart';

class DetalleAtribucionImagen extends StatelessWidget {
  const DetalleAtribucionImagen({super.key, required this.atribucion});

  final AtribucionImagenMaterial? atribucion;

  @override
  Widget build(BuildContext context) {
    final dato = atribucion;
    if (dato == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dato.titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText('Autor: ${dato.autor}'),
          SelectableText('Licencia: ${dato.licencia}'),
          SelectableText('Fuente: ${dato.fuenteUrl}'),
          if (dato.licenciaUrl != null)
            SelectableText('Información de licencia: ${dato.licenciaUrl}'),
        ],
      ),
    );
  }
}
