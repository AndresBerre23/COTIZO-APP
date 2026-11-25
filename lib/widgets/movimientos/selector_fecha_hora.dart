import 'package:flutter/material.dart';

import '../../core/formato.dart';

// Botones para cambiar la fecha y la hora conservando el otro dato.
class SelectorFechaHora extends StatelessWidget {
  const SelectorFechaHora({
    super.key,
    required this.fecha,
    required this.alCambiar,
  });

  final DateTime fecha;
  final ValueChanged<DateTime> alCambiar;

  Future<void> _elegirFecha(BuildContext context) async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (elegida == null) return;
    alCambiar(
      DateTime(
        elegida.year,
        elegida.month,
        elegida.day,
        fecha.hour,
        fecha.minute,
        fecha.second,
        fecha.millisecond,
      ),
    );
  }

  Future<void> _elegirHora(BuildContext context) async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fecha),
    );
    if (elegida == null) return;
    alCambiar(
      DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        elegida.hour,
        elegida.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      OutlinedButton.icon(
        onPressed: () => _elegirFecha(context),
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text('Fecha: ${fechaCorta(fecha)}'),
      ),
      OutlinedButton.icon(
        onPressed: () => _elegirHora(context),
        icon: const Icon(Icons.schedule_outlined),
        label: Text('Hora: ${horaCorta(fecha)}'),
      ),
    ],
  );
}
