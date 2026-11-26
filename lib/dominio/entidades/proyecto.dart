enum EstadoProyecto {
  borrador('Borrador'),
  enviado('Enviado'),
  aprobado('Aprobado'),
  finalizado('Finalizado'),
  rechazado('Rechazado'),
  cancelado('Cancelado');

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
    this.fechaCreacion,
    this.clienteId,
    this.ivaPuntos,
    this.validezDias = validezPredeterminadaDias,
    this.formaPago = '',
    this.condiciones = '',
  });

  static const validezPredeterminadaDias = 15;

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
  final DateTime? fechaCreacion;
  final int? clienteId;

  // Tasa en centésimas de punto (1500 = 15 %); nulo si no aplica IVA.
  final int? ivaPuntos;
  final int validezDias;
  final String formaPago;
  final String condiciones;

  DateTime get creadoEl => fechaCreacion ?? fechaInicio;
  DateTime get validaHasta =>
      DateTime(creadoEl.year, creadoEl.month, creadoEl.day + validezDias);

  // El total cotizado es la base imponible; el cliente paga el total con IVA.
  int get ivaCentavos => ivaDe(totalCotizadoCentavos);

  int ivaDe(int baseCentavos) =>
      ivaPuntos == null ? 0 : (baseCentavos * ivaPuntos! + 5000) ~/ 10000;
  int conIva(int baseCentavos) => baseCentavos + ivaDe(baseCentavos);
  int get totalConIvaCentavos => totalCotizadoCentavos + ivaCentavos;

  bool get esObra =>
      fechaInicioReal != null || estado == EstadoProyecto.finalizado;
  // Acepta gastos reales y cuenta en el balance (D-009).
  bool get admiteGastos => esObra || estado == EstadoProyecto.aprobado;
  bool get estaEnCurso =>
      fechaInicioReal != null &&
      fechaFinReal == null &&
      estado != EstadoProyecto.finalizado &&
      estado != EstadoProyecto.cancelado;
  bool get estaFinalizada => estado == EstadoProyecto.finalizado;

  String get etapa {
    if (estado == EstadoProyecto.cancelado) return 'Cancelado';
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
    fechaCreacion: fechaCreacion,
    clienteId: clienteId,
    ivaPuntos: ivaPuntos,
    validezDias: validezDias,
    formaPago: formaPago,
    condiciones: condiciones,
  );
}

DateTime _soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);
