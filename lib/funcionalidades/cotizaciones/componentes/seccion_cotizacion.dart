import 'package:flutter/material.dart';

import '../../../widgets/surface_card.dart';
import '../../../widgets/ayuda/boton_ayuda.dart';
import '../../../widgets/ayuda/temas_ayuda.dart';

class SeccionCotizacion extends StatelessWidget {
  const SeccionCotizacion({
    super.key,
    required this.titulo,
    required this.child,
    this.ayuda,
  });

  final String titulo;
  final Widget child;
  final TemaAyuda? ayuda;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (ayuda != null) BotonAyuda(tema: ayuda!),
          ],
        ),
        SizedBox(height: ayuda == null ? 16 : 8),
        child,
      ],
    ),
  );
}
