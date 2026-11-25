import 'package:flutter/material.dart';

import '../../../widgets/surface_card.dart';
import '../../movimientos/componentes/barra_comparativa.dart';

// Totales por categoría, con barras relativas a la mayor.
class DesgloseCategorias extends StatelessWidget {
  const DesgloseCategorias({
    super.key,
    required this.titulo,
    required this.totales,
    required this.color,
    required this.mensajeVacio,
  });

  final String titulo;
  final Map<String, int> totales;
  final Color color;
  final String mensajeVacio;

  @override
  Widget build(BuildContext context) {
    final maximo = totales.isEmpty ? 0 : totales.values.first;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          if (totales.isEmpty)
            Text(
              mensajeVacio,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          for (final MapEntry(key: categoria, value: monto) in totales.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BarraComparativa(
                etiqueta: categoria,
                centavos: monto,
                maximo: maximo,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
