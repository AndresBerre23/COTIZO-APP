import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dominio/modelos.dart';
import 'seccion_cotizacion.dart';

class MaterialesProyectoDetalle extends StatelessWidget {
  const MaterialesProyectoDetalle({super.key, required this.partidas});

  final List<ItemProyecto> partidas;

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: 'Materiales del proyecto',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (partidas.isEmpty) const Text('No se han añadido materiales.'),
        for (final partida in partidas)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partida.nombreMaterial,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${partida.cantidad} ${partida.unidadMedida} × '
                  '${dinero(partida.costoUnitarioAplicadoCentavos)}',
                ),
                Text(
                  dinero(partida.subtotalCentavos),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.cobalt,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class GastosProyectoDetalle extends StatelessWidget {
  const GastosProyectoDetalle({
    super.key,
    required this.gastos,
    required this.guardando,
    required this.alRegistrar,
  });

  final List<Gasto> gastos;
  final bool guardando;
  final VoidCallback alRegistrar;

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: 'Gastos registrados',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: guardando ? null : alRegistrar,
          icon: const Icon(Icons.add),
          label: const Text('Registrar gasto'),
        ),
        const SizedBox(height: 12),
        if (gastos.isEmpty)
          const Text(
            'Aún no hay gastos en este proyecto. '
            'Añade el primero para actualizar la rentabilidad.',
          ),
        for (final gasto in gastos)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${gasto.categoria} · ${fechaCorta(gasto.fecha)}'),
                if (gasto.nota.isNotEmpty) Text(gasto.nota),
                Text(
                  dinero(gasto.montoCentavos),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class GastosPrevistosProyectoDetalle extends StatelessWidget {
  const GastosPrevistosProyectoDetalle({super.key, required this.gastos});

  final List<GastoPrevisto> gastos;

  @override
  Widget build(BuildContext context) {
    final total = gastos.fold<int>(
      0,
      (acumulado, gasto) => acumulado + gasto.montoCentavos,
    );
    return SeccionCotizacion(
      titulo: 'Gastos previstos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (gastos.isEmpty)
            const Text('Esta cotización no tiene gastos previstos.'),
          for (final gasto in gastos)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gasto.categoria),
                        if (gasto.descripcion.isNotEmpty)
                          Text(
                            gasto.descripcion,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(dinero(gasto.montoCentavos)),
                ],
              ),
            ),
          if (gastos.isNotEmpty) ...[
            const Divider(),
            Text('Total previsto: ${dinero(total)}'),
          ],
          const SizedBox(height: 8),
          const Text(
            'Se muestra por separado de los gastos registrados para evitar descontarlos dos veces.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
