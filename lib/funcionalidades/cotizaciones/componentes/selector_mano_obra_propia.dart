import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class SelectorManoObraPropia extends StatelessWidget {
  const SelectorManoObraPropia({
    super.key,
    required this.incluido,
    required this.alCambiar,
  });

  final bool incluido;
  final ValueChanged<bool> alCambiar;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.handyman_outlined, color: AppColors.cobalt),
    title: const Text('¿Cobrarás por tu mano de obra?'),
    subtitle: const Text(
      'Opcional. Se suma como ingreso, aparte de los costos y del margen.',
    ),
    trailing: Checkbox(
      value: incluido,
      onChanged: (valor) {
        if (valor != null) alCambiar(valor);
      },
    ),
    onTap: () => alCambiar(!incluido),
  );
}
