import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import 'dialogo_gasto_previsto.dart';
import 'seccion_cotizacion.dart';

class GastosPrevistosEditor extends StatelessWidget {
  const GastosPrevistosEditor({
    super.key,
    required this.gastos,
    required this.alCambiar,
  });

  final List<GastoPrevisto> gastos;
  final ValueChanged<List<GastoPrevisto>> alCambiar;

  Future<void> _editar(BuildContext context, [int? indice]) async {
    final anterior = indice == null ? null : gastos[indice];
    final actualizado = await showDialog<GastoPrevisto>(
      context: context,
      builder: (_) => DialogoGastoPrevisto(gasto: anterior),
    );
    if (actualizado != null && context.mounted) {
      final actualizados = List<GastoPrevisto>.of(gastos);
      if (indice == null) {
        actualizados.add(actualizado);
      } else {
        actualizados[indice] = actualizado;
      }
      alCambiar(actualizados);
    }
  }

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: 'Gastos previstos',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Presupuesta transporte, alimentación, mano de obra y otros costos antes de cotizar.',
        ),
        for (var indice = 0; indice < gastos.length; indice++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(gastos[indice].categoria),
            subtitle: gastos[indice].descripcion.isEmpty
                ? null
                : Text(gastos[indice].descripcion),
            leading: IconButton(
              onPressed: () => alCambiar(
                gastos.where((gasto) => gasto != gastos[indice]).toList(),
              ),
              icon: Icon(Icons.delete_outline),
              tooltip: 'Quitar gasto previsto',
            ),
            trailing: Text(
              dinero(gastos[indice].montoCentavos),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () => _editar(context, indice),
          ),
        OutlinedButton.icon(
          onPressed: () => _editar(context),
          icon: Icon(Icons.add),
          label: Text('Añadir gasto previsto'),
        ),
      ],
    ),
  );
}
