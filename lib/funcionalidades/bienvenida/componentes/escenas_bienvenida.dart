import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../arranque/constantes_arranque.dart';

// Avance de un tramo del progreso de la escena.
typedef Tramo = double Function(double inicio, double fin);

Paint relleno(Color color) => Paint()..color = color;

void pintarCotizar(Canvas canvas, double s, Tramo tramo) {
  final hoja = tramo(0, 0.4);
  final hojaRect = Rect.fromLTWH(
    s * 0.24,
    s * (0.2 + 0.08 * (1 - hoja)),
    s * 0.52,
    s * 0.62,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(hojaRect, Radius.circular(s * 0.04)),
    relleno(ColoresLogo.trazo.withValues(alpha: hoja)),
  );
  // Renglones de la cotización que se escriben uno tras otro.
  for (var i = 0; i < 4; i++) {
    final avance = tramo(0.25 + i * 0.1, 0.5 + i * 0.1);
    final y = hojaRect.top + s * (0.1 + i * 0.09);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          hojaRect.left + s * 0.06,
          y,
          s * (i == 0 ? 0.24 : 0.36) * avance,
          s * 0.03,
        ),
        Radius.circular(s * 0.015),
      ),
      relleno(const Color(0xFFB9BCE0)),
    );
  }
  // Total destacado con el color de la marca.
  final total = tramo(0.65, 0.9);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        hojaRect.left + s * 0.06,
        hojaRect.bottom - s * 0.13,
        s * 0.4 * total,
        s * 0.07,
      ),
      Radius.circular(s * 0.02),
    ),
    relleno(ColoresLogo.verdeAgua),
  );
  pintarDestello(canvas, Offset(s * 0.78, s * 0.24), s * 0.06 * tramo(0.8, 1));
}

void pintarObra(Canvas canvas, double s, Tramo tramo) {
  // Tarjetas de gasto, consumo y adicional que entran desde la derecha.
  const colores = [
    ColoresLogo.verde,
    ColoresLogo.verdeAgua,
    ColoresLogo.violeta,
  ];
  for (var i = 0; i < 3; i++) {
    final avance = tramo(0.1 + i * 0.15, 0.5 + i * 0.15);
    final rect = Rect.fromLTWH(
      s * (0.2 + 0.3 * (1 - avance)),
      s * (0.24 + i * 0.2),
      s * 0.6,
      s * 0.14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(s * 0.035)),
      relleno(ColoresLogo.trazo.withValues(alpha: avance)),
    );
    canvas.drawCircle(
      Offset(rect.left + s * 0.07, rect.center.dy),
      s * 0.035,
      relleno(colores[i].withValues(alpha: avance)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left + s * 0.14,
          rect.center.dy - s * 0.015,
          s * 0.3,
          s * 0.03,
        ),
        Radius.circular(s * 0.015),
      ),
      relleno(const Color(0xFFB9BCE0).withValues(alpha: avance)),
    );
  }
  // Botón de agregar que aparece al final.
  final mas = tramo(0.75, 1);
  final centro = Offset(s * 0.78, s * 0.8);
  canvas.drawCircle(centro, s * 0.07 * mas, relleno(ColoresLogo.verdeAgua));
  final cruz = Paint()
    ..color = ColoresLogo.fondo
    ..strokeWidth = s * 0.018 * mas
    ..strokeCap = StrokeCap.round;
  final brazo = s * 0.03 * mas;
  canvas
    ..drawLine(centro - Offset(brazo, 0), centro + Offset(brazo, 0), cruz)
    ..drawLine(centro - Offset(0, brazo), centro + Offset(0, brazo), cruz);
}

void pintarDestello(Canvas canvas, Offset centro, double radio) {
  if (radio <= 0) return;
  final pincel = Paint()
    ..color = ColoresLogo.verde
    ..strokeWidth = radio * 0.3
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 4; i++) {
    final angulo = i * math.pi / 2;
    final direccion = Offset(math.cos(angulo), math.sin(angulo));
    canvas.drawLine(
      centro + direccion * radio * 0.35,
      centro + direccion * radio,
      pincel,
    );
  }
}
