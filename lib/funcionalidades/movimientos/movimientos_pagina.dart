import 'package:flutter/material.dart';

import '../gastos/gastos_pagina.dart';
import '../ingresos/ingresos_pagina.dart';
import 'componentes/tarjeta_balance_mes.dart';

enum TipoMovimiento { gastos, ingresos }

// Pestaña que reúne gastos e ingresos con el balance del mes (P-012).
class MovimientosPagina extends StatefulWidget {
  const MovimientosPagina({super.key});

  @override
  State<MovimientosPagina> createState() => _MovimientosPaginaState();
}

class _MovimientosPaginaState extends State<MovimientosPagina> {
  TipoMovimiento _tipo = TipoMovimiento.gastos;

  @override
  Widget build(BuildContext context) {
    final encabezado = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TarjetaBalanceMes(),
        const SizedBox(height: 16),
        SegmentedButton<TipoMovimiento>(
          segments: const [
            ButtonSegment(
              value: TipoMovimiento.gastos,
              icon: Icon(Icons.north_east),
              label: Text('Gastos'),
            ),
            ButtonSegment(
              value: TipoMovimiento.ingresos,
              icon: Icon(Icons.south_west),
              label: Text('Ingresos'),
            ),
          ],
          selected: {_tipo},
          onSelectionChanged: (seleccion) =>
              setState(() => _tipo = seleccion.first),
        ),
        const SizedBox(height: 20),
      ],
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _tipo == TipoMovimiento.gastos
          ? GastosPagina(
              key: const ValueKey(TipoMovimiento.gastos),
              titulo: 'Movimientos',
              encabezado: encabezado,
            )
          : IngresosPagina(
              key: const ValueKey(TipoMovimiento.ingresos),
              titulo: 'Movimientos',
              encabezado: encabezado,
            ),
    );
  }
}
