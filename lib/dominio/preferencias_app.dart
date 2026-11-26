enum ModoTema { sistema, claro, oscuro }

class PreferenciasApp {
  const PreferenciasApp({
    this.nombre = '',
    this.apellido = '',
    this.fotoRuta,
    this.modoTema = ModoTema.sistema,
    this.omitirAvisoNombre = false,
    this.tutorialVisto = false,
    this.bloqueoActivo = false,
    this.negocio = const DatosNegocio(),
    this.ivaPuntos = 1500,
    this.margenPuntos = 2000,
    this.validezDias = 15,
    this.formaPago = '',
    this.condiciones = '',
  });

  final String nombre;
  final String apellido;
  final String? fotoRuta;
  final ModoTema modoTema;
  final bool omitirAvisoNombre;

  // El tutorial de bienvenida se muestra hasta completarlo o saltarlo.
  final bool tutorialVisto;

  // Pide huella o clave del teléfono al abrir la app.
  final bool bloqueoActivo;
  final DatosNegocio negocio;

  // Valores con los que nace cada cotización; nulo si no aplica IVA.
  final int? ivaPuntos;
  final int margenPuntos;
  final int validezDias;
  final String formaPago;
  final String condiciones;

  // Nombre que aparece como emisor en los documentos.
  String get nombreEmisor => negocio.nombreComercial.trim().isNotEmpty
      ? negocio.nombreComercial.trim()
      : nombreCompleto;

  String get nombreCompleto => [
    nombre.trim(),
    apellido.trim(),
  ].where((parte) => parte.isNotEmpty).join(' ');

  bool get tieneNombre => nombre.trim().isNotEmpty;

  PreferenciasApp copyWith({
    String? nombre,
    String? apellido,
    String? fotoRuta,
    bool quitarFoto = false,
    ModoTema? modoTema,
    bool? omitirAvisoNombre,
    bool? tutorialVisto,
    bool? bloqueoActivo,
    DatosNegocio? negocio,
    int? ivaPuntos,
    bool sinIva = false,
    int? margenPuntos,
    int? validezDias,
    String? formaPago,
    String? condiciones,
  }) => PreferenciasApp(
    nombre: nombre ?? this.nombre,
    apellido: apellido ?? this.apellido,
    fotoRuta: quitarFoto ? null : fotoRuta ?? this.fotoRuta,
    modoTema: modoTema ?? this.modoTema,
    omitirAvisoNombre: omitirAvisoNombre ?? this.omitirAvisoNombre,
    tutorialVisto: tutorialVisto ?? this.tutorialVisto,
    bloqueoActivo: bloqueoActivo ?? this.bloqueoActivo,
    negocio: negocio ?? this.negocio,
    ivaPuntos: sinIva ? null : ivaPuntos ?? this.ivaPuntos,
    margenPuntos: margenPuntos ?? this.margenPuntos,
    validezDias: validezDias ?? this.validezDias,
    formaPago: formaPago ?? this.formaPago,
    condiciones: condiciones ?? this.condiciones,
  );
}

// Datos del emisor para la proforma (P-020).
class DatosNegocio {
  const DatosNegocio({
    this.nombreComercial = '',
    this.identificacion = '',
    this.telefono = '',
    this.correo = '',
    this.direccion = '',
    this.logoRuta,
  });

  final String nombreComercial;
  final String identificacion;
  final String telefono;
  final String correo;
  final String direccion;
  final String? logoRuta;

  DatosNegocio copyWith({
    String? nombreComercial,
    String? identificacion,
    String? telefono,
    String? correo,
    String? direccion,
    String? logoRuta,
    bool quitarLogo = false,
  }) => DatosNegocio(
    nombreComercial: nombreComercial ?? this.nombreComercial,
    identificacion: identificacion ?? this.identificacion,
    telefono: telefono ?? this.telefono,
    correo: correo ?? this.correo,
    direccion: direccion ?? this.direccion,
    logoRuta: quitarLogo ? null : logoRuta ?? this.logoRuta,
  );
}
