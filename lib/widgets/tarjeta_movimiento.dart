import 'package:flutter/material.dart';

import '../core/formato.dart';
import '../dominio/modelos.dart';
import 'surface_card.dart';

// Tarjeta de un gasto o ingreso con su menú de opciones.
class TarjetaMovimiento extends StatelessWidget {
  const TarjetaMovimiento({
    super.key,
    required this.movimiento,
    required this.destino,
    required this.esIngreso,
    required this.tooltipOpciones,
    required this.editar,
    required this.eliminar,
    this.detalle,
  });

  final Movimiento movimiento;
  final String destino;
  final bool esIngreso;
  final String tooltipOpciones;
  final VoidCallback? editar;
  final VoidCallback? eliminar;

  // Dato extra bajo el destino, como el método de pago.
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final secundario = TextStyle(color: colores.onSurfaceVariant);
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: esIngreso
                ? colores.secondaryContainer
                : colores.primaryContainer,
            child: Icon(
              esIngreso ? Icons.south_west : Icons.receipt_long_outlined,
              color: esIngreso ? colores.secondary : colores.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.categoria,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(destino, style: secundario),
                if (detalle != null) ...[
                  const SizedBox(height: 4),
                  Text(detalle!, style: secundario),
                ],
                const SizedBox(height: 4),
                Text(
                  fechaHoraCorta(movimiento.fecha),
                  style: secundario.copyWith(fontSize: 12),
                ),
                if (movimiento.nota.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(movimiento.nota),
                ],
                const SizedBox(height: 8),
                Text(
                  '${esIngreso ? '+' : '-'} ${dinero(movimiento.montoCentavos)}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: esIngreso ? colores.secondary : colores.error,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: tooltipOpciones,
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
}
