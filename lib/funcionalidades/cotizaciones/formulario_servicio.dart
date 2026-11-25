import 'package:flutter/material.dart';

import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';

// Partida de servicio con precio propio, sin material del catálogo (P-026).
Future<ItemProyecto?> mostrarFormularioServicio(
  BuildContext context, {
  ItemProyecto? partida,
}) => showDialog<ItemProyecto>(
  context: context,
  builder: (_) => _FormularioServicio(partida: partida),
);

class _FormularioServicio extends StatefulWidget {
  const _FormularioServicio({this.partida});

  final ItemProyecto? partida;

  @override
  State<_FormularioServicio> createState() => _FormularioServicioState();
}

class _FormularioServicioState extends State<_FormularioServicio> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _descripcion;
  late final TextEditingController _cantidad;
  late final TextEditingController _unidad;
  late final TextEditingController _precio;

  @override
  void initState() {
    super.initState();
    final partida = widget.partida;
    _descripcion = TextEditingController(text: partida?.nombreMaterial);
    _cantidad = TextEditingController(text: '${partida?.cantidad ?? 1}');
    _unidad = TextEditingController(text: partida?.unidadMedida ?? 'servicio');
    _precio = TextEditingController(
      text: partida == null
          ? ''
          : (partida.costoUnitarioAplicadoCentavos / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _descripcion.dispose();
    _cantidad.dispose();
    _unidad.dispose();
    _precio.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.pop(
      context,
      ItemProyecto(
        id: widget.partida?.id ?? 0,
        proyectoId: widget.partida?.proyectoId ?? 0,
        esServicio: true,
        cantidad: leerCantidad(_cantidad.text)!,
        costoUnitarioAplicadoCentavos: leerCentavos(_precio.text)!,
        nombreMaterial: _descripcion.text.trim(),
        unidadMedida: _unidad.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.partida == null ? 'Añadir servicio' : 'Editar servicio'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Cobra un trabajo con precio propio, como instalación o '
                'diseño. No recibe margen.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                onTapOutside: cerrarFocoAlTocarFuera,
                controller: _descripcion,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción del servicio',
                ),
                validator: validarRequerido,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      onTapOutside: cerrarFocoAlTocarFuera,
                      controller: _cantidad,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                      validator: (texto) => leerCantidad(texto ?? '') == null
                          ? 'Mayor a cero'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      onTapOutside: cerrarFocoAlTocarFuera,
                      controller: _unidad,
                      maxLength: 40,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        counterText: '',
                      ),
                      validator: validarRequerido,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                onTapOutside: cerrarFocoAlTocarFuera,
                controller: _precio,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio unitario al cliente',
                  prefixText: '\$ ',
                ),
                validator: validarImporte,
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
        child: Text(widget.partida == null ? 'Añadir' : 'Aplicar'),
      ),
    ],
  );
}
