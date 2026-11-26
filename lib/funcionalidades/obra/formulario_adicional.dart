import 'package:flutter/material.dart';

import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/movimientos/campo_monto.dart';

// Trabajo extra que el cliente aceptó durante la obra (P-031).
Future<Adicional?> mostrarFormularioAdicional(
  BuildContext context, {
  required Proyecto proyecto,
  Adicional? adicional,
}) => showDialog<Adicional>(
  context: context,
  builder: (_) =>
      _FormularioAdicional(proyecto: proyecto, adicional: adicional),
);

class _FormularioAdicional extends StatefulWidget {
  const _FormularioAdicional({required this.proyecto, this.adicional});

  final Proyecto proyecto;
  final Adicional? adicional;

  @override
  State<_FormularioAdicional> createState() => _FormularioAdicionalState();
}

class _FormularioAdicionalState extends State<_FormularioAdicional> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _descripcion;
  late final TextEditingController _monto;

  @override
  void initState() {
    super.initState();
    final adicional = widget.adicional;
    _descripcion = TextEditingController(text: adicional?.descripcion);
    _monto = TextEditingController(
      text: adicional == null
          ? ''
          : (adicional.montoCentavos / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _descripcion.dispose();
    _monto.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.pop(
      context,
      Adicional(
        id: widget.adicional?.id ?? 0,
        proyectoId: widget.proyecto.id,
        descripcion: _descripcion.text.trim(),
        montoCentavos: leerCentavos(_monto.text)!,
        fecha: widget.adicional?.fecha ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monto = leerCentavos(_monto.text) ?? 0;
    final iva = widget.proyecto.ivaDe(monto);
    return AlertDialog(
      title: Text(
        widget.adicional == null ? 'Registrar adicional' : 'Editar adicional',
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formulario,
            onChanged: () => setState(() {}),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Un adicional aumenta lo que el cliente te debe y genera '
                  'su propia orden de cambio en PDF.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  onTapOutside: cerrarFocoAlTocarFuera,
                  controller: _descripcion,
                  maxLength: 500,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Trabajo adicional',
                    hintText: 'Ej.: Instalar dos tomacorrientes extra',
                  ),
                  validator: validarRequerido,
                ),
                CampoMonto(controlador: _monto),
                const SizedBox(height: 8),
                Text(
                  widget.proyecto.ivaPuntos == null
                      ? 'Sin IVA, como la proforma.'
                      : 'Con IVA: ${dinero(monto + iva)}',
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
        FilledButton(
          onPressed: _aceptar,
          child: const Text('Guardar adicional'),
        ),
      ],
    );
  }
}
