import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dominio/categorias_gasto.dart';
import '../../../dominio/modelos.dart';
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
    var categoria = anterior?.categoria ?? categoriasGasto.first;
    final importe = TextEditingController(
      text: anterior == null
          ? ''
          : (anterior.montoCentavos / 100).toStringAsFixed(2),
    );
    final descripcion = TextEditingController(
      text: anterior?.descripcion ?? '',
    );
    final formulario = GlobalKey<FormState>();
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, actualizar) => AlertDialog(
          title: Text(
            anterior == null
                ? 'Añadir gasto previsto'
                : 'Editar gasto previsto',
          ),
          content: Form(
            key: formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    helperText: categoria == 'Materiales adicionales'
                        ? 'Usa esta opción para materiales que no estén '
                              'en las partidas.'
                        : null,
                  ),
                  items: categoriasGasto
                      .map(
                        (valor) =>
                            DropdownMenuItem(value: valor, child: Text(valor)),
                      )
                      .toList(),
                  onChanged: (valor) =>
                      actualizar(() => categoria = valor ?? categoria),
                ),
                TextFormField(
                  controller: importe,
                  decoration: const InputDecoration(
                    labelText: 'Importe previsto',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: validarImporte,
                ),
                TextField(
                  controller: descripcion,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                  ),
                  maxLength: 2000,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, formulario.currentState!.validate()),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (aceptado == true && context.mounted) {
      final nuevo = GastoPrevisto(
        id: anterior?.id ?? 0,
        proyectoId: anterior?.proyectoId ?? 0,
        categoria: categoria,
        montoCentavos: leerCentavos(importe.text)!,
        descripcion: descripcion.text.trim(),
      );
      final actualizados = List<GastoPrevisto>.of(gastos);
      if (indice == null) {
        actualizados.add(nuevo);
      } else {
        actualizados[indice] = nuevo;
      }
      alCambiar(actualizados);
    }
    importe.dispose();
    descripcion.dispose();
  }

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: '2. Gastos previstos',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
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
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Quitar gasto previsto',
            ),
            trailing: Text(
              dinero(gastos[indice].montoCentavos),
              style: const TextStyle(
                color: AppColors.cobalt,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () => _editar(context, indice),
          ),
        OutlinedButton.icon(
          onPressed: () => _editar(context),
          icon: const Icon(Icons.add),
          label: const Text('Añadir gasto previsto'),
        ),
      ],
    ),
  );
}
