import 'package:flutter/material.dart';

import 'filtros_materiales.dart';

class ControlesMateriales extends StatelessWidget {
  const ControlesMateriales({
    super.key,
    required this.total,
    required this.conImagen,
    required this.sinImagen,
    required this.resultados,
    required this.filtroImagen,
    required this.unidad,
    required this.orden,
    required this.alCambiarImagen,
    required this.alElegirUnidad,
    required this.alOrdenar,
  });

  final int total;
  final int conImagen;
  final int sinImagen;
  final int resultados;
  final FiltroImagenMaterial filtroImagen;
  final String? unidad;
  final OrdenMateriales orden;
  final ValueChanged<FiltroImagenMaterial> alCambiarImagen;
  final VoidCallback alElegirUnidad;
  final ValueChanged<OrdenMateriales> alOrdenar;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 44,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('Todos ($total)', FiltroImagenMaterial.todos),
              const SizedBox(width: 8),
              _chip('Con imagen ($conImagen)', FiltroImagenMaterial.conImagen),
              const SizedBox(width: 8),
              _chip('Sin imagen ($sinImagen)', FiltroImagenMaterial.sinImagen),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: alElegirUnidad,
            icon: const Icon(Icons.straighten),
            label: Text(
              unidad == null ? 'Unidad de medida' : 'Unidad: $unidad',
            ),
          ),
          PopupMenuButton<OrdenMateriales>(
            initialValue: orden,
            onSelected: alOrdenar,
            itemBuilder: (contexto) => OrdenMateriales.values
                .map(
                  (valor) =>
                      PopupMenuItem(value: valor, child: Text(valor.etiqueta)),
                )
                .toList(),
            child: Chip(
              avatar: const Icon(Icons.sort, size: 18),
              label: Text(orden.etiqueta),
            ),
          ),
          Text('$resultados materiales'),
        ],
      ),
    ],
  );

  Widget _chip(String etiqueta, FiltroImagenMaterial valor) => ChoiceChip(
    label: Text(etiqueta),
    selected: filtroImagen == valor,
    onSelected: (_) => alCambiarImagen(valor),
  );
}
