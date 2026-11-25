import 'package:flutter/material.dart';
import 'package:cotizo_app/core/enfoque.dart';

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../utilidades/datos_proforma_editor.dart';
import 'campo_cliente_editor.dart';
import 'fechas_proyecto.dart';
import 'seccion_cotizacion.dart';

class DatosClienteEditor extends StatelessWidget {
  const DatosClienteEditor({
    super.key,
    required this.cliente,
    required this.descripcion,
    required this.inicio,
    required this.fin,
    required this.alCambiarInicio,
    required this.alCambiarFin,
    required this.datosProforma,
    required this.clientes,
    required this.alElegirCliente,
    this.errorFecha,
  });

  final TextEditingController cliente, descripcion;
  final DateTime inicio;
  final DateTime? fin;
  final ValueChanged<DateTime> alCambiarInicio;
  final ValueChanged<DateTime?> alCambiarFin;
  final String? errorFecha;
  final DatosProformaEditor datosProforma;
  final List<Cliente> clientes;
  final ValueChanged<Cliente> alElegirCliente;

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: 'Cliente y proyecto',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoClienteEditor(
          nombre: cliente,
          datos: datosProforma,
          clientes: clientes,
          alElegir: alElegirCliente,
        ),
        const SizedBox(height: 12),
        TextFormField(
          onTapOutside: cerrarFocoAlTocarFuera,
          controller: descripcion,
          validator: validarRequerido,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 500,
          minLines: 1,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descripción del proyecto',
          ),
        ),
        const SizedBox(height: 16),
        FechasProyecto(
          inicio: inicio,
          fin: fin,
          alCambiarInicio: alCambiarInicio,
          alCambiarFin: alCambiarFin,
        ),
        if (errorFecha != null)
          Text(
            errorFecha!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
  );
}
