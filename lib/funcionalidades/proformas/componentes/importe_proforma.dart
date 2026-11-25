import 'package:flutter/material.dart';

import '../../../core/formato.dart';

// Fila de etiqueta e importe usada en la proforma y su desglose.
class ImporteProforma extends StatelessWidget {
  const ImporteProforma(
    this.etiqueta,
    this.centavos, {
    super.key,
    this.destacado = false,
  });

  final String etiqueta;
  final int centavos;
  final bool destacado;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Wrap(
      spacing: 20,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            fontWeight: destacado ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          dinero(centavos),
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            fontSize: destacado ? 22 : 15,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    ),
  );
}
