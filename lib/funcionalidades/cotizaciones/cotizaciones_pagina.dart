import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../dominio/modelos.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import 'componentes/tarjeta_proyecto.dart';
import 'detalle_proyecto_pagina.dart';
import 'editor_proyecto_pagina.dart';

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  String _busqueda = '';
  EstadoProyecto? _estado;
  bool _verObras = false;
  _FiltroObras _filtroObras = _FiltroObras.todas;

  void _crear() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const EditorProyectoPagina()));

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final proyectos = estado.datos.proyectos.where((proyecto) {
        final texto = '${proyecto.nombreCliente} ${proyecto.descripcion}'
            .toLowerCase();
        if (!texto.contains(_busqueda) || proyecto.esObra != _verObras) {
          return false;
        }
        if (!_verObras) return _estado == null || proyecto.estado == _estado;
        return switch (_filtroObras) {
          _FiltroObras.todas => true,
          _FiltroObras.enCurso => proyecto.estaEnCurso,
          _FiltroObras.finalizadas => proyecto.estaFinalizada,
        };
      }).toList();
      return PaginaBase(
        titulo: 'Cotizaciones',
        accion: FilledButton.icon(
          onPressed: _crear,
          icon: const Icon(Icons.add),
          label: const Text('Nueva cotización'),
        ),
        children: [
          const Text('Tus proyectos, desde el presupuesto hasta la entrega.'),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.request_quote_outlined),
                label: Text('Cotizaciones'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.construction_outlined),
                label: Text('Obras'),
              ),
            ],
            selected: {_verObras},
            onSelectionChanged: (seleccion) => setState(() {
              _verObras = seleccion.single;
              _estado = null;
              _filtroObras = _FiltroObras.todas;
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (texto) =>
                setState(() => _busqueda = texto.trim().toLowerCase()),
            decoration: const InputDecoration(
              labelText: 'Buscar cliente o proyecto',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (!_verObras)
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: _estado == null,
                  onSelected: (_) => setState(() => _estado = null),
                ),
              for (final filtro
                  in _verObras
                      ? const <EstadoProyecto>[]
                      : EstadoProyecto.values.where(
                          (opcion) => opcion != EstadoProyecto.finalizado,
                        ))
                ChoiceChip(
                  label: Text(filtro.etiqueta),
                  selected: _estado == filtro,
                  onSelected: (_) => setState(() => _estado = filtro),
                ),
              if (_verObras)
                for (final filtro in _FiltroObras.values)
                  ChoiceChip(
                    label: Text(filtro.etiqueta),
                    selected: _filtroObras == filtro,
                    onSelected: (_) => setState(() => _filtroObras = filtro),
                  ),
            ],
          ),
          const SizedBox(height: 20),
          if (proyectos.isEmpty)
            EstadoVacio(
              icono: Icons.request_quote_outlined,
              titulo: estado.datos.proyectos.isEmpty && !_verObras
                  ? 'Tu próxima cotización empieza aquí'
                  : 'No hay coincidencias',
              mensaje: estado.datos.proyectos.isEmpty && !_verObras
                  ? 'Añade un cliente, tus materiales y el precio que '
                        'quieres cotizar. Todo se guarda en este dispositivo.'
                  : _verObras
                  ? 'Inicia una cotización aceptada o cambia el filtro seleccionado.'
                  : 'Prueba con otro cliente o cambia el estado seleccionado.',
              accion: estado.datos.proyectos.isEmpty && !_verObras
                  ? FilledButton(
                      onPressed: _crear,
                      child: const Text('Crear mi primera cotización'),
                    )
                  : null,
            ),
          for (final proyecto in proyectos)
            TarjetaProyecto(
              proyecto: proyecto,
              alAbrir: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      DetalleProyectoPagina(proyectoId: proyecto.id),
                ),
              ),
            ),
        ],
      );
    },
  );
}

enum _FiltroObras {
  todas('Todas'),
  enCurso('En curso'),
  finalizadas('Finalizadas');

  const _FiltroObras(this.etiqueta);
  final String etiqueta;
}
