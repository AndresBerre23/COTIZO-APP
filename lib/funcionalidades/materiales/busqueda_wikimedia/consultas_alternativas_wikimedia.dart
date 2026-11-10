const _consultasAlternativas = <String, List<String>>{
  'correa de hierro': ['iron strap hinge', 'strap hinge'],
  'correas de hierro': ['iron strap hinge', 'strap hinge'],
};

List<String> obtenerConsultasAlternativasWikimedia(String consulta) {
  final normalizada = consulta.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
  return _consultasAlternativas[normalizada] ?? const [];
}
