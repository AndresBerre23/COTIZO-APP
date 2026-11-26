import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../arranque/constantes_arranque.dart';
import 'escenas_bienvenida.dart';

// Escenas de ganancias y de datos protegidos del tutorial.
void pintarGanancias(Canvas canvas, double s, Tramo tramo) {
  const alturas = [0.22, 0.32, 0.44];
  for (var i = 0; i < 3; i++) {
    final alto = s * alturas[i] * tramo(0.1 + i * 0.12, 0.55 + i * 0.12);
    final rect = Rect.fromLTWH(
      s * (0.24 + i * 0.18),
      s * 0.78 - alto,
      s * 0.13,
      alto,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(s * 0.025),
        topRight: Radius.circular(s * 0.025),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ColoresLogo.verde, ColoresLogo.verdeAgua],
        ).createShader(rect),
    );
  }
  // Flecha ascendente, como en el logo.
  final avance = tramo(0.5, 0.95);
  final curva = Path()
    ..moveTo(s * 0.2, s * 0.5)
    ..quadraticBezierTo(s * 0.5, s * 0.46, s * 0.74, s * 0.22);
  final metrica = curva.computeMetrics().first;
  final largo = metrica.length * avance;
  canvas.drawPath(
    metrica.extractPath(0, largo),
    Paint()
      ..color = ColoresLogo.trazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round,
  );
  final punta = metrica.getTangentForOffset(largo);
  if (punta != null && avance > 0.6) {
    final t = s * 0.06 * ((avance - 0.6) / 0.4);
    canvas
      ..save()
      ..translate(punta.position.dx, punta.position.dy)
      ..rotate(math.atan2(punta.vector.dy, punta.vector.dx))
      ..drawPath(
        Path()
          ..moveTo(t, 0)
          ..lineTo(-t * 0.6, -t * 0.75)
          ..lineTo(-t * 0.6, t * 0.75)
          ..close(),
        relleno(ColoresLogo.trazo),
      )
      ..restore();
  }
}

void pintarDatos(Canvas canvas, double s, Tramo tramo) {
  // Teléfono con un escudo que protege los datos.
  final telefono = tramo(0, 0.45);
  final cuerpo = Rect.fromCenter(
    center: Offset(s * 0.5, s * (0.54 + 0.06 * (1 - telefono))),
    width: s * 0.38,
    height: s * 0.62,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(cuerpo, Radius.circular(s * 0.06)),
    relleno(ColoresLogo.trazo.withValues(alpha: telefono)),
  );
  final escudo = tramo(0.35, 0.75);
  final c = cuerpo.center;
  final e = s * 0.13 * escudo;
  final forma = Path()
    ..moveTo(c.dx, c.dy - e)
    ..lineTo(c.dx + e * 0.85, c.dy - e * 0.6)
    ..quadraticBezierTo(c.dx + e * 0.8, c.dy + e * 0.6, c.dx, c.dy + e)
    ..quadraticBezierTo(
      c.dx - e * 0.8,
      c.dy + e * 0.6,
      c.dx - e * 0.85,
      c.dy - e * 0.6,
    )
    ..close();
  canvas.drawPath(forma, relleno(ColoresLogo.fondo));
  // Visto que se dibuja dentro del escudo.
  final visto = tramo(0.7, 1);
  if (visto > 0) {
    final trazo = Path()
      ..moveTo(c.dx - e * 0.4, c.dy)
      ..lineTo(c.dx - e * 0.08, c.dy + e * 0.32)
      ..lineTo(c.dx + e * 0.45, c.dy - e * 0.3);
    final metrica = trazo.computeMetrics().first;
    canvas.drawPath(
      metrica.extractPath(0, metrica.length * visto),
      Paint()
        ..color = ColoresLogo.verdeAgua
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.025
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }
  pintarDestello(canvas, Offset(s * 0.22, s * 0.28), s * 0.05 * visto);
}
