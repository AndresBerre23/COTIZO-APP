import 'package:flutter/material.dart';

import '../../../core/formato.dart';

class FechasProyecto extends StatelessWidget {
  const FechasProyecto({
    super.key,
    required this.inicio,
    required this.fin,
    required this.alCambiarInicio,
    required this.alCambiarFin,
  });

  final DateTime inicio;
  final DateTime? fin;
  final ValueChanged<DateTime> alCambiarInicio;
  final ValueChanged<DateTime?> alCambiarFin;

  Future<void> _elegir(BuildContext context, bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio ? inicio : (fin ?? inicio),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      helpText: esInicio ? 'Fecha de inicio' : 'Fecha de entrega',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    if (fecha == null) return;
    esInicio ? alCambiarInicio(fecha) : alCambiarFin(fecha);
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      OutlinedButton.icon(
        onPressed: () => _elegir(context, true),
        icon: const Icon(Icons.calendar_today_outlined, size: 18),
        label: Text('Inicio: ${fechaCorta(inicio)}'),
      ),
      OutlinedButton.icon(
        onPressed: () => _elegir(context, false),
        icon: const Icon(Icons.event_outlined, size: 18),
        label: Text(
          fin == null ? 'Definir entrega' : 'Entrega: ${fechaCorta(fin!)}',
        ),
      ),
      if (fin != null)
        IconButton(
          onPressed: () => alCambiarFin(null),
          tooltip: 'Quitar fecha de entrega',
          icon: const Icon(Icons.close),
        ),
    ],
  );
}
