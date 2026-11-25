import 'package:flutter/material.dart';

import '../../dominio/modelos.dart';

// Elige el proyecto de un movimiento; 0 significa "sin proyecto".
class SelectorProyectoMovimiento extends StatelessWidget {
  const SelectorProyectoMovimiento({
    super.key,
    required this.proyectos,
    required this.valor,
    required this.etiquetaGeneral,
    required this.alCambiar,
    this.idConservado,
  });

  final List<Proyecto> proyectos;
  final int valor;
  final String etiquetaGeneral;
  final ValueChanged<int> alCambiar;

  // Proyecto que se muestra aunque ya no admita movimientos.
  final int? idConservado;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    value: valor,
    isExpanded: true,
    decoration: const InputDecoration(labelText: 'Asignar a'),
    items: [
      DropdownMenuItem(value: 0, child: Text(etiquetaGeneral)),
      for (final proyecto in proyectos)
        if (proyecto.admiteGastos || proyecto.id == idConservado)
          DropdownMenuItem(
            value: proyecto.id,
            child: Text(
              '${proyecto.nombreCliente} · ${proyecto.descripcion}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
    ],
    onChanged: (nuevo) => alCambiar(nuevo ?? 0),
  );
}
