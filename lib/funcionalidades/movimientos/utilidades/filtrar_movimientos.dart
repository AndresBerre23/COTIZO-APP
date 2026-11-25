import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';

enum FiltroAsignacionGasto { todos, proyectos, generales }

enum OrdenGastos {
  recientes('Más recientes'),
  antiguos('Más antiguos'),
  mayorImporte('Mayor importe'),
  menorImporte('Menor importe');

  const OrdenGastos(this.etiqueta);
  final String etiqueta;
}

// Criterios de búsqueda compartidos por gastos e ingresos.
class CriteriosMovimientos {
  const CriteriosMovimientos({
    this.busqueda = '',
    this.categoria,
    this.rangoFechas,
    this.asignacion = FiltroAsignacionGasto.todos,
    this.orden = OrdenGastos.recientes,
  });

  final String busqueda;
  final String? categoria;
  final DateTimeRange? rangoFechas;
  final FiltroAsignacionGasto asignacion;
  final OrdenGastos orden;
}

List<T> filtrarMovimientos<T extends Movimiento>(
  List<T> movimientos,
  CriteriosMovimientos criterios,
  Map<int, Proyecto> proyectos, {
  required String etiquetaGeneral,
}) {
  final consulta = criterios.busqueda.trim().toLowerCase();
  final rango = criterios.rangoFechas;
  final limite = rango == null
      ? null
      : DateTime(rango.end.year, rango.end.month, rango.end.day + 1);
  final resultado = movimientos.where((movimiento) {
    final esGeneral = movimiento.proyectoId == null;
    switch (criterios.asignacion) {
      case FiltroAsignacionGasto.generales when !esGeneral:
      case FiltroAsignacionGasto.proyectos when esGeneral:
        return false;
      default:
    }
    if (criterios.categoria != null &&
        movimiento.categoria != criterios.categoria) {
      return false;
    }
    if (rango != null &&
        (movimiento.fecha.isBefore(rango.start) ||
            !movimiento.fecha.isBefore(limite!))) {
      return false;
    }
    if (consulta.isEmpty) return true;
    final proyecto = proyectos[movimiento.proyectoId];
    final destino = proyecto == null
        ? etiquetaGeneral
        : '${proyecto.nombreCliente} ${proyecto.descripcion} '
              '${codigosBusqueda(proyecto.id)}';
    return '${movimiento.categoria} ${movimiento.nota} $destino'
        .toLowerCase()
        .contains(consulta);
  }).toList();
  switch (criterios.orden) {
    case OrdenGastos.recientes:
      resultado.sort((a, b) => b.fecha.compareTo(a.fecha));
    case OrdenGastos.antiguos:
      resultado.sort((a, b) => a.fecha.compareTo(b.fecha));
    case OrdenGastos.mayorImporte:
      resultado.sort((a, b) => b.montoCentavos.compareTo(a.montoCentavos));
    case OrdenGastos.menorImporte:
      resultado.sort((a, b) => a.montoCentavos.compareTo(b.montoCentavos));
  }
  return resultado;
}

String destinoMovimiento(
  Movimiento movimiento,
  Map<int, Proyecto> proyectos, {
  required String etiquetaGeneral,
}) {
  final proyecto = proyectos[movimiento.proyectoId];
  return proyecto == null
      ? etiquetaGeneral
      : '${proyecto.nombreCliente} · ${proyecto.descripcion}';
}
