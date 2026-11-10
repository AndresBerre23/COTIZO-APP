import 'package:flutter/material.dart';

enum FiltroImagenMaterial { todos, conImagen, sinImagen }

enum OrdenMateriales {
  recientes('Más recientes'),
  nombre('Nombre A-Z'),
  unidad('Unidad A-Z'),
  mayorCosto('Mayor costo'),
  menorCosto('Menor costo');

  const OrdenMateriales(this.etiqueta);
  final String etiqueta;
}

class SeleccionUnidadMaterial {
  const SeleccionUnidadMaterial(this.unidad);

  final String? unidad;
}

Future<SeleccionUnidadMaterial?> mostrarFiltroUnidadMaterial(
  BuildContext contexto, {
  required List<String> unidades,
  required String? unidadActual,
}) => showModalBottomSheet<SeleccionUnidadMaterial>(
  context: contexto,
  isScrollControlled: true,
  builder: (contextoHoja) {
    var unidad = unidadActual;
    return StatefulBuilder(
      builder: (contextoHoja, actualizar) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(contextoHoja).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filtrar por unidad',
                style: Theme.of(contextoHoja).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: unidad,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todas las unidades'),
                  ),
                  for (final valor in unidades)
                    DropdownMenuItem<String?>(value: valor, child: Text(valor)),
                ],
                onChanged: (valor) => actualizar(() => unidad = valor),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(
                      contextoHoja,
                      const SeleccionUnidadMaterial(null),
                    ),
                    child: const Text('Quitar filtro'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      contextoHoja,
                      SeleccionUnidadMaterial(unidad),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);
