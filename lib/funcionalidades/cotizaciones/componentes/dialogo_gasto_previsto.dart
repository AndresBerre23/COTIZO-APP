import 'package:flutter/material.dart';
import 'package:cotizo_app/core/enfoque.dart';

import '../../../core/formato.dart';
import '../../../dominio/categorias_gasto.dart';
import '../../../dominio/modelos.dart';

class DialogoGastoPrevisto extends StatefulWidget {
  const DialogoGastoPrevisto({super.key, this.gasto});

  final GastoPrevisto? gasto;

  @override
  State<DialogoGastoPrevisto> createState() => _DialogoGastoPrevistoState();
}

class _DialogoGastoPrevistoState extends State<DialogoGastoPrevisto> {
  late final TextEditingController _importe;
  late final TextEditingController _descripcion;
  final _formulario = GlobalKey<FormState>();
  late String _categoria;

  @override
  void initState() {
    super.initState();
    final gasto = widget.gasto;
    final categoriaGuardada = gasto?.categoria;
    _categoria = categoriaGuardada == categoriaManoObra
        ? categoriaPagoTrabajadores
        : categoriaGuardada ?? categoriasGastoPrevisto.first;
    _importe = TextEditingController(
      text: gasto == null ? '' : (gasto.montoCentavos / 100).toStringAsFixed(2),
    );
    _descripcion = TextEditingController(text: gasto?.descripcion ?? '');
  }

  @override
  void dispose() {
    _importe.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formulario.currentState!.validate()) return;
    final gasto = widget.gasto;
    Navigator.pop(
      context,
      GastoPrevisto(
        id: gasto?.id ?? 0,
        proyectoId: gasto?.proyectoId ?? 0,
        categoria: _categoria,
        montoCentavos: leerCentavos(_importe.text)!,
        descripcion: _descripcion.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.gasto == null ? 'Añadir gasto previsto' : 'Editar gasto previsto',
    ),
    content: Form(
      key: _formulario,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _categoria,
            decoration: InputDecoration(
              labelText: 'Categoría',
              helperText: switch (_categoria) {
                'Materiales adicionales' =>
                  'Usa esta opción para materiales que no estén en las partidas.',
                categoriaPagoTrabajadores =>
                  'Registra pagos previstos a ayudantes o personal contratado.',
                _ => null,
              },
            ),
            items: categoriasGastoPrevisto
                .map(
                  (valor) => DropdownMenuItem(value: valor, child: Text(valor)),
                )
                .toList(),
            onChanged: (valor) {
              if (valor != null) setState(() => _categoria = valor);
            },
          ),
          TextFormField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: _importe,
            decoration: const InputDecoration(
              labelText: 'Importe previsto',
              prefixText: '\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validarImporte,
          ),
          TextField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: _descripcion,
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
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _guardar, child: const Text('Guardar')),
    ],
  );
}
