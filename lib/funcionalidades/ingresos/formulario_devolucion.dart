import 'package:flutter/material.dart';

import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/movimientos/campo_monto.dart';
import '../../widgets/movimientos/selector_fecha_hora.dart';

// Dinero devuelto al cliente de un proyecto; deja constancia del motivo.
Future<Gasto?> mostrarFormularioDevolucion(
  BuildContext context, {
  required Proyecto proyecto,
  required int maximoCentavos,
}) => showDialog<Gasto>(
  context: context,
  builder: (_) =>
      _FormularioDevolucion(proyecto: proyecto, maximo: maximoCentavos),
);

class _FormularioDevolucion extends StatefulWidget {
  const _FormularioDevolucion({required this.proyecto, required this.maximo});

  final Proyecto proyecto;
  final int maximo;

  @override
  State<_FormularioDevolucion> createState() => _FormularioDevolucionState();
}

class _FormularioDevolucionState extends State<_FormularioDevolucion> {
  final _formulario = GlobalKey<FormState>();
  final _monto = TextEditingController();
  final _motivo = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _monto.dispose();
    _motivo.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.pop(
      context,
      Gasto(
        proyectoId: widget.proyecto.id,
        montoCentavos: leerCentavos(_monto.text)!,
        categoria: Gasto.categoriaDevolucion,
        fecha: _fecha,
        nota: _motivo.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Registrar devolución'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dinero que le devolviste al cliente. Se descuenta de lo '
                'cobrado (hasta ${dinero(widget.maximo)}) y de tu balance.',
              ),
              const SizedBox(height: 12),
              CampoMonto(controlador: _monto),
              const SizedBox(height: 12),
              TextFormField(
                onTapOutside: cerrarFocoAlTocarFuera,
                controller: _motivo,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  hintText: 'Ej.: Se canceló la obra antes de empezar',
                ),
                validator: validarRequerido,
              ),
              SelectorFechaHora(
                fecha: _fecha,
                alCambiar: (valor) => setState(() => _fecha = valor),
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
        onPressed: () {
          final monto = leerCentavos(_monto.text) ?? 0;
          if (monto > widget.maximo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No puedes devolver más de lo cobrado.'),
              ),
            );
            return;
          }
          _aceptar();
        },
        child: const Text('Guardar devolución'),
      ),
    ],
  );
}
