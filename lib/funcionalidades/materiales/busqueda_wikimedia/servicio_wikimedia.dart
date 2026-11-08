import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../dominio/modelos.dart';
import 'imagen_wikimedia.dart';
import 'licencias_wikimedia.dart';

class ServicioWikimedia {
  ServicioWikimedia({HttpClient? cliente})
    : _cliente = cliente ?? HttpClient() {
    _cliente.connectionTimeout = const Duration(seconds: 15);
  }

  static const _dominioApi = 'commons.wikimedia.org';
  static const _dominioArchivos = 'upload.wikimedia.org';
  static const _maximoJson = 2 * 1024 * 1024;
  static const _maximoMiniatura = 1024 * 1024;
  static const _maximoImagen = 8 * 1024 * 1024;
  static const _maximoCacheMiniaturas = 6 * 1024 * 1024;
  final HttpClient _cliente;
  final Map<String, Uint8List> _cacheMiniaturas = {};
  var _bytesEnCache = 0;

  Future<PaginaImagenesWikimedia> buscar(
    String consulta, {
    int offset = 0,
  }) async {
    final texto = consulta.trim();
    if (texto.isEmpty || texto.length > 100 || offset < 0) {
      throw const ErrorWikimedia('Escribe un nombre de material para buscar.');
    }
    final uri = Uri.https(_dominioApi, '/w/api.php', {
      'action': 'query',
      'format': 'json',
      'formatversion': '2',
      'generator': 'search',
      'gsrsearch': texto,
      'gsrnamespace': '6',
      'gsrlimit': '20',
      'gsroffset': '$offset',
      'prop': 'imageinfo',
      'iiprop': 'url|extmetadata',
      'iiurlwidth': '1280',
      'iiextmetadatafilter': 'Artist|Credit|LicenseShortName|LicenseUrl',
    });
    final bytes = await _solicitar(uri, _maximoJson);
    try {
      final respuesta = jsonDecode(utf8.decode(bytes));
      if (respuesta is! Map<String, dynamic>) {
        throw const FormatException();
      }
      final consultaApi = respuesta['query'];
      final paginas = consultaApi is Map ? consultaApi['pages'] : null;
      final imagenes = <ImagenWikimedia>[];
      if (paginas is List) {
        for (final pagina in paginas) {
          final imagen = _leerImagen(pagina);
          if (imagen != null) imagenes.add(imagen);
        }
      }
      final continuar = respuesta['continue'];
      final siguiente = continuar is Map ? continuar['gsroffset'] : null;
      return PaginaImagenesWikimedia(
        imagenes: List.unmodifiable(imagenes),
        siguienteOffset: siguiente is int ? siguiente : null,
      );
    } on FormatException {
      throw const ErrorWikimedia('Wikimedia devolvió una respuesta inválida.');
    }
  }

  Future<Uint8List> descargar(ImagenWikimedia imagen) async {
    if (!_esUrlPermitida(imagen.descargaUrl, _dominioArchivos)) {
      throw const ErrorWikimedia('La dirección de descarga no es segura.');
    }
    final cacheada = _cacheMiniaturas.remove(imagen.descargaUrl.toString());
    if (cacheada != null) {
      _bytesEnCache -= cacheada.lengthInBytes;
      return cacheada;
    }
    final respuesta = await _solicitar(
      imagen.descargaUrl,
      _maximoImagen,
      exigirImagen: true,
    );
    return respuesta;
  }

  Future<Uint8List> descargarMiniatura(Uri url) async {
    if (!_esUrlPermitida(url, _dominioArchivos)) {
      throw const ErrorWikimedia('La dirección de miniatura no es segura.');
    }
    final clave = url.toString();
    final guardada = _cacheMiniaturas[clave];
    if (guardada != null) return guardada;
    final bytes = await _solicitar(url, _maximoMiniatura, exigirImagen: true);
    if (_bytesEnCache + bytes.lengthInBytes > _maximoCacheMiniaturas) {
      _cacheMiniaturas.clear();
      _bytesEnCache = 0;
    }
    _cacheMiniaturas[clave] = bytes;
    _bytesEnCache += bytes.lengthInBytes;
    return bytes;
  }

  void cerrar() => _cliente.close(force: true);

  Future<Uint8List> _solicitar(
    Uri uri,
    int maximo, {
    bool exigirImagen = false,
  }) async {
    late HttpClientResponse respuesta;
    final dominioPermitido = exigirImagen ? _dominioArchivos : _dominioApi;
    if (!_esUrlPermitida(uri, dominioPermitido)) {
      throw const ErrorWikimedia('La dirección de Wikimedia no es segura.');
    }
    try {
      var destino = uri;
      var respuestaFinal = false;
      late HttpClientResponse respuestaLocal;
      for (var redireccion = 0; redireccion <= 2; redireccion++) {
        final solicitudLocal = await _cliente
            .getUrl(destino)
            .timeout(const Duration(seconds: 20));
        solicitudLocal
          ..followRedirects = false
          ..headers.set(HttpHeaders.userAgentHeader, 'Cotizo/1.0')
          ..headers.set(
            HttpHeaders.acceptHeader,
            exigirImagen ? 'image/*' : 'application/json',
          );
        respuestaLocal = await solicitudLocal.close().timeout(
          const Duration(seconds: 20),
        );
        if (respuestaLocal.statusCode < HttpStatus.movedPermanently ||
            respuestaLocal.statusCode >= HttpStatus.badRequest) {
          respuestaFinal = true;
          break;
        }
        final ubicacion = respuestaLocal.headers.value(
          HttpHeaders.locationHeader,
        );
        await respuestaLocal.drain<void>();
        if (ubicacion == null || redireccion == 2) {
          throw const ErrorWikimedia(
            'Wikimedia devolvió una redirección inválida.',
          );
        }
        destino = destino.resolve(ubicacion);
        if (!_esUrlPermitida(destino, dominioPermitido)) {
          throw const ErrorWikimedia('La descarga intentó salir de Wikimedia.');
        }
      }
      if (!respuestaFinal) {
        throw const ErrorWikimedia('Wikimedia redirigió demasiadas veces.');
      }
      respuesta = respuestaLocal;
    } on TimeoutException {
      throw const ErrorWikimedia(
        'La solicitud tardó demasiado. Intenta otra vez.',
      );
    } on SocketException {
      throw const ErrorWikimedia('No hay conexión a internet disponible.');
    } on HttpException {
      throw const ErrorWikimedia('No se pudo conectar con Wikimedia.');
    }
    if (respuesta.statusCode != HttpStatus.ok) {
      await respuesta.drain<void>();
      throw const ErrorWikimedia('Wikimedia no pudo completar la solicitud.');
    }
    if (respuesta.contentLength > maximo) {
      await respuesta.drain<void>();
      throw const ErrorWikimedia('El archivo supera el límite de descarga.');
    }
    if (exigirImagen &&
        !(respuesta.headers.contentType?.mimeType.startsWith('image/') ??
            false)) {
      await respuesta.drain<void>();
      throw const ErrorWikimedia(
        'Wikimedia no devolvió una imagen compatible.',
      );
    }
    final bytes = BytesBuilder(copy: false);
    var total = 0;
    try {
      await for (final bloque in respuesta.timeout(
        const Duration(seconds: 20),
      )) {
        total += bloque.length;
        if (total > maximo) {
          throw const ErrorWikimedia(
            'El archivo supera el límite de descarga.',
          );
        }
        bytes.add(bloque);
      }
    } on TimeoutException {
      throw const ErrorWikimedia(
        'La descarga tardó demasiado. Intenta otra vez.',
      );
    } on SocketException {
      throw const ErrorWikimedia(
        'La conexión se interrumpió durante la descarga.',
      );
    }
    return bytes.takeBytes();
  }

  ImagenWikimedia? _leerImagen(Object? valor) {
    if (valor is! Map) return null;
    final titulo = valor['title'];
    final info = valor['imageinfo'];
    if (titulo is! String ||
        info is! List ||
        info.isEmpty ||
        info.first is! Map) {
      return null;
    }
    final archivo = info.first as Map;
    final metadatos = archivo['extmetadata'];
    if (metadatos is! Map) return null;
    final licencia = _limpiarTexto(_leerCampo(metadatos, 'LicenseShortName'));
    final autorLeido = _limpiarTexto(
      _leerCampo(metadatos, 'Artist').isNotEmpty
          ? _leerCampo(metadatos, 'Artist')
          : _leerCampo(metadatos, 'Credit'),
    );
    final autor = autorLeido.isEmpty ? 'Autor no indicado' : autorLeido;
    final fuente = Uri.tryParse(archivo['descriptionurl'] as String? ?? '');
    final miniatura = Uri.tryParse(archivo['thumburl'] as String? ?? '');
    if (!admiteLicenciaWikimedia(licencia) ||
        autor.isEmpty ||
        fuente == null ||
        !_esUrlPermitida(fuente, _dominioApi) ||
        miniatura == null ||
        !_esUrlPermitida(miniatura, _dominioArchivos)) {
      return null;
    }
    final nombreArchivo = _limpiarTexto(
      titulo.replaceFirst(RegExp(r'^File:'), '').replaceAll('_', ' '),
    );
    final licenciaUrlTexto = _leerCampo(metadatos, 'LicenseUrl');
    final licenciaUrl = Uri.tryParse(licenciaUrlTexto);
    return ImagenWikimedia(
      titulo: nombreArchivo,
      miniaturaUrl: miniatura,
      descargaUrl: miniatura,
      atribucion: AtribucionImagenMaterial(
        titulo: nombreArchivo,
        autor: autor,
        fuenteUrl: fuente.toString(),
        licencia: licencia,
        licenciaUrl: licenciaUrl?.scheme == 'https'
            ? licenciaUrl.toString()
            : null,
      ),
    );
  }

  String _leerCampo(Map metadatos, String clave) {
    final dato = metadatos[clave];
    return dato is Map && dato['value'] is String
        ? dato['value'] as String
        : '';
  }

  String _limpiarTexto(String valor) => valor
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#160;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _esUrlPermitida(Uri uri, String dominio) =>
      uri.scheme == 'https' &&
      uri.host == dominio &&
      uri.userInfo.isEmpty &&
      uri.port == 443;
}
