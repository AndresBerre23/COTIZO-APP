enum EstadoProyecto {
  borrador('Borrador'),
  enviado('Enviado'),
  aprobado('Aprobado'),
  finalizado('Finalizado');

  const EstadoProyecto(this.etiqueta);
  final String etiqueta;
}

class Proyecto {
  const Proyecto({
    this.id = 0,
    required this.nombreCliente,
    required this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    this.estado = EstadoProyecto.borrador,
    required this.totalCotizadoCentavos,
  });

  final int id;
  final String nombreCliente;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final EstadoProyecto estado;
  final int totalCotizadoCentavos;

  Proyecto conEstado(EstadoProyecto nuevoEstado) => Proyecto(
    id: id,
    nombreCliente: nombreCliente,
    descripcion: descripcion,
    fechaInicio: fechaInicio,
    fechaFin: fechaFin,
    estado: nuevoEstado,
    totalCotizadoCentavos: totalCotizadoCentavos,
  );
}
