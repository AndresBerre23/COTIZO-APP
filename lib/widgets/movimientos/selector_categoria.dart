import 'package:flutter/material.dart';

// Lista desplegable de categorías de un movimiento.
class SelectorCategoria extends StatelessWidget {
  const SelectorCategoria({
    super.key,
    required this.categorias,
    required this.valor,
    required this.alCambiar,
  });

  final List<String> categorias;
  final String valor;
  final ValueChanged<String> alCambiar;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: valor,
    isExpanded: true,
    decoration: const InputDecoration(labelText: 'Categoría'),
    items: [
      for (final categoria in categorias)
        DropdownMenuItem(
          value: categoria,
          child: Text(categoria, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (nuevo) {
      if (nuevo != null) alCambiar(nuevo);
    },
  );
}
