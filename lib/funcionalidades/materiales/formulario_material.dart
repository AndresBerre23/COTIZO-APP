import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../dominio/modelos.dart';

Future<MaterialObra?> mostrarFormularioMaterial(
  BuildContext contexto, {
  MaterialObra? material,
}) => showDialog<MaterialObra>(
  context: contexto,
  builder: (_) => MaterialFormulario(material: material),
);

class MaterialFormulario extends StatefulWidget {
  const MaterialFormulario({super.key, this.material});

  final MaterialObra? material;

  @override
  State<MaterialFormulario> createState() => _MaterialFormularioState();
}

class _MaterialFormularioState extends State<MaterialFormulario> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _unidad;
  late final TextEditingController _costo;

  @override
  void initState() {
    super.initState();
    final material = widget.material;
    _nombre = TextEditingController(text: material?.nombre ?? '');
    _unidad = TextEditingController(text: material?.unidadMedida ?? 'unidad');
    _costo = TextEditingController(
      text: material == null
          ? ''
          : (material.costoBaseCentavos / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _unidad.dispose();
    _costo.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.pop(
      context,
      MaterialObra(
        id: widget.material?.id ?? 0,
        nombre: _nombre.text.trim(),
        unidadMedida: _unidad.text.trim(),
        costoBaseCentavos: leerCentavos(_costo.text)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.material == null ? 'Nuevo material' : 'Editar material',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Define tu precio de referencia por unidad.'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombre,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Nombre del material',
                ),
                validator: validarRequerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unidad,
                textInputAction: TextInputAction.next,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida',
                  hintText: 'm², saco, galón, unidad',
                ),
                validator: validarRequerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costo,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Costo por unidad',
                  prefixText: '\$ ',
                ),
                validator: validarCosto,
                onFieldSubmitted: (_) => _aceptar(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Las cotizaciones guardadas conservarán sus costos originales.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _aceptar,
                child: const Text('Guardar material'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
