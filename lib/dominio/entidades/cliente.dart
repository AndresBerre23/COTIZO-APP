// Cliente reutilizable entre cotizaciones (P-021).
class Cliente {
  const Cliente({
    this.id = 0,
    required this.nombre,
    this.identificacion = '',
    this.telefono = '',
    this.correo = '',
    this.direccion = '',
  });

  final int id;
  final String nombre;
  final String identificacion;
  final String telefono;
  final String correo;
  final String direccion;

  bool get tieneContacto => [
    identificacion,
    telefono,
    correo,
    direccion,
  ].any((dato) => dato.trim().isNotEmpty);

  Cliente conId(int nuevoId) => Cliente(
    id: nuevoId,
    nombre: nombre,
    identificacion: identificacion,
    telefono: telefono,
    correo: correo,
    direccion: direccion,
  );
}
