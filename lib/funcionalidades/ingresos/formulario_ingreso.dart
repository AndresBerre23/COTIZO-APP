import 'package:flutter/material.dart';

import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/categorias_ingreso.dart';
import '../../dominio/modelos.dart';
import '../../widgets/movimientos/campo_monto.dart';
import '../../widgets/movimientos/selector_categoria.dart';
import '../../widgets/movimientos/selector_fecha_hora.dart';
import '../../widgets/movimientos/selector_proyecto_movimiento.dart';

Future<Ingreso?> mostrarFormularioIngreso(
  BuildContext contexto, {
  required List<Proyecto> proyectos,
  Ingreso? ingreso,
  int? proyectoId,
}) => showDialog<Ingreso>(
  context: contexto,
  builder: (_) => FormularioIngreso(
    proyectos: proyectos,
    ingreso: ingreso,
    proyectoId: proyectoId,
  ),
);

class FormularioIngreso extends StatefulWidget {
  const FormularioIngreso({
    super.key,
    required this.proyectos,
    this.ingreso,
    this.proyectoId,
  });

  final List<Proyecto> proyectos;
  final Ingreso? ingreso;
  final int? proyectoId;

  @override
  State<FormularioIngreso> createState() => _FormularioIngresoState();
}

class _FormularioIngresoState extends State<FormularioIngreso> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _monto;
  late final TextEditingController _nota;
  late DateTime _fecha;
  late String _categoria;
  late int _proyectoId;
  late MetodoPago _metodo;
  late final List<String> _categorias;

  @override
  void initState() {
    super.initState();
    final ingreso = widget.ingreso;
    _monto = TextEditingController(
      text: ingreso == null
          ? ''
          : (ingreso.montoCentavos / 100).toStringAsFixed(2),
    );
    _nota = TextEditingController(text: ingreso?.nota ?? '');
    _fecha = ingreso?.fecha ?? DateTime.now();
    _proyectoId = ingreso?.proyectoId ?? widget.proyectoId ?? 0;
    _metodo = ingreso?.metodo ?? MetodoPago.efectivo;
    _categorias = List.of(categoriasIngreso);
    // Desde un proyecto, lo habitual es registrar un anticipo o abono.
    _categoria =
        ingreso?.categoria ??
        (_proyectoId == 0 ? 'Venta' : categoriasCobroProyecto.first);
    if (!_categorias.contains(_categoria)) _categorias.add(_categoria);
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
      Ingreso(
        id: widget.ingreso?.id ?? 0,
        proyectoId: _proyectoId == 0 ? null : _proyectoId,
        montoCentavos: leerCentavos(_monto.text)!,
        categoria: _categoria,
        metodo: _metodo,
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
                widget.ingreso == null ? 'Registrar ingreso' : 'Editar ingreso',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Anota cada cobro para saber cuánto entra de verdad.'),
              const SizedBox(height: 24),
              CampoMonto(controlador: _monto),
              const SizedBox(height: 16),
              SelectorProyectoMovimiento(
                proyectos: widget.proyectos,
                valor: _proyectoId,
                etiquetaGeneral: 'Ingreso general',
                idConservado: widget.ingreso?.proyectoId ?? widget.proyectoId,
                alCambiar: (valor) => setState(() => _proyectoId = valor),
              ),
              const SizedBox(height: 8),
              Text(
                _proyectoId == 0
                    ? 'Cuenta en tu balance sin ligarse a un proyecto.'
                    : 'Se descuenta del saldo pendiente del proyecto.',
              ),
              const SizedBox(height: 16),
              SelectorCategoria(
                categorias: _categorias,
                valor: _categoria,
                alCambiar: (valor) => setState(() => _categoria = valor),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MetodoPago>(
                value: _metodo,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: [
                  for (final metodo in MetodoPago.values)
                    DropdownMenuItem(
                      value: metodo,
                      child: Text(metodo.etiqueta),
                    ),
                ],
                onChanged: (valor) =>
                    setState(() => _metodo = valor ?? _metodo),
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
                  hintText: 'Número de transferencia o detalle',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _aceptar,
                child: const Text('Guardar ingreso'),
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
