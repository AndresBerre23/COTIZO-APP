import 'package:flutter/material.dart';

import '../../movimientos/utilidades/filtrar_movimientos.dart';

export '../../movimientos/utilidades/filtrar_movimientos.dart'
    show FiltroAsignacionGasto, OrdenGastos;

class ControlesGastos extends StatelessWidget {
  const ControlesGastos({
    super.key,
    required this.total,
    required this.deProyecto,
    required this.generales,
    required this.totalResultados,
    required this.asignacion,
    required this.categoria,
    required this.rangoFechas,
    required this.orden,
    required this.alCambiarAsignacion,
    required this.alMostrarFiltros,
    required this.alOrdenar,
  });

  final int total;
  final int deProyecto;
  final int generales;
  final int totalResultados;
  final FiltroAsignacionGasto asignacion;
  final String? categoria;
  final DateTimeRange? rangoFechas;
  final OrdenGastos orden;
  final ValueChanged<FiltroAsignacionGasto> alCambiarAsignacion;
  final VoidCallback alMostrarFiltros;
  final ValueChanged<OrdenGastos> alOrdenar;

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
              _chip('Todos ($total)', FiltroAsignacionGasto.todos),
              const SizedBox(width: 8),
              _chip(
                'De proyecto ($deProyecto)',
                FiltroAsignacionGasto.proyectos,
              ),
              const SizedBox(width: 8),
              _chip('Generales ($generales)', FiltroAsignacionGasto.generales),
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
            onPressed: alMostrarFiltros,
            icon: const Icon(Icons.filter_list),
            label: Text(
              categoria == null && rangoFechas == null
                  ? 'Más filtros'
                  : 'Más filtros (${(categoria == null ? 0 : 1) + (rangoFechas == null ? 0 : 1)})',
            ),
          ),
          PopupMenuButton<OrdenGastos>(
            initialValue: orden,
            onSelected: alOrdenar,
            itemBuilder: (contexto) => OrdenGastos.values
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
          Text('$totalResultados resultados'),
        ],
      ),
    ],
  );

  Widget _chip(String etiqueta, FiltroAsignacionGasto valor) => ChoiceChip(
    label: Text(etiqueta),
    selected: asignacion == valor,
    onSelected: (_) => alCambiarAsignacion(valor),
  );
}
