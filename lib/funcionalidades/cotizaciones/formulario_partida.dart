import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../materiales/componentes/imagen_material.dart';
import '../materiales/formulario_material.dart';

Future<ItemProyecto?> mostrarFormularioPartida(
  BuildContext context, {
  ItemProyecto? partida,
}) => showDialog<ItemProyecto>(
  context: context,
  builder: (_) => BlocProvider.value(
    value: context.read<CotizoCubit>(),
    child: _FormularioPartida(partida: partida),
  ),
);

class _FormularioPartida extends StatefulWidget {
  const _FormularioPartida({this.partida});
  final ItemProyecto? partida;

  @override
  State<_FormularioPartida> createState() => _FormularioPartidaState();
}

class _FormularioPartidaState extends State<_FormularioPartida> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _cantidad;
  late final TextEditingController _costo;
  int? _materialId;
  bool _creandoMaterial = false;

  @override
  void initState() {
    super.initState();
    _materialId = widget.partida?.materialId;
    _cantidad = TextEditingController(
      text: widget.partida?.cantidad.toString() ?? '1',
    );
    _costo = TextEditingController(
      text: widget.partida == null
          ? ''
          : (widget.partida!.costoUnitarioAplicadoCentavos / 100)
                .toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _costo.dispose();
    super.dispose();
  }

  void _seleccionar(MaterialObra material) => setState(() {
    _materialId = material.id;
    _costo.text = (material.costoBaseCentavos / 100).toStringAsFixed(2);
  });

  Future<void> _crearMaterial() async {
    final cubit = context.read<CotizoCubit>();
    final edicion = await mostrarFormularioMaterial(context);
    if (edicion == null || !mounted) return;
    final idsPrevios = cubit.state.datos.materiales.map((m) => m.id).toSet();
    setState(() => _creandoMaterial = true);
    final guardado = await cubit.guardarMaterial(edicion);
    if (!mounted) return;
    setState(() => _creandoMaterial = false);
    if (guardado) {
      final creados = cubit.state.datos.materiales.where(
        (material) => !idsPrevios.contains(material.id),
      );
      if (creados.isNotEmpty) _seleccionar(creados.first);
    }
  }

  void _agregar(List<MaterialObra> materiales) {
    if (!_formulario.currentState!.validate()) return;
    final material = materiales.firstWhere((m) => m.id == _materialId);
    final anterior = widget.partida;
    final conservaMaterial = anterior?.materialId == material.id;
    Navigator.of(context).pop(
      ItemProyecto(
        id: anterior?.id ?? 0,
        proyectoId: anterior?.proyectoId ?? 0,
        materialId: material.id,
        cantidad: leerCantidad(_cantidad.text)!,
        costoUnitarioAplicadoCentavos: leerCentavos(_costo.text)!,
        nombreMaterial: conservaMaterial
            ? anterior!.nombreMaterial
            : material.nombre,
        unidadMedida: conservaMaterial
            ? anterior!.unidadMedida
            : material.unidadMedida,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final materiales = estado.datos.materiales;
      return AlertDialog(
        title: Text(
          widget.partida == null ? 'Añadir material' : 'Editar material',
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Form(
              key: _formulario,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (materiales.isEmpty)
                    const Text(
                      'Crea tu primer material con su precio y unidad.',
                    ),
                  if (materiales.isNotEmpty)
                    DropdownButtonFormField<int>(
                      value: _materialId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Material'),
                      items: materiales
                          .map(
                            (material) => DropdownMenuItem(
                              value: material.id,
                              child: Row(
                                children: [
                                  ImagenMaterial(
                                    ruta: material.imagenRuta,
                                    ancho: 36,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      material.nombre,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      validator: (id) =>
                          id == null ? 'Selecciona un material' : null,
                      onChanged: (id) {
                        if (id != null) {
                          _seleccionar(
                            materiales.firstWhere((m) => m.id == id),
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _creandoMaterial ? null : _crearMaterial,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear material'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cantidad,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      helperText: 'Hasta 3 decimales',
                    ),
                    validator: (texto) => leerCantidad(texto ?? '') == null
                        ? 'Ingresa una cantidad mayor a cero'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _costo,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Costo unitario aplicado',
                      prefixText: '\$ ',
                      helperText: 'Se conserva en esta cotización',
                    ),
                    validator: validarCosto,
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
            onPressed: materiales.isEmpty || _creandoMaterial
                ? null
                : () => _agregar(materiales),
            child: Text(widget.partida == null ? 'Añadir' : 'Aplicar'),
          ),
        ],
      );
    },
  );
}
