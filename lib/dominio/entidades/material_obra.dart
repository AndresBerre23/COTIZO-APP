import 'atribucion_imagen_material.dart';

class MaterialObra {
  const MaterialObra({
    this.id = 0,
    required this.nombre,
    required this.unidadMedida,
    required this.costoBaseCentavos,
    this.imagenRuta,
    this.atribucionImagen,
  });

  final int id;
  final String nombre;
  final String unidadMedida;
  final int costoBaseCentavos;
  final String? imagenRuta;
  final AtribucionImagenMaterial? atribucionImagen;

  MaterialObra conImagen(
    String? ruta, {
    AtribucionImagenMaterial? atribucion,
  }) => MaterialObra(
    id: id,
    nombre: nombre,
    unidadMedida: unidadMedida,
    costoBaseCentavos: costoBaseCentavos,
    imagenRuta: ruta,
    atribucionImagen: atribucion,
  );
}
