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
    this.fechaInicioReal,
    this.fechaFinReal,
    this.margenDeseadoPuntos,
    this.estado = EstadoProyecto.borrador,
    required this.totalCotizadoCentavos,
    this.cobroManoObraCentavos = 0,
  });

  final int id;
  final String nombreCliente;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final DateTime? fechaInicioReal;
  final DateTime? fechaFinReal;
  final int? margenDeseadoPuntos;
  final EstadoProyecto estado;
  final int totalCotizadoCentavos;
  final int cobroManoObraCentavos;

  bool get esObra =>
      fechaInicioReal != null || estado == EstadoProyecto.finalizado;
  bool get estaEnCurso =>
      fechaInicioReal != null &&
      fechaFinReal == null &&
      estado != EstadoProyecto.finalizado;
  bool get estaFinalizada => estado == EstadoProyecto.finalizado;

  String get etapa {
    if (estaEnCurso) return 'En curso';
    if (estaFinalizada) return 'Finalizada';
    return estado.etiqueta;
  }

  bool estaRetrasada(DateTime ahora) {
    if (!estaEnCurso || fechaFin == null) return false;
    return _soloFecha(ahora).isAfter(_soloFecha(fechaFin!));
  }

  int diasDeRetraso(DateTime ahora) => estaRetrasada(ahora)
      ? _soloFecha(ahora).difference(_soloFecha(fechaFin!)).inDays
      : 0;

  Proyecto conEstado(EstadoProyecto nuevoEstado) => Proyecto(
    id: id,
    nombreCliente: nombreCliente,
    descripcion: descripcion,
    fechaInicio: fechaInicio,
    fechaFin: fechaFin,
    fechaInicioReal: fechaInicioReal,
    fechaFinReal: fechaFinReal,
    margenDeseadoPuntos: margenDeseadoPuntos,
    estado: nuevoEstado,
    totalCotizadoCentavos: totalCotizadoCentavos,
    cobroManoObraCentavos: cobroManoObraCentavos,
  );
}

DateTime _soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);
