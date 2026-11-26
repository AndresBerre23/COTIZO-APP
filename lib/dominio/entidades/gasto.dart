import 'movimiento.dart';

class Gasto implements Movimiento {
  const Gasto({
    this.id = 0,
    this.proyectoId,
    required this.montoCentavos,
    required this.categoria,
    required this.fecha,
    this.nota = '',
    this.origen,
    this.materialId,
    this.cantidad,
    this.costoUnitarioCentavos,
    this.nombreMaterial,
  });

  // Categoría con la que se guardan los consumos de material.
  static const categoriaConsumo = 'Materiales de obra';

  // Dinero devuelto al cliente; descuenta lo cobrado, no es costo de la obra.
  static const categoriaDevolucion = 'Devolución a cliente';

  @override
  final int id;
  @override
  final int? proyectoId;
  @override
  final int montoCentavos;
  @override
  final String categoria;
  @override
  final DateTime fecha;
  @override
  final String nota;
  @override
  final String? origen;

  // Solo en consumos: material, cantidad y costo real (P-030).
  final int? materialId;
  final double? cantidad;
  final int? costoUnitarioCentavos;
  final String? nombreMaterial;

  bool get esConsumo => cantidad != null;
  bool get esDevolucion => categoria == categoriaDevolucion;
}
