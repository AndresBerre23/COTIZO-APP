import 'package:flutter/material.dart';

import 'pintor_escena.dart';

// Una pantalla del tutorial; anima su ilustración al quedar visible.
class PaginaBienvenida extends StatefulWidget {
  const PaginaBienvenida({
    super.key,
    required this.escena,
    required this.titulo,
    required this.texto,
    required this.activa,
  });

  final EscenaBienvenida escena;
  final String titulo;
  final String texto;
  final bool activa;

  @override
  State<PaginaBienvenida> createState() => _PaginaBienvenidaState();
}

class _PaginaBienvenidaState extends State<PaginaBienvenida>
    with SingleTickerProviderStateMixin {
  late final _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.activa) _animar();
  }

  @override
  void didUpdateWidget(PaginaBienvenida anterior) {
    super.didUpdateWidget(anterior);
    if (widget.activa && !anterior.activa) _animar();
  }

  void _animar() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controlador.value = 1;
    } else {
      _controlador.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, limites) {
      final amplio = limites.maxWidth >= 720;
      final lado = [
        limites.maxWidth * (amplio ? 0.4 : 0.72),
        limites.maxHeight * (amplio ? 0.7 : 0.45),
        360.0,
      ].reduce((a, b) => a < b ? a : b);
      final ilustracion = Semantics(
        label: widget.titulo,
        child: SizedBox.square(
          dimension: lado,
          child: AnimatedBuilder(
            animation: _controlador,
            builder: (context, _) => CustomPaint(
              painter: PintorEscena(
                escena: widget.escena,
                progreso: _controlador.value,
              ),
            ),
          ),
        ),
      );
      final textos = FadeTransition(
        opacity: CurvedAnimation(
          parent: _controlador,
          curve: const Interval(0.3, 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: amplio
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Text(
              widget.titulo,
              textAlign: amplio ? TextAlign.start : TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              widget.texto,
              textAlign: amplio ? TextAlign.start : TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: amplio
                ? Row(
                    children: [
                      ilustracion,
                      const SizedBox(width: 48),
                      Expanded(child: textos),
                    ],
                  )
                : Column(
                    children: [ilustracion, const SizedBox(height: 32), textos],
                  ),
          ),
        ),
      );
    },
  );
}
