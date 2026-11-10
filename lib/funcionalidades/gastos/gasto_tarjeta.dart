import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class GastoTarjeta extends StatelessWidget {
  const GastoTarjeta({
    super.key,
    required this.gasto,
    required this.destino,
    required this.editar,
    required this.eliminar,
  });

  final Gasto gasto;
  final String destino;
  final VoidCallback? editar;
  final VoidCallback? eliminar;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.receipt_long_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gasto.categoria,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                destino,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fechaHoraCorta(gasto.fecha),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (gasto.nota.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(gasto.nota),
              ],
              const SizedBox(height: 8),
              Text(
                dinero(gasto.montoCentavos),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Opciones del gasto',
          enabled: editar != null,
          onSelected: (opcion) =>
              opcion == 'editar' ? editar?.call() : eliminar?.call(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
        ),
      ],
    ),
  );
}
