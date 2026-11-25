import 'package:flutter/material.dart';

import '../dominio/opciones_iva.dart';

// Lista de tasas de IVA; -1 representa "no aplica" en el menú.
class SelectorIva extends StatelessWidget {
  const SelectorIva({super.key, required this.puntos, required this.alCambiar});

  final int? puntos;
  final ValueChanged<int?> alCambiar;

  @override
  Widget build(BuildContext context) {
    final valores = [for (final opcion in opcionesIva) opcion.puntos ?? -1];
    final actual = puntos ?? -1;
    return DropdownButtonFormField<int>(
      value: actual,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'IVA de la proforma'),
      items: [
        for (final opcion in opcionesIva)
          DropdownMenuItem(
            value: opcion.puntos ?? -1,
            child: Text(
              opcion.etiqueta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // Conserva una tasa antigua que ya no está en la lista.
        if (!valores.contains(actual))
          DropdownMenuItem(value: actual, child: Text(etiquetaIva(puntos))),
      ],
      onChanged: (valor) =>
          alCambiar(valor == null || valor < 0 ? null : valor),
    );
  }
}
