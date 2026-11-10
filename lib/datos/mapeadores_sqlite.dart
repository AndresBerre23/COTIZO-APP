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
);

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
  materialId: fila['material_id'] as int,
  cantidad: (fila['cantidad'] as num).toDouble(),
  costoUnitarioAplicadoCentavos: fila['costo_unitario_aplicado'] as int,
  nombreMaterial: fila['nombre_material'] as String,
  unidadMedida: fila['unidad_medida'] as String,
);

Map<String, Object?> escribirItem(ItemProyecto item, int proyectoId) => {
  'proyecto_id': proyectoId,
  'material_id': item.materialId,
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
);

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
};
