import 'package:flutter/material.dart';

import '../../../widgets/surface_card.dart';

class SeccionCotizacion extends StatelessWidget {
  const SeccionCotizacion({
    super.key,
    required this.titulo,
    required this.child,
  });

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
