import 'package:flutter/material.dart';

import '../../core/formato.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../dominio/modelos.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import 'componentes/controles_cotizaciones.dart';
import 'componentes/tarjeta_proyecto.dart';
import 'detalle_proyecto_pagina.dart';
import 'editor_proyecto_pagina.dart';
import '../clientes/clientes_pagina.dart';
import '../../widgets/ayuda/temas_ayuda.dart';

class CotizacionesPagina extends StatefulWidget {
  const CotizacionesPagina({super.key});

  @override
  State<CotizacionesPagina> createState() => _CotizacionesPaginaState();
}

class _CotizacionesPaginaState extends State<CotizacionesPagina> {
  String _busqueda = '';
  EstadoProyecto? _estado;
  DateTimeRange? _rangoFechas;
  bool _verObras = false;
  FiltroObras _filtroObras = FiltroObras.todas;
  OrdenProyectos _orden = OrdenProyectos.recientes;

  void _crear() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const EditorProyectoPagina()));

  DateTime _fechaInicio(Proyecto proyecto) => _verObras
      ? proyecto.fechaInicioReal ?? proyecto.fechaInicio
      : proyecto.fechaInicio;

  List<Proyecto> _filtrar(List<Proyecto> origen) {
    final consulta = _busqueda.trim().toLowerCase();
    final resultado = origen.where((proyecto) {
      if (proyecto.esObra != _verObras) return false;
      if (!_verObras && _estado != null && proyecto.estado != _estado) {
        return false;
      }
      if (_verObras) {
        final coincide = switch (_filtroObras) {
          FiltroObras.todas => true,
          FiltroObras.enCurso => proyecto.estaEnCurso,
          FiltroObras.finalizadas => proyecto.estaFinalizada,
        };
        if (!coincide) return false;
      }
      final texto =
          '${proyecto.nombreCliente} ${proyecto.descripcion} ${codigosBusqueda(proyecto.id)}'
              .toLowerCase();
      if (consulta.isNotEmpty && !texto.contains(consulta)) return false;
      final rango = _rangoFechas;
      if (rango != null) {
        final fecha = _fechaInicio(proyecto);
        final limite = DateTime(
          rango.end.year,
          rango.end.month,
          rango.end.day + 1,
        );
        if (fecha.isBefore(rango.start) || !fecha.isBefore(limite)) {
          return false;
        }
      }
      return true;
    }).toList();
    switch (_orden) {
      case OrdenProyectos.recientes:
        resultado.sort((a, b) {
          final orden = b.creadoEl.compareTo(a.creadoEl);
          return orden != 0 ? orden : b.id.compareTo(a.id);
        });
      case OrdenProyectos.cliente:
        resultado.sort((a, b) => a.nombreCliente.compareTo(b.nombreCliente));
      case OrdenProyectos.fecha:
        resultado.sort((a, b) => _fechaInicio(b).compareTo(_fechaInicio(a)));
      case OrdenProyectos.importe:
        resultado.sort(
          (a, b) => b.totalCotizadoCentavos.compareTo(a.totalCotizadoCentavos),
        );
    }
    return resultado;
  }

  Future<void> _elegirPeriodo() async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
      initialDateRange: _rangoFechas,
      helpText: 'Filtrar por fecha de inicio',
    );
    if (rango != null && mounted) setState(() => _rangoFechas = rango);
  }

  void _cambiarTipo(bool verObras) => setState(() {
    _verObras = verObras;
    _estado = null;
    _filtroObras = FiltroObras.todas;
    _rangoFechas = null;
  });

  void _abrirDetalle(Proyecto proyecto) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DetalleProyectoPagina(proyectoId: proyecto.id),
    ),
  );

  @override
  Widget build(BuildContext context) => BlocBuilder<CotiCubit, EstadoCoti>(
    builder: (context, estado) {
      final todos = estado.datos.proyectos;
      final cotizaciones = todos.where((proyecto) => !proyecto.esObra).length;
      final obras = todos.where((proyecto) => proyecto.esObra).length;
      final proyectos = _filtrar(todos);
      final ancho = MediaQuery.sizeOf(context).width;
      final mostrarAccionMovil = ancho < 840 && todos.isNotEmpty;
      return Scaffold(
        body: PaginaBase(
          titulo: 'Cotizaciones',
          ayuda: TemaAyuda.cotizaciones,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: const Text(
                    'Tus proyectos, desde el presupuesto hasta la entrega.',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ClientesPagina(),
                    ),
                  ),
                  icon: const Icon(Icons.people_outline),
                  label: const Text('Clientes'),
                ),
                if (ancho >= 840 && todos.isNotEmpty)
                  FilledButton.icon(
                    onPressed: _crear,
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva cotización'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ControlesCotizaciones(
              verObras: _verObras,
              totalCotizaciones: cotizaciones,
              totalObras: obras,
              busqueda: _busqueda,
              etapa: _estado,
              filtroObras: _filtroObras,
              rangoFechas: _rangoFechas,
              orden: _orden,
              totalResultados: proyectos.length,
              alCambiarTipo: _cambiarTipo,
              alBuscar: (texto) => setState(() => _busqueda = texto),
              alCambiarEstado: (valor) => setState(() => _estado = valor),
              alCambiarFiltroObras: (valor) =>
                  setState(() => _filtroObras = valor),
              alElegirPeriodo: _elegirPeriodo,
              alLimpiarPeriodo: () => setState(() => _rangoFechas = null),
              alOrdenar: (valor) => setState(() => _orden = valor),
            ),
            const SizedBox(height: 16),
            if (proyectos.isEmpty)
              _estadoVacio(todos)
            else
              for (final proyecto in proyectos)
                TarjetaProyecto(
                  proyecto: proyecto,
                  alAbrir: () => _abrirDetalle(proyecto),
                ),
            if (mostrarAccionMovil) const SizedBox(height: 76),
          ],
        ),
        floatingActionButton: mostrarAccionMovil
            ? FloatingActionButton.extended(
                heroTag: 'nueva-cotizacion',
                onPressed: _crear,
                icon: const Icon(Icons.add),
                label: const Text('Nueva cotización'),
              )
            : null,
      );
    },
  );

  Widget _estadoVacio(List<Proyecto> todos) {
    final totalSeccion = todos
        .where((proyecto) => proyecto.esObra == _verObras)
        .length;
    final primeraCotizacion = totalSeccion == 0 && !_verObras;
    return EstadoVacio(
      icono: Icons.request_quote_outlined,
      titulo: primeraCotizacion
          ? 'Tu próxima cotización empieza aquí'
          : 'No hay coincidencias',
      mensaje: primeraCotizacion
          ? 'Añade un cliente, tus materiales y el precio que quieres cotizar. '
                'Todo se guarda en este dispositivo.'
          : totalSeccion == 0 && _verObras
          ? 'Aprueba una cotización y comienza la obra para verla aquí.'
          : 'Prueba con otro texto o ajusta los filtros seleccionados.',
      accion: primeraCotizacion
          ? FilledButton.icon(
              onPressed: _crear,
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primera cotización'),
            )
          : null,
    );
  }
}
