import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/formato.dart';
import '../../dominio/modelos.dart';

class ServicioPdf {
  Future<Uint8List> generar(Proyecto proyecto, List<ItemProyecto> items) async {
    final partidas = items
        .where((item) => item.proyectoId == proyecto.id)
        .toList();
    final costoMateriales = partidas.fold<int>(
      0,
      (total, item) => total + item.subtotalCentavos,
    );
    final fuente = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Regular.ttf'),
    );
    final negrita = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Bold.ttf'),
    );
    final documento = pw.Document(
      title: 'Cotización ${proyecto.id}',
      author: 'ObraPro',
      theme: pw.ThemeData.withFont(base: fuente, bold: negrita),
    );
    final azul = PdfColor.fromHex('#1E3A8A');
    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        maxPages: 100,
        header: (contexto) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 18),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'OBRAPRO',
                style: pw.TextStyle(
                  color: azul,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('COT-${proyecto.id.toString().padLeft(4, '0')}'),
            ],
          ),
        ),
        footer: (contexto) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Proforma / USD', style: const pw.TextStyle(fontSize: 9)),
            pw.Text(
              '${contexto.pageNumber} / ${contexto.pagesCount}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        build: (contexto) => [
          pw.Text(
            proyecto.nombreCliente,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(proyecto.descripcion),
          pw.SizedBox(height: 16),
          pw.Text('Inicio: ${fechaCorta(proyecto.fechaInicio)}'),
          if (proyecto.fechaFin != null)
            pw.Text('Fin previsto: ${fechaCorta(proyecto.fechaFin!)}'),
          pw.SizedBox(height: 8),
          pw.Text('Estado: ${proyecto.estado.etiqueta}'),
          pw.SizedBox(height: 24),
          if (partidas.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: [
                'Material',
                'Cantidad',
                'Unidad',
                'Unitario',
                'Subtotal',
              ],
              data: partidas
                  .map(
                    (item) => [
                      item.nombreMaterial,
                      '${item.cantidad}',
                      item.unidadMedida,
                      dinero(item.costoUnitarioAplicadoCentavos),
                      dinero(item.subtotalCentavos),
                    ],
                  )
                  .toList(),
              headerDecoration: pw.BoxDecoration(color: azul),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.all(8),
              border: null,
              oddRowDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F0F4FF'),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(),
                2: const pw.FlexColumnWidth(),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
              },
            ),
          pw.SizedBox(height: 24),
          _fila('Materiales', dinero(costoMateriales)),
          if (proyecto.totalCotizadoCentavos != costoMateriales)
            _fila(
              'Ajuste al total cotizado',
              dinero(proyecto.totalCotizadoCentavos - costoMateriales),
            ),
          pw.Divider(),
          _fila(
            'TOTAL COTIZADO (USD)',
            dinero(proyecto.totalCotizadoCentavos),
            destacado: true,
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Cotización de referencia. No constituye una factura ni un comprobante de pago.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return documento.save();
  }

  Future<File> guardarEn(
    Directory directorio,
    Proyecto proyecto,
    List<ItemProyecto> items,
  ) async {
    await directorio.create(recursive: true);
    final archivo = File(
      '${directorio.path}${Platform.pathSeparator}cotizacion-${proyecto.id}.pdf',
    );
    return archivo.writeAsBytes(await generar(proyecto, items), flush: true);
  }

  pw.Widget _fila(String etiqueta, String valor, {bool destacado = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                etiqueta,
                style: pw.TextStyle(
                  fontWeight: destacado
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Text(
              valor,
              style: pw.TextStyle(
                fontSize: destacado ? 16 : 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}
