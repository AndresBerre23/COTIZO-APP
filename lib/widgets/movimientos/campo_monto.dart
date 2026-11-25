import 'package:flutter/material.dart';

import '../../core/enfoque.dart';
import '../../core/formato.dart';

// Campo de importe destacado para gastos e ingresos.
class CampoMonto extends StatelessWidget {
  const CampoMonto({super.key, required this.controlador});

  final TextEditingController controlador;

  @override
  Widget build(BuildContext context) => TextFormField(
    onTapOutside: cerrarFocoAlTocarFuera,
    controller: controlador,
    autofocus: true,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textInputAction: TextInputAction.next,
    style: const TextStyle(
      fontFamily: 'monospace',
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
    validator: validarImporte,
  );
}
