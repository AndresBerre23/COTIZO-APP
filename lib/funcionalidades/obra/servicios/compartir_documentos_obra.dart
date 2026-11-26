import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../aplicacion/coti_cubit.dart';
import '../../../aplicacion/preferencias_cubit.dart';
import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../../proformas/servicio_pdf.dart';
import '../../proformas/servicios/datos_emisor_pdf.dart';
import 'servicio_pdf_adicional.dart';

// Comparte la orden de cambio de un adicional (P-031).
Future<void> compartirAdicional(
  BuildContext context,
  Proyecto proyecto,
  Adicional adicional,
  int numero,
) => _compartir(context, 'orden-cambio-${proyecto.id}-$numero.pdf', (
  emisor,
  cliente,
) {
  return ServicioPdfAdicional().generar(
    proyecto,
    adicional,
    numero: numero,
    emisor: emisor,
    cliente: cliente,
  );
}, proyecto.clienteId);

// Vuelve a generar la proforma tal como era en una versión anterior (P-032).
Future<void> compartirVersion(BuildContext context, VersionProforma version) =>
    _compartir(
      context,
      'cotizacion-${version.proyectoId}-v${version.numero}.pdf',
      (emisor, cliente) => ServicioPdf().generar(
        version.proyecto,
        version.items,
        gastosPrevistos: version.gastosPrevistos,
        nombreEmisor: emisor.nombre,
        negocio: emisor.negocio,
        cliente: cliente,
        logoEmisor: emisor.logo,
        codigo: '${codigoDocumento(version.proyectoId)} · v${version.numero}',
      ),
      version.proyecto.clienteId,
    );

Future<void> _compartir(
  BuildContext context,
  String archivo,
  Future<List<int>> Function(DatosEmisorPdf, Cliente?) generar,
  int? clienteId,
) async {
  final mensajero = ScaffoldMessenger.of(context);
  final ajustes = context.read<PreferenciasCubit>().state;
  final cliente = context.read<CotiCubit>().state.datos.clientePorId(clienteId);
  try {
    final emisor = await DatosEmisorPdf.desde(ajustes);
    final bytes = await generar(emisor, cliente);
    await Printing.sharePdf(
      bytes: Uint8List.fromList(bytes),
      filename: archivo,
    );
  } catch (_) {
    mensajero.showSnackBar(
      const SnackBar(content: Text('No se pudo generar el PDF.')),
    );
  }
}
