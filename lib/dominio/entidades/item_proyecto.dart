class ItemProyecto {
  const ItemProyecto({
    this.id = 0,
    this.proyectoId = 0,
    this.materialId,
    this.esServicio = false,
    required this.cantidad,
    required this.costoUnitarioAplicadoCentavos,
    required this.nombreMaterial,
    required this.unidadMedida,
  });

  final int id;
  final int proyectoId;
  // Nulo en partidas de servicio.
  final int? materialId;

  // Servicio con precio propio: no es costo ni recibe margen (P-026).
  final bool esServicio;
  final double cantidad;
  final int costoUnitarioAplicadoCentavos;
  final String nombreMaterial;
  final String unidadMedida;

  int get subtotalCentavos =>
      calcularSubtotal(cantidad, costoUnitarioAplicadoCentavos);

  int get costoCentavos => esServicio ? 0 : subtotalCentavos;
  int get precioServicioCentavos => esServicio ? subtotalCentavos : 0;
}

// Cantidad por precio unitario, redondeada al centavo sin errores de coma flotante.
int calcularSubtotal(double cantidad, int unitarioCentavos) {
  final milesimas = (cantidad * 1000).round();
  final parteEntera = unitarioCentavos ~/ 1000;
  final residuo = unitarioCentavos % 1000;
  return parteEntera * milesimas + (residuo * milesimas + 500) ~/ 1000;
}
