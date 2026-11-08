import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dominio/modelos.dart';
import 'seccion_cotizacion.dart';

class AccionesObra extends StatelessWidget {
  const AccionesObra({
    super.key,
    required this.proyecto,
    required this.guardando,
    required this.alIniciar,
    required this.alFinalizar,
  });

  final Proyecto proyecto;
  final bool guardando;
  final Future<void> Function(DateTime fecha) alIniciar;
  final Future<void> Function(DateTime fecha) alFinalizar;

  Future<DateTime?> _pedirInicio(BuildContext context) async {
    final hoy = _soloFecha(DateTime.now());
    var seleccion = hoy;
    return showDialog<DateTime>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, actualizar) => AlertDialog(
          title: const Text('Iniciar obra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'La cotización se marcará como aprobada y pasará a Obras. '
                'Confirma que el cliente aceptó el trabajo.',
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: seleccion,
                    firstDate: DateTime(2000),
                    lastDate: hoy,
                    helpText: 'Inicio real de la obra',
                    cancelText: 'Cancelar',
                    confirmText: 'Seleccionar',
                  );
                  if (fecha != null) actualizar(() => seleccion = fecha);
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Inicio real: ${fechaCorta(seleccion)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, seleccion),
              child: const Text('Iniciar obra'),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pedirFinalizacion(BuildContext context) async {
    final hoy = _soloFecha(DateTime.now());
    var seleccion = hoy;
    return showDialog<DateTime>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, actualizar) => AlertDialog(
          title: const Text('Finalizar obra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Registra el día en que culminó el trabajo. La fecha prevista '
                'se conservará para comparar el plazo.',
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: seleccion,
                    firstDate: proyecto.fechaInicioReal!,
                    lastDate: hoy,
                    helpText: 'Finalización real de la obra',
                    cancelText: 'Cancelar',
                    confirmText: 'Seleccionar',
                  );
                  if (fecha != null) actualizar(() => seleccion = fecha);
                },
                icon: const Icon(Icons.event_available_outlined),
                label: Text('Finalización real: ${fechaCorta(seleccion)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aún no termino'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, seleccion),
              child: const Text('Finalizar obra'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retrasada = proyecto.estaRetrasada(DateTime.now());
    return SeccionCotizacion(
      titulo: proyecto.esObra ? 'Ejecución de la obra' : 'Convertir en obra',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (retrasada) ...[
            Material(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Obra en retraso · ${proyecto.diasDeRetraso(DateTime.now())} '
                  '${proyecto.diasDeRetraso(DateTime.now()) == 1 ? 'día' : 'días'}',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (proyecto.fechaInicioReal != null)
            Text('Inicio real: ${fechaCorta(proyecto.fechaInicioReal!)}'),
          if (proyecto.fechaFinReal != null)
            Text('Finalización real: ${fechaCorta(proyecto.fechaFinReal!)}'),
          if (proyecto.estaFinalizada && proyecto.fechaInicioReal == null)
            const Text(
              'Fechas reales no registradas en este proyecto histórico.',
            ),
          if (!proyecto.esObra)
            FilledButton.icon(
              onPressed: guardando
                  ? null
                  : () async {
                      final fecha = await _pedirInicio(context);
                      if (fecha != null) await alIniciar(fecha);
                    },
              icon: const Icon(Icons.construction_outlined),
              label: const Text('Iniciar obra'),
            ),
          if (proyecto.estaEnCurso) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: guardando
                  ? null
                  : () async {
                      final fecha = await _pedirFinalizacion(context);
                      if (fecha != null) await alFinalizar(fecha);
                    },
              icon: const Icon(Icons.task_alt_outlined),
              label: const Text('Finalizar obra'),
            ),
          ],
        ],
      ),
    );
  }
}

DateTime _soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);
