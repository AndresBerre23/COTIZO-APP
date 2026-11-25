import 'package:flutter/material.dart';

import '../../../core/formato.dart';

// Barra horizontal animada proporcional a un máximo.
class BarraComparativa extends StatelessWidget {
  const BarraComparativa({
    super.key,
    required this.etiqueta,
    required this.centavos,
    required this.maximo,
    required this.color,
  });

  final String etiqueta;
  final int centavos;
  final int maximo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final proporcion = maximo <= 0 ? 0.0 : centavos / maximo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dinero(centavos),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: proporcion),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, valor, _) => LinearProgressIndicator(
              value: valor,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ),
      ],
    );
  }
}
