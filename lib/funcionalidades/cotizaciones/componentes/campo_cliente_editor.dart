import 'package:flutter/material.dart';

import '../../../core/enfoque.dart';
import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../utilidades/datos_proforma_editor.dart';

// Nombre del cliente con sugerencias de la lista y datos de contacto (P-021).
class CampoClienteEditor extends StatefulWidget {
  const CampoClienteEditor({
    super.key,
    required this.nombre,
    required this.datos,
    required this.clientes,
    required this.alElegir,
  });

  final TextEditingController nombre;
  final DatosProformaEditor datos;
  final List<Cliente> clientes;
  final ValueChanged<Cliente> alElegir;

  @override
  State<CampoClienteEditor> createState() => _CampoClienteEditorState();
}

class _CampoClienteEditorState extends State<CampoClienteEditor> {
  final _foco = FocusNode();

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  Iterable<Cliente> _sugerencias(TextEditingValue valor) {
    final consulta = valor.text.trim().toLowerCase();
    if (consulta.isEmpty) return const [];
    return widget.clientes
        .where((cliente) => cliente.nombre.toLowerCase().contains(consulta))
        .take(6);
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controlador, [
    TextInputType teclado = TextInputType.text,
  ]) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      onTapOutside: cerrarFocoAlTocarFuera,
      controller: controlador,
      keyboardType: teclado,
      maxLength: 200,
      decoration: InputDecoration(labelText: etiqueta, counterText: ''),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RawAutocomplete<Cliente>(
          textEditingController: widget.nombre,
          focusNode: _foco,
          displayStringForOption: (cliente) => cliente.nombre,
          optionsBuilder: _sugerencias,
          onSelected: widget.alElegir,
          fieldViewBuilder: (context, controlador, foco, alEnviar) =>
              TextFormField(
                onTapOutside: cerrarFocoAlTocarFuera,
                controller: controlador,
                focusNode: foco,
                validator: validarRequerido,
                textCapitalization: TextCapitalization.words,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Cliente / titular',
                  helperText: 'Escribe para buscar en tus clientes',
                ),
              ),
          optionsViewBuilder: (context, alElegir, opciones) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 240,
                  maxWidth: 520,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    for (final cliente in opciones)
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(cliente.nombre),
                        subtitle: cliente.tieneContacto
                            ? Text(
                                [
                                  cliente.identificacion,
                                  cliente.telefono,
                                ].where((d) => d.isNotEmpty).join(' · '),
                              )
                            : null,
                        onTap: () => alElegir(cliente),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: const Text('Datos de contacto (opcional)'),
          subtitle: const Text('Aparecen en la proforma'),
          initiallyExpanded:
              datos.identificacion.text.isNotEmpty ||
              datos.telefono.text.isNotEmpty,
          children: [
            _campo('RUC o cédula', datos.identificacion),
            _campo('Teléfono', datos.telefono, TextInputType.phone),
            _campo('Correo', datos.correo, TextInputType.emailAddress),
            _campo('Dirección', datos.direccion),
          ],
        ),
      ],
    );
  }
}
