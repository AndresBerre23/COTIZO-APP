import 'package:flutter/material.dart';

import '../../core/formato.dart';

class FiltrosDocumentos {
  const FiltrosDocumentos({this.etapa, this.rangoFechas});

  final String? etapa;
  final DateTimeRange? rangoFechas;
}

Future<FiltrosDocumentos?> mostrarFiltrosDocumentos(
  BuildContext contexto, {
  required bool mostrarEtapa,
  required String? etapaInicial,
  required DateTimeRange? rangoInicial,
}) async {
  var etapa = etapaInicial;
  var rango = rangoInicial;
  return showModalBottomSheet<FiltrosDocumentos>(
    context: contexto,
    isScrollControlled: true,
    builder: (contextoHoja) => StatefulBuilder(
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
                'Filtrar documentos',
                style: Theme.of(contextoHoja).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (mostrarEtapa) ...[
                DropdownButtonFormField<String?>(
                  value: etapa,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todos los estados'),
                    ),
                    for (final valor in [
                      'Borrador',
                      'Enviado',
                      'Aprobado',
                      'En curso',
                      'Finalizada',
                    ])
                      DropdownMenuItem<String?>(
                        value: valor,
                        child: Text(valor),
                      ),
                  ],
                  onChanged: (valor) => actualizar(() => etapa = valor),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () async {
                  final elegido = await showDateRangePicker(
                    context: contextoHoja,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2200),
                    initialDateRange: rango,
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
                        Navigator.pop(contextoHoja, const FiltrosDocumentos()),
                    child: const Text('Limpiar filtros'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      contextoHoja,
                      FiltrosDocumentos(etapa: etapa, rangoFechas: rango),
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
