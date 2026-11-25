import 'package:flutter/material.dart';

import '../constantes_arranque.dart';

// Fondo azul con las ondas violeta y turquesa del logo, en leve movimiento.
class FondoArranque extends StatelessWidget {
  const FondoArranque({super.key, required this.avance, required this.child});

  final Animation<double> avance;
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: ColoresLogo.fondo,
    child: AnimatedBuilder(
      animation: avance,
      builder: (context, contenido) {
        final v = Curves.easeOut.transform(avance.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            _Mancha(
              alineacion: Alignment(1.1 - 0.15 * v, -1.1 + 0.1 * v),
              color: ColoresLogo.violeta,
              opacidad: 0.55 * v,
            ),
            _Mancha(
              alineacion: Alignment(-1.1 + 0.15 * v, 1.1 - 0.1 * v),
              color: ColoresLogo.turquesa,
              opacidad: 0.45 * v,
            ),
            contenido!,
          ],
        );
      },
      child: child,
    ),
  );
}

class _Mancha extends StatelessWidget {
  const _Mancha({
    required this.alineacion,
    required this.color,
    required this.opacidad,
  });

  final Alignment alineacion;
  final Color color;
  final double opacidad;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: alineacion,
          radius: 0.9,
          colors: [
            color.withValues(alpha: opacidad),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}
