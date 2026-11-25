import 'package:flutter/animation.dart';

// Tiempos de la animación de arranque, como fracción de la duración total.
abstract final class TiemposArranque {
  static const duracion = Duration(milliseconds: 1900);
  static const salida = Duration(milliseconds: 450);

  static const arco = Interval(0, 0.42, curve: Curves.easeOutCubic);
  static const barras = Interval(0.22, 0.68);
  static const flecha = Interval(0.5, 0.82, curve: Curves.easeInOutCubic);
  static const texto = Interval(0.6, 0.92, curve: Curves.easeOutCubic);
  static const brillo = Interval(0.7, 1, curve: Curves.easeOut);
}

// Colores propios del logo de Coti.
abstract final class ColoresLogo {
  static const fondo = Color(0xFF10144C);
  static const violeta = Color(0xFF6A2FD6);
  static const turquesa = Color(0xFF00A99A);
  static const verde = Color(0xFF5BE38A);
  static const verdeAgua = Color(0xFF22D3A6);
  static const trazo = Color(0xFFF1F2FF);
}
