import 'package:flutter/widgets.dart';

import '../../../dominio/modelos.dart';

// Estado del editor para cliente y condiciones de la proforma (P-021 a P-025).
class DatosProformaEditor {
  DatosProformaEditor._({
    required this.clienteId,
    required this.ivaPuntos,
    required this.margenPuntos,
    required this.fechaCreacion,
    required Cliente? cliente,
    required int validezDias,
    required String formaPago,
    required String condiciones,
  }) : identificacion = TextEditingController(text: cliente?.identificacion),
       telefono = TextEditingController(text: cliente?.telefono),
       correo = TextEditingController(text: cliente?.correo),
       direccion = TextEditingController(text: cliente?.direccion),
       validez = TextEditingController(text: '$validezDias'),
       formaPago = TextEditingController(text: formaPago),
       condiciones = TextEditingController(text: condiciones);

  // Una cotización existente conserva sus valores; una nueva toma los ajustes.
  factory DatosProformaEditor.desde(
    Proyecto? proyecto,
    DatosLocales datos,
    PreferenciasApp ajustes,
  ) => DatosProformaEditor._(
    clienteId: proyecto?.clienteId,
    cliente: datos.clientePorId(proyecto?.clienteId),
    ivaPuntos: proyecto == null ? ajustes.ivaPuntos : proyecto.ivaPuntos,
    margenPuntos: proyecto?.margenDeseadoPuntos ?? ajustes.margenPuntos,
    fechaCreacion: proyecto?.fechaCreacion ?? DateTime.now(),
    validezDias: proyecto?.validezDias ?? ajustes.validezDias,
    formaPago: proyecto?.formaPago ?? ajustes.formaPago,
    condiciones: proyecto?.condiciones ?? ajustes.condiciones,
  );

  int? clienteId;
  int? ivaPuntos;
  final int margenPuntos;
  final DateTime fechaCreacion;
  final TextEditingController identificacion, telefono, correo, direccion;
  final TextEditingController validez, formaPago, condiciones;

  int get validezDias =>
      int.tryParse(validez.text.trim()) ?? Proyecto.validezPredeterminadaDias;

  void elegirCliente(Cliente cliente) {
    clienteId = cliente.id;
    identificacion.text = cliente.identificacion;
    telefono.text = cliente.telefono;
    correo.text = cliente.correo;
    direccion.text = cliente.direccion;
  }

  // Reutiliza un cliente con el mismo nombre para no duplicarlo.
  Cliente clientePara(String nombre, List<Cliente> clientes) {
    final buscado = nombre.trim().toLowerCase();
    var id = clienteId ?? 0;
    final elegido = clientes.where((c) => c.id == clienteId).firstOrNull;
    if (elegido == null || elegido.nombre.trim().toLowerCase() != buscado) {
      id =
          clientes
              .where((c) => c.nombre.trim().toLowerCase() == buscado)
              .firstOrNull
              ?.id ??
          0;
    }
    return Cliente(
      id: id,
      nombre: nombre.trim(),
      identificacion: identificacion.text.trim(),
      telefono: telefono.text.trim(),
      correo: correo.text.trim(),
      direccion: direccion.text.trim(),
    );
  }

  void dispose() {
    for (final controlador in [
      identificacion,
      telefono,
      correo,
      direccion,
      validez,
      formaPago,
      condiciones,
    ]) {
      controlador.dispose();
    }
  }
}
