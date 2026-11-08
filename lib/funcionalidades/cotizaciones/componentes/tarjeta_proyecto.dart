import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/surface_card.dart';

class TarjetaProyecto extends StatelessWidget {
  const TarjetaProyecto({
    super.key,
    required this.proyecto,
    required this.alAbrir,
  });

  final Proyecto proyecto;
  final VoidCallback alAbrir;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: alAbrir,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'COT-${proyecto.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  Chip(label: Text(proyecto.etapa)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proyecto.descripcion,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                proyecto.nombreCliente,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    dinero(proyecto.totalCotizadoCentavos),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cobalt,
                    ),
                  ),
                  Text('Inicio previsto: ${fechaCorta(proyecto.fechaInicio)}'),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text('Ver detalle', style: TextStyle(color: AppColors.blue)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
