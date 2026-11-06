import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'surface_card.dart';

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
  });
  final IconData icono;
  final String titulo, mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.softBlue,
            child: Icon(icono, size: 32, color: AppColors.cobalt),
          ),
          const SizedBox(height: 20),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (accion != null) ...[const SizedBox(height: 20), accion!],
        ],
      ),
    ),
  );
}
