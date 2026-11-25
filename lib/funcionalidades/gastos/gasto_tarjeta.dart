import 'package:flutter/material.dart';

import '../../dominio/modelos.dart';
import '../../widgets/tarjeta_movimiento.dart';

class GastoTarjeta extends StatelessWidget {
  const GastoTarjeta({
    super.key,
    required this.gasto,
    required this.destino,
    required this.editar,
    required this.eliminar,
  });

  final Gasto gasto;
  final String destino;
  final VoidCallback? editar;
  final VoidCallback? eliminar;

  @override
  Widget build(BuildContext context) => TarjetaMovimiento(
    movimiento: gasto,
    destino: destino,
    esIngreso: false,
    tooltipOpciones: 'Opciones del gasto',
    editar: editar,
    eliminar: eliminar,
  );
}
