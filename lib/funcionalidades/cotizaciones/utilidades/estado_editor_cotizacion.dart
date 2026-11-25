import 'package:flutter/widgets.dart';

import '../../../core/formato.dart';
import '../../../dominio/calcular_presupuesto_proyecto.dart';
import '../../../dominio/modelos.dart';
import 'datos_proforma_editor.dart';

// Datos que se editan en el asistente de cotización (P-052).
class EstadoEditorCotizacion {
  EstadoEditorCotizacion.desde(
    this.original,
    DatosLocales datos,
    PreferenciasApp ajustes,
  ) : proforma = DatosProformaEditor.desde(original, datos, ajustes),
      cliente = TextEditingController(text: original?.nombreCliente ?? ''),
      descripcion = TextEditingController(text: original?.descripcion ?? ''),
      total = TextEditingController(
        text: original == null ? '' : _texto(original.totalCotizadoCentavos),
      ),
      cobroManoObra = TextEditingController(
        text: (original?.cobroManoObraCentavos ?? 0) == 0
            ? ''
            : _texto(original!.cobroManoObraCentavos),
      ),
      incluirManoObra = (original?.cobroManoObraCentavos ?? 0) > 0,
      inicio = original?.fechaInicio ?? _hoy(),
      fin = original?.fechaFin ?? (original == null ? _hoy() : null),
      partidas = original == null ? [] : datos.itemsDeProyecto(original.id),
      gastosPrevistos = original == null
          ? []
          : datos.gastosPrevistosDeProyecto(original.id);

  final Proyecto? original;
  final DatosProformaEditor proforma;
  final TextEditingController cliente, descripcion, total, cobroManoObra;
  final List<ItemProyecto> partidas;
  List<GastoPrevisto> gastosPrevistos;
  bool incluirManoObra;
  DateTime inicio;
  DateTime? fin;

  static String _texto(int centavos) => (centavos / 100).toStringAsFixed(2);

  static DateTime _hoy() {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day);
  }

  int get cobroManoObraCentavos =>
      incluirManoObra ? leerCentavos(cobroManoObra.text) ?? 0 : 0;

  PresupuestoProyecto get presupuesto => calcularPresupuestoProyecto(
    partidas,
    gastosPrevistos,
    cobroManoObraCentavos: cobroManoObraCentavos,
    margenPuntos: proforma.margenPuntos,
  );

  String? validarFechas() {
    if (fin == null && original == null) {
      return 'Selecciona la fecha final prevista.';
    }
    if (fin?.isBefore(inicio) ?? false) {
      return 'La entrega no puede ser anterior al inicio.';
    }
    return null;
  }

  Proyecto proyectoActual() => Proyecto(
    id: original?.id ?? 0,
    nombreCliente: cliente.text.trim(),
    descripcion: descripcion.text.trim(),
    fechaInicio: inicio,
    fechaFin: fin,
    fechaInicioReal: original?.fechaInicioReal,
    fechaFinReal: original?.fechaFinReal,
    estado: original?.estado ?? EstadoProyecto.borrador,
    totalCotizadoCentavos: leerCentavos(total.text) ?? 0,
    cobroManoObraCentavos: cobroManoObraCentavos,
    margenDeseadoPuntos: proforma.margenPuntos,
    fechaCreacion: proforma.fechaCreacion,
    clienteId: proforma.clienteId,
    ivaPuntos: proforma.ivaPuntos,
    validezDias: proforma.validezDias,
    formaPago: proforma.formaPago.text.trim(),
    condiciones: proforma.condiciones.text.trim(),
  );

  Cliente clienteActual(List<Cliente> clientes) =>
      proforma.clientePara(cliente.text, clientes);

  void dispose() {
    cliente.dispose();
    descripcion.dispose();
    total.dispose();
    cobroManoObra.dispose();
    proforma.dispose();
  }
}
