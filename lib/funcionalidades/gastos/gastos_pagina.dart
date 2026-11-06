import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../core/formato.dart';
import '../../core/theme/app_theme.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import '../../widgets/surface_card.dart';
import 'formulario_gasto.dart';
import 'gasto_tarjeta.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String _busqueda = '';
  int _filtro = -1;

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

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final proyectos = {
        for (final proyecto in estado.datos.proyectos) proyecto.id: proyecto,
      };
      final filtro = _filtro <= 0 || proyectos.containsKey(_filtro)
          ? _filtro
          : -1;
      String destino(Gasto gasto) {
        final proyecto = proyectos[gasto.proyectoId];
        return proyecto == null
            ? 'Gasto general'
            : '${proyecto.nombreCliente} · ${proyecto.descripcion}';
      }

      final gastos =
          estado.datos.gastos
              .where(
                (gasto) =>
                    (filtro == -1 || (gasto.proyectoId ?? 0) == filtro) &&
                    '${gasto.categoria} ${gasto.nota} ${destino(gasto)}'
                        .toLowerCase()
                        .contains(_busqueda.toLowerCase()),
              )
              .toList()
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
      final total = gastos.fold<int>(
        0,
        (suma, gasto) => suma + gasto.montoCentavos,
      );
      return PaginaBase(
        titulo: 'Gastos',
        accion: FilledButton.icon(
          onPressed: estado.guardando ? null : () => _editar(),
          icon: const Icon(Icons.add),
          label: const Text('Registrar gasto'),
        ),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CADA GASTO CUENTA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dinero(total),
                  style: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AppColors.cobalt,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${gastos.length} gastos en esta vista. Registra transporte, mano de obra y otros costos adicionales.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (valor) => setState(() => _busqueda = valor.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Buscar gasto, nota o proyecto',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey(filtro),
            value: filtro,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Filtrar por proyecto',
            ),
            items: [
              const DropdownMenuItem(
                value: -1,
                child: Text('Todos los gastos'),
              ),
              const DropdownMenuItem(value: 0, child: Text('Gastos generales')),
              ...proyectos.values.map(
                (proyecto) => DropdownMenuItem(
                  value: proyecto.id,
                  child: Text(
                    '${proyecto.nombreCliente} · ${proyecto.descripcion}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (valor) => setState(() => _filtro = valor ?? -1),
          ),
          const SizedBox(height: 16),
          if (gastos.isEmpty)
            EstadoVacio(
              icono: Icons.receipt_long_outlined,
              titulo: estado.datos.gastos.isEmpty
                  ? 'No pierdas de vista los pequeños gastos'
                  : 'Sin gastos en esta vista',
              mensaje: estado.datos.gastos.isEmpty
                  ? 'Registra un gasto y asígnalo a un proyecto o al balance general.'
                  : 'Cambia la búsqueda o el filtro para ver más registros.',
              accion: estado.datos.gastos.isEmpty
                  ? OutlinedButton(
                      onPressed: estado.guardando ? null : () => _editar(),
                      child: const Text('Registrar el primer gasto'),
                    )
                  : null,
            )
          else
            ...gastos.map(
              (gasto) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GastoTarjeta(
                  gasto: gasto,
                  destino: destino(gasto),
                  editar: estado.guardando ? null : () => _editar(gasto),
                  eliminar: estado.guardando ? null : () => _eliminar(gasto),
                ),
              ),
            ),
        ],
      );
    },
  );
}
