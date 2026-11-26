import 'package:flutter/material.dart';

import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/movimientos/selector_fecha_hora.dart';

// Registra material realmente usado en una obra (P-030).
Future<Gasto?> mostrarFormularioConsumo(
  BuildContext context, {
  required int proyectoId,
  required List<MaterialObra> materiales,
  Gasto? consumo,
}) => showDialog<Gasto>(
  context: context,
  builder: (_) => _FormularioConsumo(
    proyectoId: proyectoId,
    materiales: materiales,
    consumo: consumo,
  ),
);

class _FormularioConsumo extends StatefulWidget {
  const _FormularioConsumo({
    required this.proyectoId,
    required this.materiales,
    this.consumo,
  });

  final int proyectoId;
  final List<MaterialObra> materiales;
  final Gasto? consumo;

  @override
  State<_FormularioConsumo> createState() => _FormularioConsumoState();
}

class _FormularioConsumoState extends State<_FormularioConsumo> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _cantidad;
  late final TextEditingController _costo;
  late final TextEditingController _nota;
  late DateTime _fecha;
  int? _materialId;

  @override
  void initState() {
    super.initState();
    final consumo = widget.consumo;
    _materialId = consumo?.materialId;
    _cantidad = TextEditingController(
      text: consumo == null ? '1' : cantidadCorta(consumo.cantidad!),
    );
    _costo = TextEditingController(
      text: consumo == null
          ? ''
          : (consumo.costoUnitarioCentavos! / 100).toStringAsFixed(2),
    );
    _nota = TextEditingController(text: consumo?.nota ?? '');
    _fecha = consumo?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _costo.dispose();
    _nota.dispose();
    super.dispose();
  }

  MaterialObra? get _material =>
      widget.materiales.where((m) => m.id == _materialId).firstOrNull;

  void _elegir(int? id) => setState(() {
    _materialId = id;
    final material = _material;
    if (material != null) {
      _costo.text = (material.costoBaseCentavos / 100).toStringAsFixed(2);
    }
  });

  void _aceptar() {
    if (!_formulario.currentState!.validate()) return;
    final cantidad = leerCantidad(_cantidad.text)!;
    final costo = leerCentavos(_costo.text)!;
    final material = _material;
    Navigator.pop(
      context,
      Gasto(
        id: widget.consumo?.id ?? 0,
        proyectoId: widget.proyectoId,
        montoCentavos: calcularSubtotal(cantidad, costo),
        categoria: Gasto.categoriaConsumo,
        fecha: _fecha,
        nota: _nota.text.trim(),
        materialId: material?.id ?? widget.consumo?.materialId,
        cantidad: cantidad,
        costoUnitarioCentavos: costo,
        nombreMaterial: material?.nombre ?? widget.consumo?.nombreMaterial,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cantidad = leerCantidad(_cantidad.text);
    final costo = leerCentavos(_costo.text);
    return AlertDialog(
      title: Text(
        widget.consumo == null ? 'Registrar consumo' : 'Editar consumo',
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
                  'Anota el material que realmente usaste. Se suma a los '
                  'gastos de la obra y reemplaza al material cotizado.',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _material == null ? null : _materialId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Material',
                    helperText: _material == null && widget.consumo != null
                        ? widget.consumo!.nombreMaterial
                        : null,
                  ),
                  items: [
                    for (final material in widget.materiales)
                      DropdownMenuItem(
                        value: material.id,
                        child: Text(
                          '${material.nombre} (${material.unidadMedida})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  validator: (id) => id == null && widget.consumo == null
                      ? 'Selecciona un material'
                      : null,
                  onChanged: _elegir,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  onTapOutside: cerrarFocoAlTocarFuera,
                  controller: _cantidad,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Cantidad usada',
                    suffixText: _material?.unidadMedida,
                  ),
                  validator: (texto) => leerCantidad(texto ?? '') == null
                      ? 'Ingresa una cantidad mayor a cero'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  onTapOutside: cerrarFocoAlTocarFuera,
                  controller: _costo,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Costo unitario real',
                    prefixText: '\$ ',
                  ),
                  validator: validarCosto,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${cantidad == null || costo == null ? '-' : dinero(calcularSubtotal(cantidad, costo))}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SelectorFechaHora(
                  fecha: _fecha,
                  alCambiar: (valor) => setState(() => _fecha = valor),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  onTapOutside: cerrarFocoAlTocarFuera,
                  controller: _nota,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
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
        FilledButton(onPressed: _aceptar, child: const Text('Guardar consumo')),
      ],
    );
  }
}
