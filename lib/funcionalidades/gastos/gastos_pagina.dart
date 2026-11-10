import 'package:flutter/material.dart';
import 'package:cotizo_app/core/enfoque.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import '../../widgets/surface_card.dart';
import 'componentes/controles_gastos.dart';
import 'filtros_gastos.dart';
import 'formulario_gasto.dart';
import 'gasto_tarjeta.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String _busqueda = '';
  String? _categoria;
  DateTimeRange? _rangoFechas;
  FiltroAsignacionGasto _asignacion = FiltroAsignacionGasto.todos;
  OrdenGastos _orden = OrdenGastos.recientes;

  Future<void> _editar([Gasto? existente]) async {
    final cubit = context.read<CotizoCubit>();
    final gasto = await mostrarFormularioGasto(
      context,
      proyectos: cubit.state.datos.proyectos,
      gasto: existente,
    );
    if (gasto == null || !mounted) return;
    final guardado = await cubit.guardarGasto(gasto);
    if (guardado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto guardado. Tu rentabilidad está actualizada.'),
        ),
      );
    }
  }

  Future<void> _eliminar(Gasto gasto) async {
    final confirmado = await confirmarEliminacion(
      context,
      '¿Eliminar el gasto de ${dinero(gasto.montoCentavos)}? Se recalculará el balance.',
    );
    if (!confirmado || !mounted) return;
    final eliminado = await context.read<CotizoCubit>().eliminarGasto(gasto.id);
    if (eliminado && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto eliminado.')));
    }
  }

  Future<void> _mostrarFiltros() async {
    final filtros = await mostrarFiltrosGastos(
      context,
      categoriaInicial: _categoria,
      rangoInicial: _rangoFechas,
    );
    if (filtros == null || !mounted) return;
    setState(() {
      _categoria = filtros.categoria;
      _rangoFechas = filtros.rangoFechas;
    });
  }

  List<Gasto> _filtrar(List<Gasto> gastos, Map<int, Proyecto> proyectos) {
    final consulta = _busqueda.trim().toLowerCase();
    final resultado = gastos.where((gasto) {
      final esGeneral = gasto.proyectoId == null;
      if (_asignacion == FiltroAsignacionGasto.generales && !esGeneral) {
        return false;
      }
      if (_asignacion == FiltroAsignacionGasto.proyectos && esGeneral) {
        return false;
      }
      if (_categoria != null && gasto.categoria != _categoria) return false;
      final proyecto = proyectos[gasto.proyectoId];
      final destino = proyecto == null
          ? 'gasto general'
          : '${proyecto.nombreCliente} ${proyecto.descripcion} '
                'COT-${proyecto.id.toString().padLeft(3, '0')}';
      final texto = '${gasto.categoria} ${gasto.nota} $destino'.toLowerCase();
      if (consulta.isNotEmpty && !texto.contains(consulta)) return false;
      final rango = _rangoFechas;
      if (rango != null) {
        final limite = DateTime(
          rango.end.year,
          rango.end.month,
          rango.end.day + 1,
        );
        if (gasto.fecha.isBefore(rango.start) ||
            !gasto.fecha.isBefore(limite)) {
          return false;
        }
      }
      return true;
    }).toList();
    switch (_orden) {
      case OrdenGastos.recientes:
        resultado.sort((a, b) => b.fecha.compareTo(a.fecha));
      case OrdenGastos.antiguos:
        resultado.sort((a, b) => a.fecha.compareTo(b.fecha));
      case OrdenGastos.mayorImporte:
        resultado.sort((a, b) => b.montoCentavos.compareTo(a.montoCentavos));
      case OrdenGastos.menorImporte:
        resultado.sort((a, b) => a.montoCentavos.compareTo(b.montoCentavos));
    }
    return resultado;
  }

  String _destino(Gasto gasto, Map<int, Proyecto> proyectos) {
    final proyecto = proyectos[gasto.proyectoId];
    return proyecto == null
        ? 'Gasto general'
        : '${proyecto.nombreCliente} · ${proyecto.descripcion}';
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final todos = estado.datos.gastos;
      final proyectos = {
        for (final proyecto in estado.datos.proyectos) proyecto.id: proyecto,
      };
      final gastos = _filtrar(todos, proyectos);
      final total = gastos.fold<int>(
        0,
        (suma, gasto) => suma + gasto.montoCentavos,
      );
      final gastosDeProyecto = todos
          .where((gasto) => gasto.proyectoId != null)
          .length;
      final gastosGenerales = todos
          .where((gasto) => gasto.proyectoId == null)
          .length;
      final ancho = MediaQuery.sizeOf(context).width;
      final mostrarAccionMovil = ancho < 840 && todos.isNotEmpty;
      return Scaffold(
        body: PaginaBase(
          titulo: 'Gastos',
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    'Registra y encuentra los costos de tus proyectos y gastos generales.',
                  ),
                ),
                if (ancho >= 840 && todos.isNotEmpty)
                  FilledButton.icon(
                    onPressed: estado.guardando ? null : () => _editar(),
                    icon: Icon(Icons.add),
                    label: Text('Registrar gasto'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onTapOutside: cerrarFocoAlTocarFuera,
              onChanged: (valor) => setState(() => _busqueda = valor),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar categoría, nota, proyecto o código',
                hintText: 'Ej.: COT-012',
                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () => setState(() => _busqueda = ''),
                        icon: Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            ControlesGastos(
              total: todos.length,
              deProyecto: gastosDeProyecto,
              generales: gastosGenerales,
              totalResultados: gastos.length,
              asignacion: _asignacion,
              categoria: _categoria,
              rangoFechas: _rangoFechas,
              orden: _orden,
              alCambiarAsignacion: (valor) =>
                  setState(() => _asignacion = valor),
              alMostrarFiltros: _mostrarFiltros,
              alOrdenar: (valor) => setState(() => _orden = valor),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL DE LA VISTA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dinero(total),
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${gastos.length} gastos encontrados.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (gastos.isEmpty)
              _estadoVacio(todos, estado.guardando)
            else
              for (final gasto in gastos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GastoTarjeta(
                    gasto: gasto,
                    destino: _destino(gasto, proyectos),
                    editar: estado.guardando ? null : () => _editar(gasto),
                    eliminar: estado.guardando ? null : () => _eliminar(gasto),
                  ),
                ),
            if (mostrarAccionMovil) const SizedBox(height: 76),
          ],
        ),
        floatingActionButton: mostrarAccionMovil
            ? FloatingActionButton.extended(
                heroTag: 'registrar-gasto',
                onPressed: estado.guardando ? null : () => _editar(),
                icon: Icon(Icons.add),
                label: Text('Registrar gasto'),
              )
            : null,
      );
    },
  );

  Widget _estadoVacio(List<Gasto> todos, bool guardando) => EstadoVacio(
    icono: Icons.receipt_long_outlined,
    titulo: todos.isEmpty
        ? 'No pierdas de vista los pequeños gastos'
        : 'Sin gastos en esta vista',
    mensaje: todos.isEmpty
        ? 'Registra un gasto y asígnalo a un proyecto o al balance general.'
        : 'Cambia la búsqueda o los filtros para ver otros registros.',
    accion: todos.isEmpty
        ? OutlinedButton(
            onPressed: guardando ? null : () => _editar(),
            child: Text('Registrar el primer gasto'),
          )
        : null,
  );
}
