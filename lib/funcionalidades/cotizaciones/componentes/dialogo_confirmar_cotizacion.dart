import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../dominio/modelos.dart';
import 'resumen_cotizacion_final.dart';

Future<bool?> mostrarConfirmacionCotizacion({
  required BuildContext context,
  required Proyecto proyecto,
  required List<ItemProyecto> partidas,
  required List<GastoPrevisto> gastosPrevistos,
}) => showDialog<bool>(
  context: context,
  builder: (contextoDialogo) => Dialog(
    backgroundColor: AppColors.canvas,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.sizeOf(contextoDialogo).height * 0.9,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.cobalt,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revisa tu cotización',
                          style: Theme.of(contextoDialogo).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confirma que los datos estén correctos antes de guardarla.',
                          style: Theme.of(contextoDialogo).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: ResumenCotizacionFinal(
                  proyecto: proyecto,
                  partidas: partidas,
                  gastosPrevistos: gastosPrevistos,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(contextoDialogo, false),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(contextoDialogo, true),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar cotización'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
