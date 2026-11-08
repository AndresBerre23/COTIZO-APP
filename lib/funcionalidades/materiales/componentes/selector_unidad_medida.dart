import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../dominio/unidades_medida.dart';

class SelectorUnidadMedida extends StatefulWidget {
  const SelectorUnidadMedida({super.key, required this.controlador});

  final TextEditingController controlador;

  @override
  State<SelectorUnidadMedida> createState() => _SelectorUnidadMedidaState();
}

class _SelectorUnidadMedidaState extends State<SelectorUnidadMedida> {
  final _campo = GlobalKey<FormFieldState<String>>();
  late bool _otraUnidadActiva;

  @override
  void initState() {
    super.initState();
    _otraUnidadActiva = !esUnidadPredefinida(widget.controlador.text);
    widget.controlador.addListener(_actualizarCampo);
  }

  void _actualizarCampo() {
    _campo.currentState?.didChange(widget.controlador.text);
  }

  @override
  void dispose() {
    widget.controlador.removeListener(_actualizarCampo);
    super.dispose();
  }

  List<DropdownMenuEntry<String>> _crearOpciones() => [
    for (var indice = 0; indice < gruposUnidadesMedida.length; indice++) ...[
      DropdownMenuEntry<String>(
        value: '__grupo_$indice',
        label: gruposUnidadesMedida[indice].nombre,
        enabled: false,
      ),
      for (final unidad in gruposUnidadesMedida[indice].unidades)
        DropdownMenuEntry<String>(value: unidad.nombre, label: unidad.nombre),
    ],
    const DropdownMenuEntry<String>(
      value: valorOtraUnidad,
      label: 'Otra unidad',
    ),
  ];

  List<DropdownMenuEntry<String>> _filtrarOpciones(
    List<DropdownMenuEntry<String>> opciones,
    String consulta,
  ) {
    final texto = normalizarUnidad(consulta.trim());
    if (texto.isEmpty) return opciones;
    final coincidencias = buscarUnidadesMedida(
      texto,
    ).map((unidad) => unidad.nombre).toSet();
    return opciones.where((opcion) {
      if (opcion.value == valorOtraUnidad) {
        return normalizarUnidad(opcion.label).contains(texto);
      }
      return coincidencias.contains(opcion.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) => FormField<String>(
    key: _campo,
    initialValue: widget.controlador.text,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (_) => widget.controlador.text.trim().isEmpty
        ? 'Selecciona o escribe una unidad.'
        : null,
    builder: (campo) => DropdownMenu<String>(
      controller: widget.controlador,
      enableFilter: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      label: const Text('Unidad de medida'),
      helperText: _otraUnidadActiva
          ? 'Escribe la unidad personalizada.'
          : 'Busca o selecciona una unidad.',
      errorText: campo.errorText,
      inputFormatters: [LengthLimitingTextInputFormatter(30)],
      dropdownMenuEntries: _crearOpciones(),
      filterCallback: _filtrarOpciones,
      onSelected: (seleccion) {
        if (seleccion == valorOtraUnidad) {
          widget.controlador.clear();
          setState(() => _otraUnidadActiva = true);
        } else if (seleccion != null && esUnidadPredefinida(seleccion)) {
          widget.controlador.text = seleccion;
          setState(() => _otraUnidadActiva = false);
        }
      },
    ),
  );
}
