class GastoPrevisto {
  const GastoPrevisto({
    this.id = 0,
    this.proyectoId = 0,
    required this.categoria,
    required this.montoCentavos,
    this.descripcion = '',
  });

  final int id;
  final int proyectoId;
  final String categoria;
  final int montoCentavos;
  final String descripcion;
}
