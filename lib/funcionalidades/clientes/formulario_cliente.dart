import 'package:flutter/material.dart';

import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';

Future<Cliente?> mostrarFormularioCliente(
  BuildContext context, {
  Cliente? cliente,
}) => showDialog<Cliente>(
  context: context,
  builder: (_) => _FormularioCliente(cliente: cliente),
);

class _FormularioCliente extends StatefulWidget {
  const _FormularioCliente({this.cliente});

  final Cliente? cliente;

  @override
  State<_FormularioCliente> createState() => _FormularioClienteState();
}

class _FormularioClienteState extends State<_FormularioCliente> {
  final _formulario = GlobalKey<FormState>();
  late final _campos = {
    'Nombre': TextEditingController(text: widget.cliente?.nombre),
    'RUC o cédula': TextEditingController(text: widget.cliente?.identificacion),
    'Teléfono': TextEditingController(text: widget.cliente?.telefono),
    'Correo': TextEditingController(text: widget.cliente?.correo),
    'Dirección': TextEditingController(text: widget.cliente?.direccion),
  };

  @override
  void dispose() {
    for (final campo in _campos.values) {
      campo.dispose();
    }
    super.dispose();
  }

  String _valor(String etiqueta) => _campos[etiqueta]!.text.trim();

  void _aceptar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.pop(
      context,
      Cliente(
        id: widget.cliente?.id ?? 0,
        nombre: _valor('Nombre'),
        identificacion: _valor('RUC o cédula'),
        telefono: _valor('Teléfono'),
        correo: _valor('Correo'),
        direccion: _valor('Dirección'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.cliente == null ? 'Nuevo cliente' : 'Editar cliente'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final MapEntry(:key, :value) in _campos.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    onTapOutside: cerrarFocoAlTocarFuera,
                    controller: value,
                    maxLength: key == 'Nombre' ? 120 : 200,
                    textCapitalization: key == 'Nombre'
                        ? TextCapitalization.words
                        : TextCapitalization.none,
                    keyboardType: switch (key) {
                      'Teléfono' => TextInputType.phone,
                      'Correo' => TextInputType.emailAddress,
                      _ => TextInputType.text,
                    },
                    decoration: InputDecoration(
                      labelText: key,
                      counterText: '',
                    ),
                    validator: key == 'Nombre' ? validarRequerido : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _aceptar, child: const Text('Guardar cliente')),
    ],
  );
}
