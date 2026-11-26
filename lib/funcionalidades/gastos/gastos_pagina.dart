import 'package:flutter/material.dart';
import 'package:coti/core/enfoque.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import '../../widgets/surface_card.dart';
import '../movimientos/utilidades/filtrar_movimientos.dart';
import 'componentes/controles_gastos.dart';
import 'filtros_gastos.dart';
import '../obra/formulario_consumo.dart';
import 'formulario_gasto.dart';
import 'gasto_tarjeta.dart';
import '../../widgets/ayuda/temas_ayuda.dart';

class GastosPagina extends StatefulWidget {
  const GastosPagina({super.key, this.titulo = 'Gastos', this.encabezado});

  final String titulo;

  // Contenido opcional sobre la descripción, como el selector de Movimientos.
  final Widget? encabezado;

  @override
  State<GastosPagina> createState() => _GastosPaginaState();
}

class _GastosPaginaState extends State<GastosPagina> {
  String _busqueda = '';
  String? _categoria;
  DateTimeRange? _rangoFechas;
  FiltroAsignacionGasto _asignacion = FiltroAsignacionGasto.todos;
  OrdenGastos _orden = OrdenGastos.recientes;

  Future<void> _editar([Gasto? existente]) async {
    final cubit = context.read<CotiCubit>();
    final gasto = existente?.esConsumo ?? false
        ? await mostrarFormularioConsumo(
            context,
            proyectoId: existente!.proyectoId ?? 0,
            materiales: cubit.state.datos.materiales,
            consumo: existente,
          )
        : await mostrarFormularioGasto(
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
    final eliminado = await context.read<CotiCubit>().eliminarGasto(gasto.id);
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

  @override
  Widget build(BuildContext context) => BlocBuilder<CotiCubit, EstadoCoti>(
    builder: (context, estado) {
      final todos = estado.datos.gastos;
      final proyectos = {
        for (final proyecto in estado.datos.proyectos) proyecto.id: proyecto,
      };
      final gastos = filtrarMovimientos(
        todos,
        CriteriosMovimientos(
          busqueda: _busqueda,
          categoria: _categoria,
          rangoFechas: _rangoFechas,
          asignacion: _asignacion,
          orden: _orden,
        ),
        proyectos,
        etiquetaGeneral: 'gasto general',
      );
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
          titulo: widget.titulo,
          ayuda: TemaAyuda.movimientos,
          children: [
            if (widget.encabezado != null) widget.encabezado!,
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
                hintText: 'Ej.: COT-0012',
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
                    destino: destinoMovimiento(
                      gasto,
                      proyectos,
                      etiquetaGeneral: 'Gasto general',
                    ),
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
