import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/formato.dart';
import '../../../dominio/calcular_resumen_mes.dart';
import '../../proformas/componentes/diseno_documento_pdf.dart';

// PDF del resumen mensual por categoría (P-014).
class ServicioPdfReporte {
  Future<Uint8List> generar(ResumenMes resumen, {String? nombreEmisor}) async {
    final fuente = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Regular.ttf'),
    );
    final negrita = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Bold.ttf'),
    );
    final logo = await DisenoDocumentoPdf.cargarLogo();
    final azul = PdfColor.fromHex('#10144C');
    final periodo = mesLargo(resumen.mes);
    final documento = pw.Document(
      title: 'Reporte de $periodo',
      author: nombreEmisor?.trim().isNotEmpty == true ? nombreEmisor : 'Coti',
      theme: pw.ThemeData.withFont(base: fuente, bold: negrita),
    );
    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (contexto) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Reporte mensual / USD   ${contexto.pageNumber} / ${contexto.pagesCount}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        build: (contexto) => [
          pw.Row(
            children: [
              pw.Image(logo, width: 40, height: 40),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REPORTE MENSUAL',
                      style: pw.TextStyle(
                        color: azul,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(periodo, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          DisenoDocumentoPdf.tituloSeccion('Ingresos por categoría', azul),
          pw.SizedBox(height: 4),
          ..._filas(resumen.ingresosPorCategoria, 'No hay ingresos este mes.'),
          DisenoDocumentoPdf.fila(
            'Total de ingresos',
            dinero(resumen.ingresosCentavos),
            destacado: true,
          ),
          pw.SizedBox(height: 20),
          DisenoDocumentoPdf.tituloSeccion('Gastos por categoría', azul),
          pw.SizedBox(height: 4),
          ..._filas(resumen.gastosPorCategoria, 'No hay gastos este mes.'),
          DisenoDocumentoPdf.fila(
            'Total de gastos',
            dinero(resumen.gastosCentavos),
            destacado: true,
          ),
          pw.SizedBox(height: 20),
          DisenoDocumentoPdf.panelTotal(
            'BALANCE DEL MES',
            dinero(resumen.balanceCentavos),
            azul,
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Ingresos menos gastos registrados en Coti. Documento informativo.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return documento.save();
  }

  List<pw.Widget> _filas(Map<String, int> totales, String vacio) =>
      totales.isEmpty
      ? [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            child: pw.Text(vacio),
          ),
        ]
      : [
          for (final MapEntry(key: categoria, value: monto) in totales.entries)
            DisenoDocumentoPdf.fila(categoria, dinero(monto)),
        ];
}
