import 'package:flutter/material.dart';

import '../constantes_arranque.dart';

// Desvanece el color del arranque sobre la app para evitar un corte brusco.
class CortinaArranque extends StatefulWidget {
  const CortinaArranque({super.key, required this.child});

  final Widget child;

  @override
  State<CortinaArranque> createState() => _CortinaArranqueState();
}

class _CortinaArranqueState extends State<CortinaArranque>
    with SingleTickerProviderStateMixin {
  late final _controlador = AnimationController(
    vsync: this,
    duration: TiemposArranque.salida,
  )..forward();
  late final _opacidad = Tween<double>(
    begin: 1,
    end: 0,
  ).animate(CurvedAnimation(parent: _controlador, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      AnimatedBuilder(
        animation: _controlador,
        builder: (context, _) => _controlador.isCompleted
            ? const SizedBox.shrink()
            : Positioned.fill(
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: _opacidad,
                    child: const ColoredBox(color: ColoresLogo.fondo),
                  ),
                ),
              ),
      ),
    ],
  );
}
