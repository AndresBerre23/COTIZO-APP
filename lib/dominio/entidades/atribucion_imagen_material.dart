class AtribucionImagenMaterial {
  const AtribucionImagenMaterial({
    required this.titulo,
    required this.autor,
    required this.fuenteUrl,
    required this.licencia,
    this.licenciaUrl,
  });

  final String titulo;
  final String autor;
  final String fuenteUrl;
  final String licencia;
  final String? licenciaUrl;
}
