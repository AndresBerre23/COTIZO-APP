import 'package:flutter/material.dart';

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
    leading: Icon(
      Icons.handyman_outlined,
      color: Theme.of(context).colorScheme.primary,
    ),
    title: Text('¿Cobrarás por tu mano de obra?'),
    subtitle: Text(
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
