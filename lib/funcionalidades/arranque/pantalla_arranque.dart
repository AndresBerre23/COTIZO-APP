import 'package:flutter/material.dart';

import 'componentes/fondo_arranque.dart';
import 'componentes/logo_animado.dart';
import 'constantes_arranque.dart';

// Pantalla de arranque animada; avisa cuando termina la animación.
class PantallaArranque extends StatefulWidget {
  const PantallaArranque({super.key, required this.alTerminar});

  final VoidCallback alTerminar;

  @override
  State<PantallaArranque> createState() => _PantallaArranqueState();
}

class _PantallaArranqueState extends State<PantallaArranque>
    with SingleTickerProviderStateMixin {
  late final _controlador = AnimationController(
    vsync: this,
    duration: TiemposArranque.duracion,
  )..addStatusListener(_alCambiarEstado);
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    // Respeta la opción de reducir animaciones del sistema.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controlador.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.alTerminar());
    } else {
      _controlador.forward();
    }
  }

  void _alCambiarEstado(AnimationStatus estado) {
    if (estado == AnimationStatus.completed) widget.alTerminar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColoresLogo.fondo,
    body: FondoArranque(
      avance: _controlador,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) {
            final tamano = [
              limites.maxWidth * 0.5,
              limites.maxHeight * 0.4,
              220.0,
            ].reduce((a, b) => a < b ? a : b);
            return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: 'Logo de Coti',
                      child: LogoAnimado(avance: _controlador, tamano: tamano),
                    ),
                    SizedBox(height: tamano * 0.1),
                    _TextoMarca(avance: _controlador, tamano: tamano),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

// Nombre y lema que aparecen deslizándose bajo el logo.
class _TextoMarca extends StatelessWidget {
  const _TextoMarca({required this.avance, required this.tamano});

  final AnimationController avance;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final entrada = CurvedAnimation(
      parent: avance,
      curve: TiemposArranque.texto,
    );
    return FadeTransition(
      opacity: entrada,
      child: SlideTransition(
        position: entrada.drive(
          Tween(begin: const Offset(0, 0.35), end: Offset.zero),
        ),
        child: Column(
          children: [
            Text(
              'Coti',
              style: TextStyle(
                color: ColoresLogo.trazo,
                fontSize: tamano * 0.26,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                height: 1,
              ),
            ),
            SizedBox(height: tamano * 0.05),
            Text(
              'Cotiza, controla y crece',
              style: TextStyle(
                color: ColoresLogo.trazo.withValues(alpha: 0.72),
                fontSize: (tamano * 0.075).clamp(12.0, 16.0),
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(height: tamano * 0.12),
            // Solo se ve si los datos tardan más que la animación.
            SizedBox(
              width: tamano * 0.5,
              height: 3,
              child: AnimatedBuilder(
                animation: avance,
                builder: (context, _) => avance.isCompleted
                    ? LinearProgressIndicator(
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                        color: ColoresLogo.verdeAgua,
                        backgroundColor: ColoresLogo.trazo.withValues(
                          alpha: 0.12,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
