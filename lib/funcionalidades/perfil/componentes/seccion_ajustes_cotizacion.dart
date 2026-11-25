import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/preferencias_cubit.dart';
import '../../../core/enfoque.dart';
import '../../../widgets/selector_iva.dart';
import '../../../widgets/surface_card.dart';

// Valores con los que nace cada cotización (P-022, P-023, P-025).
class SeccionAjustesCotizacion extends StatefulWidget {
  const SeccionAjustesCotizacion({super.key});

  @override
  State<SeccionAjustesCotizacion> createState() =>
      _SeccionAjustesCotizacionState();
}

class _SeccionAjustesCotizacionState extends State<SeccionAjustesCotizacion> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _margen;
  late final TextEditingController _validez;
  late final TextEditingController _formaPago;
  late final TextEditingController _condiciones;
  int? _iva;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final ajustes = context.read<PreferenciasCubit>().state;
    _iva = ajustes.ivaPuntos;
    _margen = TextEditingController(text: '${ajustes.margenPuntos ~/ 100}');
    _validez = TextEditingController(text: '${ajustes.validezDias}');
    _formaPago = TextEditingController(text: ajustes.formaPago);
    _condiciones = TextEditingController(text: ajustes.condiciones);
  }

  @override
  void dispose() {
    _margen.dispose();
    _validez.dispose();
    _formaPago.dispose();
    _condiciones.dispose();
    super.dispose();
  }

  static String? _validarEntero(String? texto, int minimo, int maximo) {
    final valor = int.tryParse(texto?.trim() ?? '');
    return valor == null || valor < minimo || valor > maximo
        ? 'Ingresa un número entre $minimo y $maximo.'
        : null;
  }

  Future<void> _guardar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final cubit = context.read<PreferenciasCubit>();
    setState(() => _guardando = true);
    try {
      await cubit.guardar(
        cubit.state.copyWith(
          ivaPuntos: _iva,
          sinIva: _iva == null,
          margenPuntos: int.parse(_margen.text.trim()) * 100,
          validezDias: int.parse(_validez.text.trim()),
          formaPago: _formaPago.text.trim(),
          condiciones: _condiciones.text.trim(),
        ),
      );
      _avisar('Ajustes de cotización guardados.');
    } catch (_) {
      _avisar('No se pudieron guardar los ajustes.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Form(
      key: _formulario,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ajustes de cotización',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Se aplican a las cotizaciones nuevas; puedes cambiarlos en cada una.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SelectorIva(
            puntos: _iva,
            alCambiar: (valor) => setState(() => _iva = valor),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: TextFormField(
                  onTapOutside: cerrarFocoAlTocarFuera,
                  controller: _margen,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Margen sugerido',
                    suffixText: '%',
                  ),
                  validator: (texto) => _validarEntero(texto, 0, 90),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextFormField(
                  onTapOutside: cerrarFocoAlTocarFuera,
                  controller: _validez,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Validez de la oferta',
                    suffixText: 'días',
                  ),
                  validator: (texto) => _validarEntero(texto, 1, 365),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: _formaPago,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Forma de pago',
              hintText: 'Ej.: 50 % de anticipo y 50 % al finalizar',
            ),
          ),
          TextFormField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: _condiciones,
            minLines: 2,
            maxLines: 5,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Condiciones',
              hintText: 'Ej.: Incluye garantía de 6 meses en mano de obra',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando...' : 'Guardar ajustes'),
            ),
          ),
        ],
      ),
    ),
  );
}
