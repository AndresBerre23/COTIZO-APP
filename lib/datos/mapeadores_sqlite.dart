import '../dominio/modelos.dart';

Proyecto leerProyecto(Map<String, Object?> fila) => Proyecto(
  id: fila['id'] as int,
  nombreCliente: fila['nombre_cliente'] as String,
  descripcion: fila['descripcion'] as String,
  fechaInicio: DateTime.fromMillisecondsSinceEpoch(fila['fecha_inicio'] as int),
  fechaFin: fila['fecha_fin'] == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(fila['fecha_fin'] as int),
  fechaInicioReal: fila['fecha_inicio_real'] == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(fila['fecha_inicio_real'] as int),
  fechaFinReal: fila['fecha_fin_real'] == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(fila['fecha_fin_real'] as int),
  margenDeseadoPuntos: fila['margen_deseado_puntos'] as int?,
  estado: EstadoProyecto.values.byName(fila['estado'] as String),
  totalCotizadoCentavos: fila['total_cotizado'] as int,
  cobroManoObraCentavos: fila['cobro_mano_obra'] as int? ?? 0,
  fechaCreacion: _fecha(fila['fecha_creacion']),
  clienteId: fila['cliente_id'] as int?,
  ivaPuntos: fila['iva_puntos'] as int?,
  validezDias:
      fila['validez_dias'] as int? ?? Proyecto.validezPredeterminadaDias,
  formaPago: fila['forma_pago'] as String? ?? '',
  condiciones: fila['condiciones'] as String? ?? '',
);

DateTime? _fecha(Object? valor) =>
    valor == null ? null : DateTime.fromMillisecondsSinceEpoch(valor as int);

Map<String, Object?> escribirProyecto(Proyecto proyecto) => {
  'nombre_cliente': proyecto.nombreCliente.trim(),
  'descripcion': proyecto.descripcion.trim(),
  'fecha_inicio': proyecto.fechaInicio.millisecondsSinceEpoch,
  'fecha_fin': proyecto.fechaFin?.millisecondsSinceEpoch,
  'fecha_inicio_real': proyecto.fechaInicioReal?.millisecondsSinceEpoch,
  'fecha_fin_real': proyecto.fechaFinReal?.millisecondsSinceEpoch,
  'margen_deseado_puntos': proyecto.margenDeseadoPuntos,
  'estado': proyecto.estado.name,
  'total_cotizado': proyecto.totalCotizadoCentavos,
  'cobro_mano_obra': proyecto.cobroManoObraCentavos,
  'fecha_creacion': proyecto.creadoEl.millisecondsSinceEpoch,
  'cliente_id': proyecto.clienteId,
  'iva_puntos': proyecto.ivaPuntos,
  'validez_dias': proyecto.validezDias,
  'forma_pago': proyecto.formaPago.trim(),
  'condiciones': proyecto.condiciones.trim(),
};

MaterialObra leerMaterial(Map<String, Object?> fila) => MaterialObra(
  id: fila['id'] as int,
  nombre: fila['nombre'] as String,
  unidadMedida: fila['unidad_medida'] as String,
  costoBaseCentavos: fila['costo_base'] as int,
  imagenRuta: fila['imagen_ruta'] as String?,
  atribucionImagen: fila['atribucion_titulo'] == null
      ? null
      : AtribucionImagenMaterial(
          titulo: fila['atribucion_titulo'] as String,
          autor: fila['atribucion_autor'] as String? ?? '',
          fuenteUrl: fila['atribucion_fuente'] as String? ?? '',
          licencia: fila['atribucion_licencia'] as String? ?? '',
          licenciaUrl: fila['atribucion_licencia_url'] as String?,
        ),
);

Map<String, Object?> escribirMaterial(MaterialObra material) => {
  'nombre': material.nombre.trim(),
  'unidad_medida': material.unidadMedida.trim(),
  'costo_base': material.costoBaseCentavos,
  'imagen_ruta': material.imagenRuta,
  'atribucion_titulo': material.atribucionImagen?.titulo,
  'atribucion_autor': material.atribucionImagen?.autor,
  'atribucion_fuente': material.atribucionImagen?.fuenteUrl,
  'atribucion_licencia': material.atribucionImagen?.licencia,
  'atribucion_licencia_url': material.atribucionImagen?.licenciaUrl,
};

ItemProyecto leerItem(Map<String, Object?> fila) => ItemProyecto(
  id: fila['id'] as int,
  proyectoId: fila['proyecto_id'] as int,
  materialId: fila['material_id'] as int?,
  esServicio: fila['es_servicio'] == 1,
  cantidad: (fila['cantidad'] as num).toDouble(),
  costoUnitarioAplicadoCentavos: fila['costo_unitario_aplicado'] as int,
  nombreMaterial: fila['nombre_material'] as String,
  unidadMedida: fila['unidad_medida'] as String,
);

Map<String, Object?> escribirItem(ItemProyecto item, int proyectoId) => {
  'proyecto_id': proyectoId,
  'material_id': item.esServicio ? null : item.materialId,
  'es_servicio': item.esServicio ? 1 : 0,
  'cantidad': item.cantidad,
  'costo_unitario_aplicado': item.costoUnitarioAplicadoCentavos,
  'subtotal': item.subtotalCentavos,
  'nombre_material': item.nombreMaterial.trim(),
  'unidad_medida': item.unidadMedida.trim(),
};

Gasto leerGasto(Map<String, Object?> fila) => Gasto(
  id: fila['id'] as int,
  proyectoId: fila['proyecto_id'] as int?,
  montoCentavos: fila['monto'] as int,
  categoria: fila['categoria'] as String,
  fecha: DateTime.fromMillisecondsSinceEpoch(fila['fecha'] as int),
  nota: fila['nota'] as String,
  materialId: fila['material_id'] as int?,
  cantidad: (fila['cantidad'] as num?)?.toDouble(),
  costoUnitarioCentavos: fila['costo_unitario'] as int?,
  nombreMaterial: fila['nombre_material'] as String?,
  origen: fila['origen'] as String?,
);

Ingreso leerIngreso(Map<String, Object?> fila) => Ingreso(
  id: fila['id'] as int,
  proyectoId: fila['proyecto_id'] as int?,
  montoCentavos: fila['monto'] as int,
  categoria: fila['categoria'] as String,
  metodo: MetodoPago.values.byName(fila['metodo'] as String),
  fecha: DateTime.fromMillisecondsSinceEpoch(fila['fecha'] as int),
  nota: fila['nota'] as String,
  origen: fila['origen'] as String?,
);

Map<String, Object?> escribirIngreso(Ingreso ingreso) => {
  'proyecto_id': ingreso.proyectoId,
  'monto': ingreso.montoCentavos,
  'categoria': ingreso.categoria.trim(),
  'metodo': ingreso.metodo.name,
  'fecha': ingreso.fecha.millisecondsSinceEpoch,
  'nota': ingreso.nota.trim(),
};

GastoPrevisto leerGastoPrevisto(Map<String, Object?> fila) => GastoPrevisto(
  id: fila['id'] as int,
  proyectoId: fila['proyecto_id'] as int,
  categoria: fila['categoria'] as String,
  montoCentavos: fila['monto'] as int,
  descripcion: fila['descripcion'] as String,
);

Map<String, Object?> escribirGastoPrevisto(
  GastoPrevisto gasto,
  int proyectoId,
) => {
  'proyecto_id': proyectoId,
  'categoria': gasto.categoria.trim(),
  'monto': gasto.montoCentavos,
  'descripcion': gasto.descripcion.trim(),
};

Map<String, Object?> escribirGasto(Gasto gasto) => {
  'proyecto_id': gasto.proyectoId,
  'monto': gasto.montoCentavos,
  'categoria': gasto.categoria.trim(),
  'fecha': gasto.fecha.millisecondsSinceEpoch,
  'nota': gasto.nota.trim(),
  'material_id': gasto.materialId,
  'cantidad': gasto.cantidad,
  'costo_unitario': gasto.costoUnitarioCentavos,
  'nombre_material': gasto.nombreMaterial?.trim(),
};

Adicional leerAdicional(Map<String, Object?> fila) => Adicional(
  id: fila['id'] as int,
  proyectoId: fila['proyecto_id'] as int,
  descripcion: fila['descripcion'] as String,
  montoCentavos: fila['monto'] as int,
  fecha: DateTime.fromMillisecondsSinceEpoch(fila['fecha'] as int),
);

Map<String, Object?> escribirAdicional(Adicional adicional) => {
  'proyecto_id': adicional.proyectoId,
  'descripcion': adicional.descripcion.trim(),
  'monto': adicional.montoCentavos,
  'fecha': adicional.fecha.millisecondsSinceEpoch,
};

Cliente leerCliente(Map<String, Object?> fila) => Cliente(
  id: fila['id'] as int,
  nombre: fila['nombre'] as String,
  identificacion: fila['identificacion'] as String,
  telefono: fila['telefono'] as String,
  correo: fila['correo'] as String,
  direccion: fila['direccion'] as String,
);

Map<String, Object?> escribirCliente(Cliente cliente) => {
  'nombre': cliente.nombre.trim(),
  'identificacion': cliente.identificacion.trim(),
  'telefono': cliente.telefono.trim(),
  'correo': cliente.correo.trim(),
  'direccion': cliente.direccion.trim(),
};

PreferenciasApp leerPreferencias(Map<String, Object?> fila) => PreferenciasApp(
  nombre: fila['nombre'] as String,
  apellido: fila['apellido'] as String,
  fotoRuta: fila['foto_ruta'] as String?,
  modoTema: ModoTema.values.firstWhere(
    (modo) => modo.name == fila['modo_tema'],
    orElse: () => ModoTema.sistema,
  ),
  omitirAvisoNombre: fila['omitir_aviso_nombre'] == 1,
  tutorialVisto: fila['tutorial_visto'] == 1,
  bloqueoActivo: fila['bloqueo_activo'] == 1,
  negocio: DatosNegocio(
    nombreComercial: fila['nombre_comercial'] as String? ?? '',
    identificacion: fila['identificacion'] as String? ?? '',
    telefono: fila['telefono'] as String? ?? '',
    correo: fila['correo'] as String? ?? '',
    direccion: fila['direccion'] as String? ?? '',
    logoRuta: fila['logo_ruta'] as String?,
  ),
  ivaPuntos: fila['iva_puntos'] as int?,
  margenPuntos: fila['margen_puntos'] as int? ?? 2000,
  validezDias:
      fila['validez_dias'] as int? ?? Proyecto.validezPredeterminadaDias,
  formaPago: fila['forma_pago'] as String? ?? '',
  condiciones: fila['condiciones'] as String? ?? '',
);

Map<String, Object?> escribirPreferencias(PreferenciasApp preferencias) => {
  'id': 1,
  'nombre': preferencias.nombre.trim(),
  'apellido': preferencias.apellido.trim(),
  'foto_ruta': preferencias.fotoRuta,
  'modo_tema': preferencias.modoTema.name,
  'omitir_aviso_nombre': preferencias.omitirAvisoNombre ? 1 : 0,
  'tutorial_visto': preferencias.tutorialVisto ? 1 : 0,
  'bloqueo_activo': preferencias.bloqueoActivo ? 1 : 0,
  'nombre_comercial': preferencias.negocio.nombreComercial.trim(),
  'identificacion': preferencias.negocio.identificacion.trim(),
  'telefono': preferencias.negocio.telefono.trim(),
  'correo': preferencias.negocio.correo.trim(),
  'direccion': preferencias.negocio.direccion.trim(),
  'logo_ruta': preferencias.negocio.logoRuta,
  'iva_puntos': preferencias.ivaPuntos,
  'margen_puntos': preferencias.margenPuntos,
  'validez_dias': preferencias.validezDias,
  'forma_pago': preferencias.formaPago.trim(),
  'condiciones': preferencias.condiciones.trim(),
};
