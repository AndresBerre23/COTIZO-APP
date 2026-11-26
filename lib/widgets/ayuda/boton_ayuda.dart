import 'package:flutter/material.dart';

import 'temas_ayuda.dart';

// Botón de información que explica para qué sirve una sección.
class BotonAyuda extends StatelessWidget {
  const BotonAyuda({super.key, required this.tema});

  final TemaAyuda tema;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Información: ${tema.titulo}',
    visualDensity: VisualDensity.compact,
    onPressed: () => mostrarAyuda(context, tema),
    icon: Icon(
      Icons.info_outline,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

Future<void> mostrarAyuda(BuildContext context, TemaAyuda tema) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (contexto) => _PanelAyuda(tema: tema),
    );

class _PanelAyuda extends StatelessWidget {
  const _PanelAyuda({required this.tema});

  final TemaAyuda tema;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: colores.secondary),
                const SizedBox(width: 8),
                Expanded(child: Text(tema.titulo, style: textos.titleLarge)),
              ],
            ),
            const SizedBox(height: 12),
            Text(tema.paraQue, style: textos.bodyLarge),
            const SizedBox(height: 16),
            Text('Cómo se usa', style: textos.titleSmall),
            const SizedBox(height: 8),
            for (var i = 0; i < tema.pasos.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: colores.primaryContainer,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colores.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(tema.pasos[i])),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colores.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ejemplo: ${tema.ejemplo}',
                style: TextStyle(color: colores.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
