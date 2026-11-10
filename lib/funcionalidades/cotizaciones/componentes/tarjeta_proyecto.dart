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

  DateTime get _fecha => proyecto.estaFinalizada
      ? proyecto.fechaFinReal ?? proyecto.fechaInicio
      : proyecto.estaEnCurso
      ? proyecto.fechaInicioReal ?? proyecto.fechaInicio
      : proyecto.fechaInicio;

  String get _etiquetaFecha => proyecto.estaFinalizada
      ? 'Finalizada'
      : proyecto.estaEnCurso
      ? 'Inicio real'
      : 'Inicio previsto';

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: alAbrir,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proyecto.nombreCliente,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proyecto.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(proyecto.etapa),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL COTIZADO',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dinero(proyecto.totalCotizadoCentavos),
                        style: const TextStyle(
                          color: AppColors.cobalt,
                          fontFamily: 'monospace',
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FECHA',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('$_etiquetaFecha: ${fechaCorta(_fecha)}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'COT-${proyecto.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const Spacer(),
                  const Text(
                    'Ver detalle',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
