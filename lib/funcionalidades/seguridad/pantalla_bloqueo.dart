import 'package:flutter/material.dart';

import '../arranque/constantes_arranque.dart';

// Pantalla con el logo que espera la huella o la clave del teléfono.
class PantallaBloqueo extends StatefulWidget {
  const PantallaBloqueo({
    super.key,
    required this.autenticando,
    required this.alDesbloquear,
  });

  final bool autenticando;
  final VoidCallback alDesbloquear;

  @override
  State<PantallaBloqueo> createState() => _PantallaBloqueoState();
}

class _PantallaBloqueoState extends State<PantallaBloqueo> {
  @override
  void initState() {
    super.initState();
    // Pide el desbloqueo apenas aparece, sin un toque extra.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.alDesbloquear());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColoresLogo.fondo,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/CotiIcono.png',
                  width: 88,
                  height: 88,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Coti está protegida',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColoresLogo.trazo,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usa tu huella o la clave de tu teléfono para entrar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColoresLogo.trazo.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: ColoresLogo.verdeAgua,
                  foregroundColor: ColoresLogo.fondo,
                ),
                onPressed: widget.autenticando ? null : widget.alDesbloquear,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Desbloquear'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
