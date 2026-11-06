class Gasto {
  const Gasto({
    this.id = 0,
    this.proyectoId,
    required this.montoCentavos,
    required this.categoria,
    required this.fecha,
    this.nota = '',
  });

  final int id;
  final int? proyectoId;
  final int montoCentavos;
  final String categoria;
  final DateTime fecha;
  final String nota;
}
