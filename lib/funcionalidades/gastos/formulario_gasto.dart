import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../dominio/categorias_gasto.dart';
import '../../dominio/modelos.dart';

Future<Gasto?> mostrarFormularioGasto(
  BuildContext contexto, {
  required List<Proyecto> proyectos,
  Gasto? gasto,
  int? proyectoId,
}) => showDialog<Gasto>(
  context: contexto,
  builder: (_) => GastoFormulario(
    proyectos: proyectos,
    gasto: gasto,
    proyectoId: proyectoId,
  ),
);

class GastoFormulario extends StatefulWidget {
  const GastoFormulario({
    super.key,
    required this.proyectos,
    this.gasto,
    this.proyectoId,
  });

  final List<Proyecto> proyectos;
  final Gasto? gasto;
  final int? proyectoId;

  @override
  State<GastoFormulario> createState() => _GastoFormularioState();
}

class _GastoFormularioState extends State<GastoFormulario> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _monto;
  late final TextEditingController _nota;
  late DateTime _fecha;
  late String _categoria;
  late int _proyectoId;
  late final List<String> _categorias;

  @override
  void initState() {
    super.initState();
    final gasto = widget.gasto;
    _monto = TextEditingController(
      text: gasto == null ? '' : (gasto.montoCentavos / 100).toStringAsFixed(2),
    );
    _nota = TextEditingController(text: gasto?.nota ?? '');
    _fecha = gasto?.fecha ?? DateTime.now();
    _categorias = List.of(categoriasGasto);
    _categoria = gasto?.categoria ?? categoriasGasto.first;
    if (!_categorias.contains(_categoria)) _categorias.add(_categoria);
    _proyectoId = gasto?.proyectoId ?? widget.proyectoId ?? 0;
  }

  @override
  void dispose() {
    _monto.dispose();
    _nota.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (elegida != null && mounted) setState(() => _fecha = elegida);
  }

  void _aceptar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.pop(
      context,
      Gasto(
        id: widget.gasto?.id ?? 0,
        proyectoId: _proyectoId == 0 ? null : _proyectoId,
        montoCentavos: leerCentavos(_monto.text)!,
        categoria: _categoria,
        fecha: _fecha,
        nota: _nota.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.gasto == null ? 'Registrar gasto' : 'Editar gasto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Cada gasto cuenta para conocer lo que ganas.'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _monto,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                ),
                validator: (valor) {
                  final centavos = leerCentavos(valor ?? '');
                  return centavos == null || centavos <= 0
                      ? 'Ingresa un monto mayor que cero con hasta 2 decimales.'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _proyectoId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Asignar a'),
                items: [
                  const DropdownMenuItem(
                    value: 0,
                    child: Text('Gasto general'),
                  ),
                  ...widget.proyectos.map(
                    (proyecto) => DropdownMenuItem(
                      value: proyecto.id,
                      child: Text(
                        '${proyecto.nombreCliente} · ${proyecto.descripcion}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (valor) => setState(() => _proyectoId = valor ?? 0),
              ),
              const SizedBox(height: 8),
              Text(
                _proyectoId == 0
                    ? 'El gasto general afecta al balance global, sin descontarse de un proyecto.'
                    : 'Este gasto se descontará de la rentabilidad del proyecto.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoria,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categorias
                    .map(
                      (categoria) => DropdownMenuItem(
                        value: categoria,
                        child: Text(
                          categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (valor) => setState(() => _categoria = valor!),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _elegirFecha,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Fecha: ${fechaCorta(_fecha)}'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nota,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Detalle del gasto o comprobante',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registra solo costos adicionales. Los materiales incluidos en la cotización ya se descuentan automáticamente.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _aceptar,
                child: const Text('Guardar gasto'),
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
