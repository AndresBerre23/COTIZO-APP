import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/cotizo_cubit.dart';
import '../../../core/formato.dart';
import '../../../dominio/calcular_cobros_proyecto.dart';
import '../../../dominio/modelos.dart';
import '../../ingresos/formulario_ingreso.dart';
import 'seccion_cotizacion.dart';

// Anticipos y abonos de un proyecto con su saldo pendiente (P-011).
class CobrosProyectoDetalle extends StatelessWidget {
  const CobrosProyectoDetalle({
    super.key,
    required this.proyecto,
    required this.ingresos,
    required this.guardando,
  });

  final Proyecto proyecto;
  final List<Ingreso> ingresos;
  final bool guardando;

  Future<void> _registrar(BuildContext context) async {
    final cubit = context.read<CotizoCubit>();
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

  @override
  Widget build(BuildContext context) {
    final cobros = calcularCobrosProyecto(proyecto, ingresos);
    final colores = Theme.of(context).colorScheme;
    final saldo = cobros.saldoCentavos;
    return SeccionCotizacion(
      titulo: 'Cobros',
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
          OutlinedButton.icon(
            onPressed: guardando || !proyecto.admiteGastos
                ? null
                : () => _registrar(context),
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Registrar cobro'),
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
