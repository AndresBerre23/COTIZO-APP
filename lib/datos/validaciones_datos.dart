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

void validarProyecto(
  Proyecto proyecto,
  List<ItemProyecto> items, [
  List<GastoPrevisto> gastosPrevistos = const [],
]) {
  validarId(proyecto.id);
  validarTexto(proyecto.nombreCliente, 'El cliente');
  validarTexto(proyecto.descripcion, 'La descripción', maximo: 2000);
  validarImporte(proyecto.totalCotizadoCentavos);
  validarImporte(proyecto.cobroManoObraCentavos);
  final iva = proyecto.ivaPuntos;
  if (iva != null && (iva < 0 || iva > 10000)) {
    throw const FormatException('La tasa de IVA no es válida.');
  }
  if (proyecto.validezDias < 1 || proyecto.validezDias > 365) {
    throw const FormatException('La validez debe estar entre 1 y 365 días.');
  }
  if (proyecto.formaPago.length > 500 || proyecto.condiciones.length > 2000) {
    throw const FormatException(
      'La forma de pago o las condiciones son muy largas.',
    );
  }
  final margen = proyecto.margenDeseadoPuntos;
  if (margen != null && (margen < 0 || margen >= 10000)) {
    throw const FormatException('El margen debe estar entre 0 y 99,99 %.');
  }
  if (proyecto.id == 0 && proyecto.fechaFin == null) {
    throw const FormatException('Selecciona la fecha final prevista.');
  }
  if (proyecto.fechaFin?.isBefore(proyecto.fechaInicio) ?? false) {
    throw const FormatException('La fecha final debe ser posterior al inicio.');
  }
  if (proyecto.fechaFinReal != null && proyecto.fechaInicioReal == null) {
    throw const FormatException('La obra debe tener una fecha de inicio real.');
  }
  if (proyecto.fechaFinReal?.isBefore(proyecto.fechaInicioReal!) ?? false) {
    throw const FormatException(
      'La finalización real no puede ser anterior al inicio real.',
    );
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
    final materialValido = item.esServicio
        ? item.materialId == null
        : (item.materialId ?? 0) > 0;
    if (!materialValido ||
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
  var totalGastosPrevistos = 0;
  for (final gasto in gastosPrevistos) {
    validarTexto(gasto.categoria, 'La categoría', maximo: 80);
    if (gasto.descripcion.length > 2000) {
      throw const FormatException(
        'La descripción admite hasta 2000 caracteres.',
      );
    }
    validarImporte(gasto.montoCentavos, admiteCero: false);
    totalGastosPrevistos += gasto.montoCentavos;
    validarImporte(totalGastosPrevistos);
  }
}

void validarMaterial(MaterialObra material) {
  validarId(material.id);
  validarTexto(material.nombre, 'El nombre');
  validarTexto(material.unidadMedida, 'La unidad', maximo: 40);
  validarImporte(material.costoBaseCentavos);
  final ruta = material.imagenRuta;
  final atribucion = material.atribucionImagen;
  if (ruta != null &&
      (ruta.isEmpty ||
          ruta.length > 100 ||
          ruta.contains('/') ||
          ruta.contains('\\'))) {
    throw const FormatException('La referencia de imagen no es válida.');
  }
  if (atribucion != null) {
    if (ruta == null) {
      throw const FormatException(
        'La imagen debe estar guardada para conservar su atribución.',
      );
    }
    validarTexto(atribucion.titulo, 'El título de la imagen', maximo: 500);
    validarTexto(atribucion.autor, 'El autor de la imagen', maximo: 500);
    validarTexto(atribucion.licencia, 'La licencia de la imagen', maximo: 120);
    _validarUrlSegura(atribucion.fuenteUrl, 'La fuente de la imagen');
    if (atribucion.licenciaUrl != null) {
      _validarUrlSegura(atribucion.licenciaUrl!, 'La licencia de la imagen');
    }
  }
}

void _validarUrlSegura(String valor, String campo) {
  validarTexto(valor, campo, maximo: 2048);
  final url = Uri.tryParse(valor);
  if (url == null ||
      url.scheme != 'https' ||
      url.host.isEmpty ||
      url.userInfo.isNotEmpty) {
    throw FormatException('$campo debe usar una dirección HTTPS válida.');
  }
}

void validarGasto(Gasto gasto) {
  validarId(gasto.id);
  if (gasto.proyectoId != null && gasto.proyectoId! <= 0) {
    throw const FormatException('Selecciona un proyecto válido.');
  }
  validarImporte(gasto.montoCentavos, admiteCero: false);
  validarTexto(gasto.categoria, 'La categoría', maximo: 80);
  if (gasto.esConsumo) {
    final costo = gasto.costoUnitarioCentavos;
    if (gasto.cantidad! <= 0 || costo == null || costo < 0) {
      throw const FormatException('El consumo de material no es válido.');
    }
    validarTexto(gasto.nombreMaterial ?? '', 'El material');
  }
  if (gasto.nota.length > 2000) {
    throw const FormatException('La nota admite hasta 2000 caracteres.');
  }
}

void validarIngreso(Ingreso ingreso) {
  validarId(ingreso.id);
  if (ingreso.proyectoId != null && ingreso.proyectoId! <= 0) {
    throw const FormatException('Selecciona un proyecto válido.');
  }
  validarImporte(ingreso.montoCentavos, admiteCero: false);
  validarTexto(ingreso.categoria, 'La categoría', maximo: 80);
  if (ingreso.nota.length > 2000) {
    throw const FormatException('La nota admite hasta 2000 caracteres.');
  }
}

void validarCliente(Cliente cliente) {
  validarId(cliente.id);
  validarTexto(cliente.nombre, 'El nombre del cliente');
  for (final dato in [
    cliente.identificacion,
    cliente.telefono,
    cliente.correo,
    cliente.direccion,
  ]) {
    if (dato.length > 200) {
      throw const FormatException('Los datos del cliente son muy largos.');
    }
  }
}

void validarAdicional(Adicional adicional) {
  validarId(adicional.id);
  if (adicional.proyectoId <= 0) {
    throw const FormatException('Selecciona un proyecto válido.');
  }
  validarTexto(adicional.descripcion, 'La descripción', maximo: 500);
  validarImporte(adicional.montoCentavos, admiteCero: false);
}
