import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Emisor y cliente con sus datos de contacto (P-020, P-021).
pw.Widget bloquePersonasPdf(
  String nombreEmisor,
  String nombreCliente,
  PdfColor azul,
  PdfColor turquesa, {
  List<String> detallesEmisor = const [],
  List<String> detallesCliente = const [],
}) => pw.Container(
  width: double.infinity,
  padding: const pw.EdgeInsets.all(14),
  decoration: pw.BoxDecoration(
    color: PdfColor.fromHex('#F5F4FA'),
    borderRadius: pw.BorderRadius.circular(10),
    border: pw.Border.all(color: PdfColor.fromHex('#E6E3F2')),
  ),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'ELABORADA POR',
        style: pw.TextStyle(
          color: turquesa,
          fontSize: 8,
          letterSpacing: 1,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        nombreEmisor,
        style: pw.TextStyle(
          color: azul,
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      for (final detalle in detallesEmisor) _detalle(detalle),
      pw.SizedBox(height: 10),
      pw.Divider(color: PdfColor.fromHex('#DAD7E8')),
      pw.SizedBox(height: 8),
      pw.Text(
        'CLIENTE',
        style: pw.TextStyle(
          color: PdfColor.fromHex('#68697A'),
          fontSize: 8,
          letterSpacing: 1,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        nombreCliente,
        style: pw.TextStyle(
          color: azul,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      for (final detalle in detallesCliente) _detalle(detalle),
    ],
  ),
);

pw.Widget _detalle(String texto) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 2),
  child: pw.Text(
    texto,
    style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#404252')),
  ),
);
