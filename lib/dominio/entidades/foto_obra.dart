// Foto del avance o del resultado de una obra.
class FotoObra {
  const FotoObra({
    this.id = 0,
    required this.proyectoId,
    required this.ruta,
    required this.miniatura,
    required this.fecha,
    this.nota = '',
  });

  final int id;
  final int proyectoId;

  // Nombres de archivo dentro de la carpeta privada de fotos.
  final String ruta;
  final String miniatura;
  final DateTime fecha;
  final String nota;

  FotoObra conNota(String nuevaNota) => FotoObra(
    id: id,
    proyectoId: proyectoId,
    ruta: ruta,
    miniatura: miniatura,
    fecha: fecha,
    nota: nuevaNota,
  );
}
