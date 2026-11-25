import 'package:flutter/material.dart';
import 'package:cotizo_app/core/enfoque.dart';

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';

class ControlesCotizaciones extends StatelessWidget {
  const ControlesCotizaciones({
    super.key,
    required this.verObras,
    required this.totalCotizaciones,
    required this.totalObras,
    required this.busqueda,
    required this.etapa,
    required this.filtroObras,
    required this.rangoFechas,
    required this.orden,
    required this.totalResultados,
    required this.alCambiarTipo,
    required this.alBuscar,
    required this.alCambiarEstado,
    required this.alCambiarFiltroObras,
    required this.alElegirPeriodo,
    required this.alLimpiarPeriodo,
    required this.alOrdenar,
  });

  final bool verObras;
  final int totalCotizaciones;
  final int totalObras;
  final String busqueda;
  final EstadoProyecto? etapa;
  final FiltroObras filtroObras;
  final DateTimeRange? rangoFechas;
  final OrdenProyectos orden;
  final int totalResultados;
  final ValueChanged<bool> alCambiarTipo;
  final ValueChanged<String> alBuscar;
  final ValueChanged<EstadoProyecto?> alCambiarEstado;
  final ValueChanged<FiltroObras> alCambiarFiltroObras;
  final VoidCallback alElegirPeriodo;
  final VoidCallback alLimpiarPeriodo;
  final ValueChanged<OrdenProyectos> alOrdenar;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SegmentedButton<bool>(
        segments: [
          ButtonSegment(
            value: false,
            icon: const Icon(Icons.request_quote_outlined),
            label: Text('Cotizaciones ($totalCotizaciones)'),
          ),
          ButtonSegment(
            value: true,
            icon: const Icon(Icons.construction_outlined),
            label: Text('Obras ($totalObras)'),
          ),
        ],
        selected: {verObras},
        onSelectionChanged: (seleccion) => alCambiarTipo(seleccion.single),
      ),
      const SizedBox(height: 16),
      TextField(
        onTapOutside: cerrarFocoAlTocarFuera,
        onChanged: alBuscar,
        decoration: InputDecoration(
          labelText: 'Buscar cliente, proyecto o código',
          hintText: 'Ej.: COT-0012',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: busqueda.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  onPressed: () => alBuscar(''),
                  icon: const Icon(Icons.close),
                ),
        ),
      ),
      const SizedBox(height: 12),
      _filtrosEstado(),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: alElegirPeriodo,
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              rangoFechas == null
                  ? 'Fecha de inicio'
                  : '${fechaCorta(rangoFechas!.start)} – ${fechaCorta(rangoFechas!.end)}',
            ),
          ),
          if (rangoFechas != null)
            IconButton(
              tooltip: 'Quitar filtro de fecha',
              onPressed: alLimpiarPeriodo,
              icon: const Icon(Icons.close),
            ),
          PopupMenuButton<OrdenProyectos>(
            initialValue: orden,
            onSelected: alOrdenar,
            itemBuilder: (contexto) => OrdenProyectos.values
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

  Widget _filtrosEstado() => SizedBox(
    height: 44,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: verObras
            ? [
                for (final filtro in FiltroObras.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filtro.etiqueta),
                      selected: filtroObras == filtro,
                      onSelected: (_) => alCambiarFiltroObras(filtro),
                    ),
                  ),
              ]
            : [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: etapa == null,
                  onSelected: (_) => alCambiarEstado(null),
                ),
                for (final filtro in EstadoProyecto.values.where(
                  (opcion) => opcion != EstadoProyecto.finalizado,
                ))
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(filtro.etiqueta),
                      selected: etapa == filtro,
                      onSelected: (_) => alCambiarEstado(filtro),
                    ),
                  ),
              ],
      ),
    ),
  );
}

enum FiltroObras {
  todas('Todas'),
  enCurso('En curso'),
  finalizadas('Finalizadas');

  const FiltroObras(this.etiqueta);
  final String etiqueta;
}

enum OrdenProyectos {
  recientes('Más recientes'),
  cliente('Cliente A-Z'),
  fecha('Inicio más reciente'),
  importe('Mayor importe');

  const OrdenProyectos(this.etiqueta);
  final String etiqueta;
}
