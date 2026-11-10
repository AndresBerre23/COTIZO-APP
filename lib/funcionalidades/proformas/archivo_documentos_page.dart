import 'package:flutter/material.dart';
import 'package:cotizo_app/core/enfoque.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../dominio/modelos.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import 'filtros_documentos.dart';
import 'proforma_documento_page.dart';
import 'reporte_cierre_page.dart';
import 'tarjeta_documento.dart';

class ArchivoDocumentosPage extends StatefulWidget {
  const ArchivoDocumentosPage({super.key});

  @override
  State<ArchivoDocumentosPage> createState() => _ArchivoDocumentosPageState();
}

class _ArchivoDocumentosPageState extends State<ArchivoDocumentosPage> {
  String _busqueda = '';
  String? _etapaFiltro;
  DateTimeRange? _rangoFechas;
  _OrdenDocumentos _orden = _OrdenDocumentos.recientes;
  bool _verReportes = false;

  DateTime _fechaDocumento(Proyecto proyecto) => _verReportes
      ? proyecto.fechaFinReal ?? proyecto.fechaInicio
      : proyecto.fechaInicio;

  List<Proyecto> _filtrar(List<Proyecto> proyectos) {
    final consulta = _busqueda.trim().toLowerCase();
    final resultado = proyectos.where((proyecto) {
      if (_verReportes && !proyecto.estaFinalizada) return false;
      if (!_verReportes &&
          _etapaFiltro != null &&
          proyecto.etapa != _etapaFiltro) {
        return false;
      }
      final codigo3 = 'cot-${proyecto.id.toString().padLeft(3, '0')}';
      final codigo4 = 'cot-${proyecto.id.toString().padLeft(4, '0')}';
      final texto =
          '${proyecto.nombreCliente} ${proyecto.descripcion} $codigo3 $codigo4 ${proyecto.id}'
              .toLowerCase();
      if (consulta.isNotEmpty && !texto.contains(consulta)) return false;
      final rango = _rangoFechas;
      if (rango != null) {
        final fecha = _fechaDocumento(proyecto);
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
      case _OrdenDocumentos.recientes:
        resultado.sort((a, b) => b.id.compareTo(a.id));
      case _OrdenDocumentos.cliente:
        resultado.sort((a, b) => a.nombreCliente.compareTo(b.nombreCliente));
      case _OrdenDocumentos.fecha:
        resultado.sort(
          (a, b) => _fechaDocumento(b).compareTo(_fechaDocumento(a)),
        );
      case _OrdenDocumentos.importe:
        resultado.sort(
          (a, b) => b.totalCotizadoCentavos.compareTo(a.totalCotizadoCentavos),
        );
    }
    return resultado;
  }

  Future<void> _mostrarFiltros() async {
    final filtros = await mostrarFiltrosDocumentos(
      context,
      mostrarEtapa: !_verReportes,
      etapaInicial: _etapaFiltro,
      rangoInicial: _rangoFechas,
    );
    if (filtros == null || !mounted) return;
    setState(() {
      _etapaFiltro = filtros.etapa;
      _rangoFechas = filtros.rangoFechas;
    });
  }

  void _abrirDocumento(Proyecto proyecto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _verReportes
            ? ReporteCierrePage(proyectoId: proyecto.id)
            : ProformaDocumentoPage(proyectoId: proyecto.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final todos = estado.datos.proyectos;
      final resultados = _filtrar(todos);
      final cierres = todos.where((proyecto) => proyecto.estaFinalizada).length;
      final totalTipo = _verReportes ? cierres : todos.length;
      final filtrosActivos =
          (_etapaFiltro == null ? 0 : 1) + (_rangoFechas == null ? 0 : 1);
      return PaginaBase(
        titulo: 'Documentos',
        children: [
          const Text(
            'Encuentra, consulta y comparte los documentos de tus obras.',
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.description_outlined),
                label: Text('Proformas (${todos.length})'),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.assignment_turned_in_outlined),
                label: Text('Cierres ($cierres)'),
              ),
            ],
            selected: {_verReportes},
            onSelectionChanged: (seleccion) => setState(() {
              _verReportes = seleccion.single;
              _etapaFiltro = null;
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            onTapOutside: cerrarFocoAlTocarFuera,
            onChanged: (texto) => setState(() => _busqueda = texto),
            decoration: InputDecoration(
              labelText: 'Buscar cliente, proyecto o código',
              hintText: 'Ej.: COT-012',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busqueda.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () => setState(() => _busqueda = ''),
                      icon: const Icon(Icons.close),
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
                onPressed: _mostrarFiltros,
                icon: const Icon(Icons.filter_list),
                label: Text(
                  filtrosActivos == 0 ? 'Filtrar' : 'Filtrar ($filtrosActivos)',
                ),
              ),
              PopupMenuButton<_OrdenDocumentos>(
                initialValue: _orden,
                onSelected: (valor) => setState(() => _orden = valor),
                itemBuilder: (contexto) => _OrdenDocumentos.values
                    .map(
                      (valor) => PopupMenuItem(
                        value: valor,
                        child: Text(valor.etiqueta),
                      ),
                    )
                    .toList(),
                child: Chip(
                  avatar: const Icon(Icons.sort, size: 18),
                  label: Text(_orden.etiqueta),
                ),
              ),
              Text('${resultados.length} de $totalTipo'),
            ],
          ),
          const SizedBox(height: 16),
          if (resultados.isEmpty)
            EstadoVacio(
              icono: _verReportes
                  ? Icons.assignment_outlined
                  : Icons.description_outlined,
              titulo: totalTipo == 0
                  ? _verReportes
                        ? 'Aún no hay obras finalizadas'
                        : 'Aún no hay cotizaciones'
                  : 'No hay coincidencias',
              mensaje: totalTipo == 0
                  ? _verReportes
                        ? 'Los reportes de cierre estarán disponibles cuando finalices una obra.'
                        : 'Las proformas de tus cotizaciones aparecerán aquí.'
                  : 'Prueba con otro texto o limpia los filtros.',
            )
          else
            for (final proyecto in resultados)
              TarjetaDocumento(
                proyecto: proyecto,
                esReporte: _verReportes,
                fecha: _fechaDocumento(proyecto),
                alAbrir: () => _abrirDocumento(proyecto),
              ),
        ],
      );
    },
  );
}

enum _OrdenDocumentos {
  recientes('Más recientes'),
  cliente('Cliente A-Z'),
  fecha('Fecha del proyecto'),
  importe('Mayor importe');

  const _OrdenDocumentos(this.etiqueta);
  final String etiqueta;
}
