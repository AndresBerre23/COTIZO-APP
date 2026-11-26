import 'package:flutter/animation.dart';

// Tiempos de la animación de arranque. Los intervalos se escriben como
// fracción de la animación y se escalan para dejar una pausa final.
abstract final class TiemposArranque {
  static const _animacion = 2600;

  // Logo y lema quietos al final para que se alcancen a leer.
  static const _pausaFinal = 1400;

  static const duracion = Duration(milliseconds: _animacion + _pausaFinal);
  static const salida = Duration(milliseconds: 450);

  // Convierte una fracción de la animación en fracción de la duración total.
  static double escala(double fraccion) =>
      fraccion * _animacion / (_animacion + _pausaFinal);

  static Interval _tramo(
    double inicio,
    double fin, [
    Curve curva = Curves.linear,
  ]) => Interval(escala(inicio), escala(fin), curve: curva);

  static final arco = _tramo(0, 0.42, Curves.easeOutCubic);
  static final barras = _tramo(0.22, 0.68);
  static final flecha = _tramo(0.5, 0.82, Curves.easeInOutCubic);
  static final texto = _tramo(0.6, 0.92, Curves.easeOutCubic);
  static final brillo = _tramo(0.7, 1, Curves.easeOut);
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
