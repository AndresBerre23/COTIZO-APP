import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../dominio/categorias_gasto.dart';

class FiltrosGastos {
  const FiltrosGastos({this.categoria, this.rangoFechas});

  final String? categoria;
  final DateTimeRange? rangoFechas;
}

Future<FiltrosGastos?> mostrarFiltrosGastos(
  BuildContext contexto, {
  required String? categoriaInicial,
  required DateTimeRange? rangoInicial,
}) {
  var categoria = categoriaInicial;
  var rango = rangoInicial;
  final categorias = [...categoriasGasto];
  if (categoria != null && !categorias.contains(categoria)) {
    categorias.add(categoria);
  }
  return showModalBottomSheet<FiltrosGastos>(
    context: contexto,
    isScrollControlled: true,
    builder: (contextoHoja) => StatefulBuilder(
      builder: (contextoHoja, actualizar) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(contextoHoja).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filtrar gastos',
                style: Theme.of(contextoHoja).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: categoria,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todas las categorías'),
                  ),
                  for (final opcion in categorias)
                    DropdownMenuItem<String?>(
                      value: opcion,
                      child: Text(opcion),
                    ),
                ],
                onChanged: (valor) => actualizar(() => categoria = valor),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final elegido = await showDateRangePicker(
                    context: contextoHoja,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2200),
                    initialDateRange: rango,
                    helpText: 'Filtrar por fecha del gasto',
                  );
                  if (elegido != null) actualizar(() => rango = elegido);
                },
                icon: const Icon(Icons.date_range_outlined),
                label: Text(_etiquetaRango(rango)),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(contextoHoja, const FiltrosGastos()),
                    child: const Text('Limpiar filtros'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      contextoHoja,
                      FiltrosGastos(categoria: categoria, rangoFechas: rango),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _etiquetaRango(DateTimeRange? rango) => rango == null
    ? 'Elegir período'
    : '${fechaCorta(rango.start)} – ${fechaCorta(rango.end)}';
