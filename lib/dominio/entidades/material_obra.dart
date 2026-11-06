class MaterialObra {
  const MaterialObra({
    this.id = 0,
    required this.nombre,
    required this.unidadMedida,
    required this.costoBaseCentavos,
  });

  final int id;
  final String nombre;
  final String unidadMedida;
  final int costoBaseCentavos;
}
