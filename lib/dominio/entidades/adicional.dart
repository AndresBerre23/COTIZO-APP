// Trabajo extra acordado durante la obra; aumenta lo cobrable (P-031).
class Adicional {
  const Adicional({
    this.id = 0,
    required this.proyectoId,
    required this.descripcion,
    required this.montoCentavos,
    required this.fecha,
  });

  final int id;
  final int proyectoId;
  final String descripcion;

  // Precio al cliente sin IVA; se le aplica el IVA del proyecto.
  final int montoCentavos;
  final DateTime fecha;
}
