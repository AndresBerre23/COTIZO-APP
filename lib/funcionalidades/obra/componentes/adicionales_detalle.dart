import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/coti_cubit.dart';
import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/confirmar.dart';
import '../../cotizaciones/componentes/seccion_cotizacion.dart';
import '../formulario_adicional.dart';
import '../servicios/compartir_documentos_obra.dart';
import '../../../widgets/ayuda/temas_ayuda.dart';

// Trabajos extra acordados y su orden de cambio (P-031).
class AdicionalesDetalle extends StatelessWidget {
  const AdicionalesDetalle({
    super.key,
    required this.proyecto,
    required this.adicionales,
    required this.guardando,
  });

  final Proyecto proyecto;
  final List<Adicional> adicionales;
  final bool guardando;

  Future<void> _editar(BuildContext context, [Adicional? adicional]) async {
    final cubit = context.read<CotiCubit>();
    final editado = await mostrarFormularioAdicional(
      context,
      proyecto: proyecto,
      adicional: adicional,
    );
    if (editado != null) await cubit.guardarAdicional(editado);
  }

  Future<void> _eliminar(BuildContext context, Adicional adicional) async {
    final cubit = context.read<CotiCubit>();
    if (await confirmarEliminacion(
      context,
      '¿Eliminar el adicional "${adicional.descripcion}"? '
      'Se descontará del total a cobrar.',
    )) {
      await cubit.eliminarAdicional(adicional.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = adicionales.fold(0, (s, a) => s + a.montoCentavos);
    return SeccionCotizacion(
      titulo: 'Adicionales',
      ayuda: TemaAyuda.adicionales,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            adicionales.isEmpty
                ? 'Si el cliente pide trabajo extra, regístralo para cobrarlo '
                      'y enviarle su orden de cambio.'
                : 'Suman ${dinero(proyecto.conIva(total))} al total a cobrar.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          for (var i = 0; i < adicionales.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('A${i + 1}')),
              title: Text(adicionales[i].descripcion),
              subtitle: Text(
                '${fechaCorta(adicionales[i].fecha)} · '
                '${dinero(proyecto.conIva(adicionales[i].montoCentavos))}',
              ),
              onTap: guardando ? null : () => _editar(context, adicionales[i]),
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: 'Compartir orden de cambio',
                    onPressed: () => compartirAdicional(
                      context,
                      proyecto,
                      adicionales[i],
                      i + 1,
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                  IconButton(
                    tooltip: 'Eliminar adicional',
                    onPressed: guardando
                        ? null
                        : () => _eliminar(context, adicionales[i]),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: guardando || !proyecto.admiteGastos
                ? null
                : () => _editar(context),
            icon: const Icon(Icons.add_task),
            label: const Text('Registrar adicional'),
          ),
        ],
      ),
    );
  }
}
