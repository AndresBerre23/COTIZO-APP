import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/coti_cubit.dart';
import '../../../core/formato.dart';
import '../../../dominio/calcular_cobros_proyecto.dart';
import '../../../dominio/modelos.dart';
import '../../ingresos/formulario_devolucion.dart';
import '../../ingresos/formulario_ingreso.dart';
import 'seccion_cotizacion.dart';
import '../../../widgets/ayuda/temas_ayuda.dart';

// Anticipos y abonos de un proyecto con su saldo pendiente (P-011).
class CobrosProyectoDetalle extends StatelessWidget {
  const CobrosProyectoDetalle({
    super.key,
    required this.proyecto,
    required this.ingresos,
    required this.guardando,
    this.adicionales = const [],
    this.devoluciones = const [],
  });

  final Proyecto proyecto;
  final List<Ingreso> ingresos;
  final bool guardando;
  final List<Adicional> adicionales;
  final List<Gasto> devoluciones;

  Future<void> _registrar(BuildContext context) async {
    final cubit = context.read<CotiCubit>();
    final ingreso = await mostrarFormularioIngreso(
      context,
      proyectos: cubit.state.datos.proyectos,
      proyectoId: proyecto.id,
    );
    if (ingreso == null || !context.mounted) return;
    final guardado = await cubit.guardarIngreso(ingreso);
    if (guardado && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cobro registrado en el proyecto')),
      );
    }
  }

  Future<void> _devolver(BuildContext context, int cobrado) async {
    final cubit = context.read<CotiCubit>();
    final devolucion = await mostrarFormularioDevolucion(
      context,
      proyecto: proyecto,
      maximoCentavos: cobrado,
    );
    if (devolucion != null) await cubit.guardarGasto(devolucion);
  }

  @override
  Widget build(BuildContext context) {
    final cobros = calcularCobrosProyecto(
      proyecto,
      ingresos,
      adicionales: adicionales,
      gastos: devoluciones,
    );
    final colores = Theme.of(context).colorScheme;
    final saldo = cobros.saldoCentavos;
    return SeccionCotizacion(
      titulo: 'Cobros',
      ayuda: TemaAyuda.cobros,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              _Dato('Cobrado', dinero(cobros.cobradoCentavos), colores.primary),
              _Dato(
                saldo < 0 ? 'Cobrado de más' : 'Saldo pendiente',
                dinero(saldo.abs()),
                saldo > 0 ? colores.error : colores.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: cobros.avance),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, valor, _) => LinearProgressIndicator(
                value: valor,
                minHeight: 8,
                color: colores.secondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: guardando || !proyecto.admiteGastos
                    ? null
                    : () => _registrar(context),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Registrar cobro'),
              ),
              if (cobros.cobradoCentavos > 0)
                TextButton.icon(
                  onPressed: guardando
                      ? null
                      : () => _devolver(context, cobros.cobradoCentavos),
                  icon: const Icon(Icons.undo),
                  label: const Text('Registrar devolución'),
                ),
            ],
          ),
          if (!proyecto.admiteGastos) ...[
            const SizedBox(height: 8),
            Text(
              'Aprueba la cotización para registrar anticipos y abonos.',
              style: TextStyle(color: colores.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          if (ingresos.isEmpty)
            const Text('Aún no hay cobros registrados en este proyecto.'),
          for (final devolucion in devoluciones)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.undo, color: colores.error),
              title: const Text('Devolución al cliente'),
              subtitle: Text(
                '${fechaCorta(devolucion.fecha)} · ${devolucion.nota}',
              ),
              trailing: Text(
                '- ${dinero(devolucion.montoCentavos)}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: colores.error,
                ),
              ),
            ),
          for (final ingreso in ingresos)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.south_west),
              title: Text('${ingreso.categoria} · ${ingreso.metodo.etiqueta}'),
              subtitle: Text(
                ingreso.nota.isEmpty
                    ? fechaCorta(ingreso.fecha)
                    : '${fechaCorta(ingreso.fecha)} · ${ingreso.nota}',
              ),
              trailing: Text(
                dinero(ingreso.montoCentavos),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor, this.color);

  final String etiqueta;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        etiqueta,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        valor,
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: color,
        ),
      ),
    ],
  );
}
