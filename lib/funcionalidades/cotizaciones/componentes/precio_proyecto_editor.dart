import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/theme/app_theme.dart';
import 'seccion_cotizacion.dart';

class PrecioProyectoEditor extends StatelessWidget {
  const PrecioProyectoEditor({
    super.key,
    required this.total,
    required this.costoMateriales,
    required this.guardando,
    required this.alCambiar,
    required this.alGuardar,
  });

  final TextEditingController total;
  final int costoMateriales;
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
          Text('Costo de materiales: ${dinero(costoMateriales)}'),
          const SizedBox(height: 12),
          Text(
            'Disponible antes de gastos',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              dinero(cotizado - costoMateriales),
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: cotizado < costoMateriales
                    ? AppColors.error
                    : AppColors.cobalt,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registra después transporte, mano de obra y otros gastos del proyecto para conocer su rentabilidad.',
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
