import 'package:flutter/material.dart';
import 'package:cotizo_app/core/enfoque.dart';

import '../../core/formato.dart';
import '../../dominio/categorias_gasto.dart';
import '../../dominio/modelos.dart';
import '../../widgets/movimientos/campo_monto.dart';
import '../../widgets/movimientos/selector_categoria.dart';
import '../../widgets/movimientos/selector_fecha_hora.dart';
import '../../widgets/movimientos/selector_proyecto_movimiento.dart';

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
              CampoMonto(controlador: _monto),
              const SizedBox(height: 16),
              SelectorProyectoMovimiento(
                proyectos: widget.proyectos,
                valor: _proyectoId,
                etiquetaGeneral: 'Gasto general',
                idConservado: widget.gasto?.proyectoId ?? widget.proyectoId,
                alCambiar: (valor) => setState(() => _proyectoId = valor),
              ),
              const SizedBox(height: 8),
              Text(
                _proyectoId == 0
                    ? 'El gasto general afecta al balance global, sin descontarse de un proyecto.'
                    : 'Este gasto se descontará de la rentabilidad del proyecto.',
              ),
              const SizedBox(height: 16),
              SelectorCategoria(
                categorias: _categorias,
                valor: _categoria,
                alCambiar: (valor) => setState(() => _categoria = valor),
              ),
              const SizedBox(height: 16),
              SelectorFechaHora(
                fecha: _fecha,
                alCambiar: (valor) => setState(() => _fecha = valor),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onTapOutside: cerrarFocoAlTocarFuera,
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
