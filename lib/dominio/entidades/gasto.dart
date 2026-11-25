import 'movimiento.dart';

class Gasto implements Movimiento {
  const Gasto({
    this.id = 0,
    this.proyectoId,
    required this.montoCentavos,
    required this.categoria,
    required this.fecha,
    this.nota = '',
  });

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
}
