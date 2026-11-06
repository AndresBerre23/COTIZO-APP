class ItemProyecto {
  const ItemProyecto({
    this.id = 0,
    this.proyectoId = 0,
    required this.materialId,
    required this.cantidad,
    required this.costoUnitarioAplicadoCentavos,
    required this.nombreMaterial,
    required this.unidadMedida,
  });

  final int id;
  final int proyectoId;
  final int materialId;
  final double cantidad;
  final int costoUnitarioAplicadoCentavos;
  final String nombreMaterial;
  final String unidadMedida;

  int get subtotalCentavos {
    final milesimas = (cantidad * 1000).round();
    final parteEntera = costoUnitarioAplicadoCentavos ~/ 1000;
    final residuo = costoUnitarioAplicadoCentavos % 1000;
    return parteEntera * milesimas + (residuo * milesimas + 500) ~/ 1000;
  }
}
