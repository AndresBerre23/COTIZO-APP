import '../dominio/modelos.dart';

Proyecto leerProyecto(Map<String, Object?> fila) => Proyecto(
  id: fila['id'] as int,
  nombreCliente: fila['nombre_cliente'] as String,
  descripcion: fila['descripcion'] as String,
  fechaInicio: DateTime.fromMillisecondsSinceEpoch(fila['fecha_inicio'] as int),
  fechaFin: fila['fecha_fin'] == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(fila['fecha_fin'] as int),
  estado: EstadoProyecto.values.byName(fila['estado'] as String),
  totalCotizadoCentavos: fila['total_cotizado'] as int,
);

Map<String, Object?> escribirProyecto(Proyecto proyecto) => {
  'nombre_cliente': proyecto.nombreCliente.trim(),
  'descripcion': proyecto.descripcion.trim(),
  'fecha_inicio': proyecto.fechaInicio.millisecondsSinceEpoch,
  'fecha_fin': proyecto.fechaFin?.millisecondsSinceEpoch,
  'estado': proyecto.estado.name,
  'total_cotizado': proyecto.totalCotizadoCentavos,
};

MaterialObra leerMaterial(Map<String, Object?> fila) => MaterialObra(
  id: fila['id'] as int,
  nombre: fila['nombre'] as String,
  unidadMedida: fila['unidad_medida'] as String,
  costoBaseCentavos: fila['costo_base'] as int,
);

Map<String, Object?> escribirMaterial(MaterialObra material) => {
  'nombre': material.nombre.trim(),
  'unidad_medida': material.unidadMedida.trim(),
  'costo_base': material.costoBaseCentavos,
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

Map<String, Object?> escribirGasto(Gasto gasto) => {
  'proyecto_id': gasto.proyectoId,
  'monto': gasto.montoCentavos,
  'categoria': gasto.categoria.trim(),
  'fecha': gasto.fecha.millisecondsSinceEpoch,
  'nota': gasto.nota.trim(),
};
