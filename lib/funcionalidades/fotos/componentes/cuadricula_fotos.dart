import 'package:flutter/material.dart';

import '../../../dominio/modelos.dart';
import '../visor_fotos_pagina.dart';
import 'miniatura_foto.dart';

// Cuadrícula de miniaturas que abre el visor al tocar una foto.
class CuadriculaFotos extends StatelessWidget {
  const CuadriculaFotos({
    super.key,
    required this.proyectoId,
    required this.fotos,
    this.maximo,
  });

  final int proyectoId;

  // Fotos del proyecto en el orden del visor (más recientes primero).
  final List<FotoObra> fotos;

  // Limita cuántas se muestran; el resto se ve en el visor.
  final int? maximo;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, limites) {
      final columnas = (limites.maxWidth / 120).floor().clamp(3, 8);
      final visibles = maximo == null ? fotos : fotos.take(maximo!).toList();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnas,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemBuilder: (context, i) => MiniaturaFoto(
          foto: visibles[i],
          alTocar: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  VisorFotosPagina(proyectoId: proyectoId, inicial: i),
            ),
          ),
        ),
      );
    },
  );
}
