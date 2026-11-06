import '../dominio/modelos.dart';

const limiteImporteCentavos = 1000000000000;

void validarTexto(String texto, String campo, {int maximo = 200}) {
  if (texto.trim().isEmpty || texto.trim().length > maximo) {
    throw FormatException('$campo debe contener entre 1 y $maximo caracteres.');
  }
}

void validarImporte(int importe, {bool admiteCero = true}) {
  if (importe < (admiteCero ? 0 : 1) || importe > limiteImporteCentavos) {
    throw const FormatException('El importe está fuera del rango permitido.');
  }
}

void validarId(int id) {
  if (id < 0) throw const FormatException('El identificador no es válido.');
}

void validarProyecto(Proyecto proyecto, List<ItemProyecto> items) {
  validarId(proyecto.id);
  validarTexto(proyecto.nombreCliente, 'El cliente');
  validarTexto(proyecto.descripcion, 'La descripción', maximo: 2000);
  validarImporte(proyecto.totalCotizadoCentavos);
  if (proyecto.fechaFin?.isBefore(proyecto.fechaInicio) ?? false) {
    throw const FormatException('La fecha final debe ser posterior al inicio.');
  }
  var totalMateriales = 0;
  for (final item in items) {
    if (!item.cantidad.isFinite ||
        item.cantidad < 0.001 ||
        item.cantidad > 1000000) {
      throw const FormatException(
        'La cantidad debe estar entre 0,001 y 1000000.',
      );
    }
    final milesimas = item.cantidad * 1000;
    if ((milesimas - milesimas.round()).abs() > 0.000001) {
      throw const FormatException('La cantidad admite hasta tres decimales.');
    }
    if (item.materialId <= 0 ||
        (item.proyectoId != 0 && item.proyectoId != proyecto.id)) {
      throw const FormatException(
        'El material o proyecto del detalle no es válido.',
      );
    }
    validarImporte(item.costoUnitarioAplicadoCentavos);
    validarImporte(item.subtotalCentavos);
    totalMateriales += item.subtotalCentavos;
    validarImporte(totalMateriales);
    validarTexto(item.nombreMaterial, 'El nombre del material');
    validarTexto(item.unidadMedida, 'La unidad', maximo: 40);
  }
}

void validarMaterial(MaterialObra material) {
  validarId(material.id);
  validarTexto(material.nombre, 'El nombre');
  validarTexto(material.unidadMedida, 'La unidad', maximo: 40);
  validarImporte(material.costoBaseCentavos);
}

void validarGasto(Gasto gasto) {
  validarId(gasto.id);
  if (gasto.proyectoId != null && gasto.proyectoId! <= 0) {
    throw const FormatException('Selecciona un proyecto válido.');
  }
  validarImporte(gasto.montoCentavos, admiteCero: false);
  validarTexto(gasto.categoria, 'La categoría', maximo: 80);
  if (gasto.nota.length > 2000) {
    throw const FormatException('La nota admite hasta 2000 caracteres.');
  }
}
