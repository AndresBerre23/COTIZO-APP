import 'package:flutter/foundation.dart';

import '../../../datos/almacen_imagen_local.dart';
import '../../../dominio/modelos.dart';

// Nombre, datos y logo del negocio listos para cualquier PDF (P-020).
class DatosEmisorPdf {
  const DatosEmisorPdf({this.nombre, required this.negocio, this.logo});

  final String? nombre;
  final DatosNegocio negocio;
  final Uint8List? logo;

  static Future<DatosEmisorPdf> desde(PreferenciasApp ajustes) async =>
      DatosEmisorPdf(
        nombre: ajustes.nombreEmisor.isEmpty ? null : ajustes.nombreEmisor,
        negocio: ajustes.negocio,
        logo: await _leerLogo(ajustes.negocio.logoRuta),
      );

  // Un logo ausente o dañado no impide crear el PDF.
  static Future<Uint8List?> _leerLogo(String? ruta) async {
    if (ruta == null) return null;
    try {
      final archivo = await const AlmacenLogoNegocio().obtenerArchivo(ruta);
      return await archivo.exists() ? await archivo.readAsBytes() : null;
    } catch (_) {
      return null;
    }
  }
}
