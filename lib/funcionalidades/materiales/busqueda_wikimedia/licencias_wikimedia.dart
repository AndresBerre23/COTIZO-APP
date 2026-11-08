bool admiteLicenciaWikimedia(String licencia) {
  final normalizada = licencia.toLowerCase();
  if (normalizada.contains('public domain') ||
      normalizada.contains('dominio público') ||
      normalizada.contains('cc0')) {
    return true;
  }
  if (normalizada.contains('noncommercial') ||
      normalizada.contains('no comercial') ||
      normalizada.contains('-nc') ||
      normalizada.contains('no derivatives') ||
      normalizada.contains('sin obras derivadas') ||
      normalizada.contains('-nd')) {
    return false;
  }
  return RegExp(
    r'\bcc\s+by(?:-sa)?(?:\s|$)',
    caseSensitive: false,
  ).hasMatch(licencia);
}
