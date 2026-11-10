enum ModoTema { sistema, claro, oscuro }

class PreferenciasApp {
  const PreferenciasApp({
    this.nombre = '',
    this.apellido = '',
    this.fotoRuta,
    this.modoTema = ModoTema.sistema,
    this.omitirAvisoNombre = false,
  });

  final String nombre;
  final String apellido;
  final String? fotoRuta;
  final ModoTema modoTema;
  final bool omitirAvisoNombre;

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
  }) => PreferenciasApp(
    nombre: nombre ?? this.nombre,
    apellido: apellido ?? this.apellido,
    fotoRuta: quitarFoto ? null : fotoRuta ?? this.fotoRuta,
    modoTema: modoTema ?? this.modoTema,
    omitirAvisoNombre: omitirAvisoNombre ?? this.omitirAvisoNombre,
  );
}
