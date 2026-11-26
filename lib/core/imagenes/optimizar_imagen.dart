import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imagen;

// Límites de cada tipo de imagen: lado mayor, peso máximo y calidad JPEG.
typedef PerfilImagen = ({int lado, int pesoKb, int calidad, int calidadMinima});

// Materiales, logo y perfil: imágenes pequeñas de referencia.
const perfilReferencia = (
  lado: 1280,
  pesoKb: 300,
  calidad: 88,
  calidadMinima: 56,
);

// Fotos de obra: nitidez suficiente para mostrar el trabajo al cliente.
// Una foto de 12 MP (3 a 5 MB) queda en unos 300 a 600 KB.
const perfilFotoObra = (
  lado: 1920,
  pesoKb: 600,
  calidad: 85,
  calidadMinima: 72,
);

// Miniatura para la galería: carga rápido y ocupa poco.
const perfilMiniatura = (lado: 400, pesoKb: 60, calidad: 78, calidadMinima: 60);

Future<Uint8List> optimizarImagen(
  Uint8List bytes, {
  PerfilImagen perfil = perfilReferencia,
}) => compute(_optimizar, (bytes: bytes, perfil: perfil));

// Devuelve la foto optimizada y su miniatura en un solo paso.
Future<({Uint8List foto, Uint8List miniatura})> optimizarFotoObra(
  Uint8List bytes,
) => compute(_optimizarFotoObra, bytes);

({Uint8List foto, Uint8List miniatura}) _optimizarFotoObra(Uint8List bytes) {
  final limpia = _decodificar(bytes);
  return (
    foto: _comprimir(limpia, perfilFotoObra),
    miniatura: _comprimir(limpia, perfilMiniatura),
  );
}

Uint8List _optimizar(({Uint8List bytes, PerfilImagen perfil}) entrada) =>
    _comprimir(_decodificar(entrada.bytes), entrada.perfil);

// Corrige la orientación y quita metadatos (ubicación, cámara, etc.).
imagen.Image _decodificar(Uint8List bytes) {
  imagen.Image? original;
  try {
    original = imagen.decodeImage(bytes);
  } catch (_) {
    // Algunos decodificadores fallan con datos cortos en vez de devolver nulo.
    original = null;
  }
  if (original == null) {
    throw const FormatException(
      'El archivo seleccionado no es una imagen válida.',
    );
  }
  return imagen.bakeOrientation(original)
    ..exif = imagen.ExifData()
    ..iccProfile = null
    ..textData = null;
}

// Baja primero la calidad y, solo si no alcanza, el tamaño.
Uint8List _comprimir(imagen.Image fuente, PerfilImagen perfil) {
  var resultado = _ajustarLado(fuente, perfil.lado);
  var calidad = perfil.calidad;
  for (var intento = 0; intento < 16; intento++) {
    final comprimida = Uint8List.fromList(
      imagen.encodeJpg(resultado, quality: calidad),
    );
    if (comprimida.lengthInBytes <= perfil.pesoKb * 1024) return comprimida;
    if (calidad - 6 >= perfil.calidadMinima) {
      calidad -= 6;
      continue;
    }
    final lado = (_ladoMayor(resultado) * 0.85).round();
    if (lado < 240) break;
    resultado = _ajustarLado(resultado, lado);
  }
  throw FormatException(
    'No se pudo reducir la imagen al tamaño máximo de ${perfil.pesoKb} KB.',
  );
}

int _ladoMayor(imagen.Image fuente) =>
    fuente.width >= fuente.height ? fuente.width : fuente.height;

imagen.Image _ajustarLado(imagen.Image fuente, int lado) {
  if (_ladoMayor(fuente) <= lado) return fuente;
  final horizontal = fuente.width >= fuente.height;
  return imagen.copyResize(
    fuente,
    width: horizontal ? lado : null,
    height: horizontal ? null : lado,
    interpolation: imagen.Interpolation.average,
  );
}
