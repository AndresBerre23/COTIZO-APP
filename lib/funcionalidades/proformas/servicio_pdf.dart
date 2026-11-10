import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/formato.dart';
import '../../dominio/calcular_desglose_proforma.dart';
import '../../dominio/modelos.dart';

class ServicioPdf {
  Future<Uint8List> generar(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto> gastosPrevistos = const [],
  }) => _generar(proyecto, items, gastosPrevistos: gastosPrevistos);

  Future<Uint8List> generarReporteCierre(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto> gastosPrevistos = const [],
    List<Gasto> gastosAdicionales = const [],
  }) => _generar(
    proyecto,
    items,
    gastosPrevistos: gastosPrevistos,
    gastosAdicionales: gastosAdicionales,
    reporteCierre: true,
  );

  Future<Uint8List> _generar(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto> gastosPrevistos = const [],
    List<Gasto> gastosAdicionales = const [],
    bool reporteCierre = false,
  }) async {
    final partidas = items
        .where((item) => item.proyectoId == proyecto.id)
        .toList();
    final gastos = gastosPrevistos
        .where((gasto) => gasto.proyectoId == proyecto.id)
        .toList();
    final adicionales = gastosAdicionales
        .where((gasto) => gasto.proyectoId == proyecto.id)
        .toList();
    final desglose = calcularDesgloseProforma(proyecto, partidas, gastos);
    final esCierre = reporteCierre;
    final totalAdicionales = adicionales.fold<int>(
      0,
      (total, gasto) => total + gasto.montoCentavos,
    );
    final resultadoCierre = calcularResultadoCierre(desglose, adicionales);
    final fuente = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Regular.ttf'),
    );
    final negrita = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Bold.ttf'),
    );
    final documento = pw.Document(
      title: '${esCierre ? 'Cierre' : 'Cotización'} ${proyecto.id}',
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
            pw.Text(
              '${esCierre ? 'Cierre de obra' : 'Proforma'} / USD',
              style: const pw.TextStyle(fontSize: 9),
            ),
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
          pw.Text(
            esCierre && proyecto.fechaInicioReal != null
                ? 'Inicio real: ${fechaCorta(proyecto.fechaInicioReal!)}'
                : 'Inicio previsto: ${fechaCorta(proyecto.fechaInicio)}',
          ),
          if (esCierre && proyecto.fechaFinReal != null)
            pw.Text('Fin real: ${fechaCorta(proyecto.fechaFinReal!)}')
          else if (proyecto.fechaFin != null)
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
          _fila('Materiales', dinero(desglose.totalMaterialesCentavos)),
          if (desglose.cobroManoObraCentavos > 0)
            _fila(
              'Mano de obra propia',
              dinero(desglose.cobroManoObraCentavos),
            ),
          for (final gasto in gastos)
            _fila(
              gasto.descripcion.isEmpty
                  ? gasto.categoria
                  : '${gasto.categoria} · ${gasto.descripcion}',
              dinero(gasto.montoCentavos),
            ),
          if (desglose.ajusteComercialCentavos != 0 || esCierre)
            _fila('Ajuste comercial', dinero(desglose.ajusteComercialCentavos)),
          if (esCierre) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Gastos adicionales registrados',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            if (adicionales.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text('No se registraron gastos adicionales.'),
              )
            else
              for (final gasto in adicionales)
                _fila(
                  '${fechaHoraCorta(gasto.fecha)} · ${gasto.categoria}${gasto.nota.isEmpty ? '' : ' · ${gasto.nota}'}',
                  dinero(gasto.montoCentavos),
                ),
            _fila('Total de gastos adicionales', dinero(totalAdicionales)),
            pw.Divider(),
            _fila(
              'RESULTADO DESPUÉS DE GASTOS ADICIONALES',
              dinero(resultadoCierre),
              destacado: true,
            ),
          ],
          pw.Divider(),
          _fila(
            esCierre ? 'TOTAL ORIGINAL COTIZADO (USD)' : 'TOTAL COTIZADO (USD)',
            dinero(proyecto.totalCotizadoCentavos),
            destacado: true,
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            esCierre
                ? 'Reporte informativo de cierre. No constituye una factura ni un comprobante de pago.'
                : 'Cotización de referencia. No constituye una factura ni un comprobante de pago.',
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
    List<ItemProyecto> items, {
    List<GastoPrevisto> gastosPrevistos = const [],
  }) async {
    await directorio.create(recursive: true);
    final archivo = File(
      '${directorio.path}${Platform.pathSeparator}cotizacion-${proyecto.id}.pdf',
    );
    return archivo.writeAsBytes(
      await generar(proyecto, items, gastosPrevistos: gastosPrevistos),
      flush: true,
    );
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
