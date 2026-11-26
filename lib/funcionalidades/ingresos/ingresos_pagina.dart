import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/categorias_ingreso.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import '../../widgets/surface_card.dart';
import '../../widgets/tarjeta_movimiento.dart';
import '../gastos/componentes/controles_gastos.dart';
import '../gastos/filtros_gastos.dart';
import '../movimientos/utilidades/filtrar_movimientos.dart';
import 'formulario_ingreso.dart';
import '../../widgets/ayuda/temas_ayuda.dart';

// Lista de cobros e ingresos con búsqueda, filtros y total (P-012).
class IngresosPagina extends StatefulWidget {
  const IngresosPagina({super.key, this.titulo = 'Ingresos', this.encabezado});

  final String titulo;
  final Widget? encabezado;

  @override
  State<IngresosPagina> createState() => _IngresosPaginaState();
}

class _IngresosPaginaState extends State<IngresosPagina> {
  String _busqueda = '';
  String? _categoria;
  DateTimeRange? _rangoFechas;
  FiltroAsignacionGasto _asignacion = FiltroAsignacionGasto.todos;
  OrdenGastos _orden = OrdenGastos.recientes;

  Future<void> _editar([Ingreso? existente]) async {
    final cubit = context.read<CotiCubit>();
    final ingreso = await mostrarFormularioIngreso(
      context,
      proyectos: cubit.state.datos.proyectos,
      ingreso: existente,
    );
    if (ingreso == null || !mounted) return;
    final guardado = await cubit.guardarIngreso(ingreso);
    if (guardado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingreso guardado en este dispositivo.')),
      );
    }
  }

  Future<void> _eliminar(Ingreso ingreso) async {
    final confirmado = await confirmarEliminacion(
      context,
      '¿Eliminar el ingreso de ${dinero(ingreso.montoCentavos)}? '
      'Se recalcularán el balance y el saldo del proyecto.',
    );
    if (!confirmado || !mounted) return;
    final eliminado = await context.read<CotiCubit>().eliminarIngreso(
      ingreso.id,
    );
    if (eliminado && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingreso eliminado.')));
    }
  }

  Future<void> _mostrarFiltros() async {
    final filtros = await mostrarFiltrosGastos(
      context,
      categoriaInicial: _categoria,
      rangoInicial: _rangoFechas,
      categoriasDisponibles: categoriasIngreso,
      titulo: 'Filtrar ingresos',
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
      final todos = estado.datos.ingresos;
      final proyectos = {
        for (final proyecto in estado.datos.proyectos) proyecto.id: proyecto,
      };
      final ingresos = filtrarMovimientos(
        todos,
        CriteriosMovimientos(
          busqueda: _busqueda,
          categoria: _categoria,
          rangoFechas: _rangoFechas,
          asignacion: _asignacion,
          orden: _orden,
        ),
        proyectos,
        etiquetaGeneral: 'ingreso general',
      );
      final total = ingresos.fold<int>(0, (s, i) => s + i.montoCentavos);
      final deProyecto = todos.where((i) => i.proyectoId != null).length;
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
                  child: const Text(
                    'Registra anticipos, abonos y otros ingresos para conocer tu balance real.',
                  ),
                ),
                if (ancho >= 840 && todos.isNotEmpty)
                  FilledButton.icon(
                    onPressed: estado.guardando ? null : () => _editar(),
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar ingreso'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onTapOutside: cerrarFocoAlTocarFuera,
              onChanged: (valor) => setState(() => _busqueda = valor),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Buscar categoría, nota, proyecto o código',
                hintText: 'Ej.: COT-0012',
                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () => setState(() => _busqueda = ''),
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            ControlesGastos(
              total: todos.length,
              deProyecto: deProyecto,
              generales: todos.length - deProyecto,
              totalResultados: ingresos.length,
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
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${ingresos.length} ingresos encontrados.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (ingresos.isEmpty)
              _estadoVacio(todos, estado.guardando)
            else
              for (final ingreso in ingresos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TarjetaMovimiento(
                    movimiento: ingreso,
                    esIngreso: true,
                    tooltipOpciones: 'Opciones del ingreso',
                    detalle: ingreso.metodo.etiqueta,
                    destino: destinoMovimiento(
                      ingreso,
                      proyectos,
                      etiquetaGeneral: 'Ingreso general',
                    ),
                    editar: estado.guardando ? null : () => _editar(ingreso),
                    eliminar: estado.guardando
                        ? null
                        : () => _eliminar(ingreso),
                  ),
                ),
            if (mostrarAccionMovil) const SizedBox(height: 76),
          ],
        ),
        floatingActionButton: mostrarAccionMovil
            ? FloatingActionButton.extended(
                heroTag: 'registrar-ingreso',
                onPressed: estado.guardando ? null : () => _editar(),
                icon: const Icon(Icons.add),
                label: const Text('Registrar ingreso'),
              )
            : null,
      );
    },
  );

  Widget _estadoVacio(List<Ingreso> todos, bool guardando) => EstadoVacio(
    icono: Icons.savings_outlined,
    titulo: todos.isEmpty
        ? 'Registra lo que cobras'
        : 'Sin ingresos en esta vista',
    mensaje: todos.isEmpty
        ? 'Anota anticipos, abonos y ventas para ver cuánto entra realmente.'
        : 'Cambia la búsqueda o los filtros para ver otros registros.',
    accion: todos.isEmpty
        ? OutlinedButton(
            onPressed: guardando ? null : () => _editar(),
            child: const Text('Registrar el primer ingreso'),
          )
        : null,
  );
}
