import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dominio/leer_margen_deseado.dart';
import 'seccion_cotizacion.dart';

class PrecioProyectoEditor extends StatelessWidget {
  const PrecioProyectoEditor({
    super.key,
    required this.total,
    required this.costoPrevisto,
    required this.margen,
    required this.precioSugerido,
    required this.aplicarSugerido,
    required this.guardando,
    required this.alCambiar,
    required this.alGuardar,
  });

  final TextEditingController total;
  final int costoPrevisto;
  final TextEditingController margen;
  final int? precioSugerido;
  final VoidCallback? aplicarSugerido;
  final bool guardando;
  final VoidCallback alCambiar, alGuardar;

  @override
  Widget build(BuildContext context) {
    final cotizado = leerCentavos(total.text) ?? 0;
    return SeccionCotizacion(
      titulo: '2. Precio de tu trabajo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Define el total que pagará el cliente, incluyendo tu trabajo y margen.',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: total,
            validator: validarImporte,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => alCambiar(),
            decoration: const InputDecoration(
              labelText: 'Total cotizado',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 20),
          Text('Costo previsto: ${dinero(costoPrevisto)}'),
          TextFormField(
            controller: margen,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Margen deseado sobre el precio de venta (%)',
            ),
            validator: validarMargenDeseado,
            onChanged: (_) => alCambiar(),
          ),
          if (precioSugerido != null) ...[
            const SizedBox(height: 8),
            Text('Precio sugerido: ${dinero(precioSugerido!)}'),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: aplicarSugerido,
                child: const Text('Usar precio sugerido'),
              ),
            ),
          ],
          if (precioSugerido != null && aplicarSugerido == null)
            const Text('El precio sugerido supera el límite admitido.'),
          const SizedBox(height: 12),
          Text(
            'Ganancia prevista',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              dinero(cotizado - costoPrevisto),
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: cotizado < costoPrevisto
                    ? AppColors.error
                    : AppColors.cobalt,
              ),
            ),
          ),
          if (cotizado < costoPrevisto)
            const Text(
              'El precio cotizado está por debajo del costo previsto.',
              style: TextStyle(color: AppColors.error),
            ),
          const SizedBox(height: 8),
          const Text(
            'El precio final sigue siendo editable. Los gastos registrados se calcularán por separado.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: guardando ? null : alGuardar,
            icon: const Icon(Icons.save_outlined),
            label: Text(guardando ? 'Guardando…' : 'Guardar cotización'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guardado local · Sin conexión',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
