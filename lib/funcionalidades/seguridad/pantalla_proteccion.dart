import 'package:flutter/material.dart';

import '../arranque/constantes_arranque.dart';

// Pregunta, al terminar el tutorial, si se desea proteger la app.
class PantallaProteccion extends StatelessWidget {
  const PantallaProteccion({super.key, required this.alDecidir});

  // Recibe true si el usuario quiere activar el bloqueo.
  final ValueChanged<bool> alDecidir;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ColoresLogo.fondo,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      size: 64,
                      color: ColoresLogo.verdeAgua,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Protege tu información',
                    textAlign: TextAlign.center,
                    style: textos.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Coti guarda tus cobros y ganancias. Pide tu huella o la '
                    'clave de tu teléfono cada vez que se abra. Puedes cambiarlo '
                    'cuando quieras en Mi perfil.',
                    textAlign: TextAlign.center,
                    style: textos.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => alDecidir(true),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Activar bloqueo'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => alDecidir(false),
                    child: const Text('Ahora no'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
