import 'package:flutter/material.dart';

import '../constantes_arranque.dart';
import 'pintor_logo.dart';

// Logo de Coti que se dibuja según el avance de la animación.
class LogoAnimado extends StatelessWidget {
  const LogoAnimado({super.key, required this.avance, required this.tamano});

  final Animation<double> avance;
  final double tamano;

  static double _tramo(double valor, Interval intervalo) =>
      intervalo.transform(valor.clamp(0.0, 1.0));

  // Cada barra arranca un poco después que la anterior.
  static double _barra(double valor, int indice) {
    final tramo = TiemposArranque.barras;
    final inicio = tramo.begin + TiemposArranque.escala(indice * 0.07);
    final fin = (inicio + TiemposArranque.escala(0.32)).clamp(0.0, tramo.end);
    return Interval(inicio, fin, curve: Curves.easeOutBack).transform(valor);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: avance,
    builder: (context, _) {
      final v = avance.value;
      final brillo = _tramo(v, TiemposArranque.brillo);
      final entrada = _tramo(v, TiemposArranque.arco);
      return Transform.scale(
        scale: 0.86 + 0.14 * entrada,
        child: SizedBox.square(
          dimension: tamano,
          child: DecoratedBox(
            // Resplandor suave que aparece al completar el logo.
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.5,
                colors: [
                  ColoresLogo.verdeAgua.withValues(alpha: 0.22 * brillo),
                  ColoresLogo.verdeAgua.withValues(alpha: 0),
                ],
              ),
            ),
            child: CustomPaint(
              painter: PintorLogo(
                arco: _tramo(v, TiemposArranque.arco),
                barras: List.generate(3, (i) => _barra(v, i)),
                flecha: _tramo(v, TiemposArranque.flecha),
              ),
            ),
          ),
        ),
      );
    },
  );
}
