import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../constantes_arranque.dart';

// Dibuja el logo de Coti por etapas; cada progreso va de 0 a 1.
class PintorLogo extends CustomPainter {
  const PintorLogo({
    required this.arco,
    required this.barras,
    required this.flecha,
  });

  final double arco;
  final List<double> barras;
  final double flecha;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    _pintarArco(canvas, s);
    _pintarBarras(canvas, s);
    _pintarFlecha(canvas, s);
  }

  void _pintarArco(Canvas canvas, double s) {
    if (arco <= 0) return;
    final pincel = Paint()
      ..color = ColoresLogo.trazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.115
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
      center: Offset(s / 2, s / 2),
      radius: s * 0.37,
    );
    // Abre la C hacia la derecha y la traza en sentido antihorario.
    canvas.drawArc(rect, -math.pi / 4, -1.5 * math.pi * arco, false, pincel);
  }

  void _pintarBarras(Canvas canvas, double s) {
    const izquierdas = [0.345, 0.465, 0.585];
    const alturas = [0.2, 0.26, 0.32];
    final ancho = s * 0.09;
    final base = s * 0.74;
    for (var i = 0; i < barras.length; i++) {
      final alto = s * alturas[i] * barras[i];
      if (alto <= 0) continue;
      final rect = Rect.fromLTWH(s * izquierdas[i], base - alto, ancho, alto);
      final pincel = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ColoresLogo.verde, ColoresLogo.verdeAgua, Color(0xFF0E6E86)],
        ).createShader(rect);
      final radio = Radius.circular(math.min(s * 0.022, alto / 2));
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: radio, topRight: radio),
        pincel,
      );
    }
  }

  void _pintarFlecha(Canvas canvas, double s) {
    if (flecha <= 0) return;
    final curva = Path()
      ..moveTo(s * 0.3, s * 0.5)
      ..quadraticBezierTo(s * 0.52, s * 0.48, s * 0.66, s * 0.3);
    final metrica = curva.computeMetrics().first;
    final largo = metrica.length * flecha;
    final pincel = Paint()
      ..color = ColoresLogo.verde
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(metrica.extractPath(0, largo), pincel);

    final punta = metrica.getTangentForOffset(largo);
    if (punta == null) return;
    // La punta crece al final del trazo.
    final escala = ((flecha - 0.6) / 0.4).clamp(0.0, 1.0) * s * 0.075;
    if (escala <= 0) return;
    final angulo = math.atan2(punta.vector.dy, punta.vector.dx);
    canvas
      ..save()
      ..translate(punta.position.dx, punta.position.dy)
      ..rotate(angulo)
      ..drawPath(
        Path()
          ..moveTo(escala, 0)
          ..lineTo(-escala * 0.6, -escala * 0.75)
          ..lineTo(-escala * 0.6, escala * 0.75)
          ..close(),
        Paint()..color = ColoresLogo.verde,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(PintorLogo anterior) =>
      anterior.arco != arco ||
      anterior.flecha != flecha ||
      !_listasIguales(anterior.barras, barras);

  static bool _listasIguales(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
