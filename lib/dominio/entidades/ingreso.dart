import 'movimiento.dart';

enum MetodoPago {
  efectivo('Efectivo'),
  transferencia('Transferencia'),
  tarjeta('Tarjeta'),
  otro('Otro');

  const MetodoPago(this.etiqueta);
  final String etiqueta;
}

// Dinero recibido, general o como cobro de un proyecto.
class Ingreso implements Movimiento {
  const Ingreso({
    this.id = 0,
    this.proyectoId,
    required this.montoCentavos,
    required this.categoria,
    required this.fecha,
    this.metodo = MetodoPago.efectivo,
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
  final MetodoPago metodo;
  @override
  final String nota;
}
