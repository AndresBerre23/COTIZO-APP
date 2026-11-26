import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/coti_cubit.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/confirmar.dart';

// Elimina un proyecto sin dinero; si tiene cobros o gastos, lo cancela (D-025).
class AccionCierreProyecto extends StatelessWidget {
  const AccionCierreProyecto({
    super.key,
    required this.proyecto,
    required this.datos,
    required this.guardando,
  });

  final Proyecto proyecto;
  final DatosLocales datos;
  final bool guardando;

  String get _nombre => proyecto.esObra ? 'obra' : 'cotización';

  Future<void> _eliminar(BuildContext context) async {
    final cubit = context.read<CotiCubit>();
    final navegador = Navigator.of(context);
    if (!await confirmarEliminacion(
      context,
      'Se eliminará esta $_nombre con sus materiales y fotos. El catálogo de '
      'materiales se conserva. Esta acción no se puede deshacer.',
    )) {
      return;
    }
    if (await cubit.eliminarProyecto(proyecto.id)) navegador.pop();
  }

  Future<void> _cambiarEstado(
    BuildContext context,
    EstadoProyecto estado,
    String mensaje,
    String accion,
  ) async {
    final cubit = context.read<CotiCubit>();
    if (!await confirmarAccion(
      context,
      titulo: '$accion $_nombre',
      mensaje: mensaje,
      accion: accion,
    )) {
      return;
    }
    await cubit.guardarProyecto(
      proyecto.conEstado(estado),
      datos.itemsDeProyecto(proyecto.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    if (proyecto.estado == EstadoProyecto.cancelado) {
      return TextButton.icon(
        onPressed: guardando
            ? null
            : () => _cambiarEstado(
                context,
                proyecto.esObra
                    ? EstadoProyecto.aprobado
                    : EstadoProyecto.enviado,
                'Volverá a estar activa con todos sus registros.',
                'Reactivar',
              ),
        icon: const Icon(Icons.restore),
        label: Text('Reactivar $_nombre'),
      );
    }
    final conDinero = datos.tieneMovimientos(proyecto.id);
    return TextButton.icon(
      onPressed: guardando
          ? null
          : conDinero
          ? () => _cambiarEstado(
              context,
              EstadoProyecto.cancelado,
              'Tiene cobros o gastos registrados, así que no se elimina: '
                  'queda como cancelada y conserva su historial. Si devolviste '
                  'dinero al cliente, regístralo en Cobros.',
              'Cancelar',
            )
          : () => _eliminar(context),
      style: TextButton.styleFrom(foregroundColor: error),
      icon: Icon(conDinero ? Icons.block : Icons.delete_outline),
      label: Text('${conDinero ? 'Cancelar' : 'Eliminar'} $_nombre'),
    );
  }
}
