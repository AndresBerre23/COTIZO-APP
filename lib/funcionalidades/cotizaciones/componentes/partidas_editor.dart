import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dominio/modelos.dart';
import 'seccion_cotizacion.dart';

class PartidasEditor extends StatelessWidget {
  const PartidasEditor({
    super.key,
    required this.partidas,
    required this.alAgregar,
    required this.alEditar,
    required this.alEliminar,
  });

  final List<ItemProyecto> partidas;
  final VoidCallback alAgregar;
  final ValueChanged<int> alEditar;
  final ValueChanged<int> alEliminar;

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: 'Materiales e insumos',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (partidas.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Añade los materiales que necesitará este proyecto. '
              'Puedes ajustar cantidades y costos antes de guardar.',
            ),
          ),
        for (var indice = 0; indice < partidas.length; indice++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partidas[indice].nombreMaterial,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${partidas[indice].cantidad} ${partidas[indice].unidadMedida}'
                      ' × ${dinero(partidas[indice].costoUnitarioAplicadoCentavos)}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    Text(
                      dinero(partidas[indice].subtotalCentavos),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar partida',
                onPressed: () => alEditar(indice),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Quitar partida',
                onPressed: () => alEliminar(indice),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 24),
        ],
        OutlinedButton.icon(
          onPressed: alAgregar,
          icon: const Icon(Icons.add),
          label: const Text('Añadir material'),
        ),
      ],
    ),
  );
}
