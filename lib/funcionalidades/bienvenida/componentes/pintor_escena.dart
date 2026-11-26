import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import '../../arranque/constantes_arranque.dart';
import 'escenas_bienvenida.dart';
import 'escenas_resultados.dart';

enum EscenaBienvenida { cotizar, obra, ganancias, datos }

// Ilustración de cada pantalla de bienvenida; progreso va de 0 a 1.
class PintorEscena extends CustomPainter {
  const PintorEscena({required this.escena, required this.progreso});

  final EscenaBienvenida escena;
  final double progreso;

  // Avance de un tramo del progreso total, con salida suave.
  double _tramo(double inicio, double fin) => Curves.easeOutCubic.transform(
    ((progreso - inicio) / (fin - inicio)).clamp(0.0, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    _fondo(canvas, s);
    switch (escena) {
      case EscenaBienvenida.cotizar:
        pintarCotizar(canvas, s, _tramo);
      case EscenaBienvenida.obra:
        pintarObra(canvas, s, _tramo);
      case EscenaBienvenida.ganancias:
        pintarGanancias(canvas, s, _tramo);
      case EscenaBienvenida.datos:
        pintarDatos(canvas, s, _tramo);
    }
  }

  void _fondo(Canvas canvas, double s) {
    final marco = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(s * 0.12),
    );
    canvas
      ..save()
      ..clipRRect(marco)
      ..drawRRect(marco, Paint()..color = ColoresLogo.fondo);
    // Ondas de la marca que entran desde las esquinas.
    final entrada = _tramo(0, 0.5);
    canvas.drawCircle(
      Offset(s * (1.15 - 0.1 * entrada), -s * 0.1),
      s * 0.45,
      Paint()..color = ColoresLogo.violeta.withValues(alpha: 0.45 * entrada),
    );
    canvas.drawCircle(
      Offset(-s * (0.1 - 0.08 * entrada), s * 1.1),
      s * 0.42,
      Paint()..color = ColoresLogo.turquesa.withValues(alpha: 0.4 * entrada),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorEscena anterior) =>
      anterior.progreso != progreso || anterior.escena != escena;
}
