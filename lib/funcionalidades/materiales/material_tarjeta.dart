import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/theme/app_theme.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class MaterialTarjeta extends StatelessWidget {
  const MaterialTarjeta({
    super.key,
    required this.material,
    required this.editar,
    required this.eliminar,
  });

  final MaterialObra material;
  final VoidCallback? editar;
  final VoidCallback? eliminar;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: AppColors.softBlue,
          child: Icon(Icons.inventory_2_outlined, color: AppColors.cobalt),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Por ${material.unidadMedida}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              Text(
                dinero(material.costoBaseCentavos),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: AppColors.cobalt,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Opciones del material',
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
