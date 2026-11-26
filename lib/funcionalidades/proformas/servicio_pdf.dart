import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/formato.dart';
import '../../dominio/calcular_desglose_proforma.dart';
import '../../dominio/modelos.dart';
import 'componentes/bloque_personas_pdf.dart';
import 'componentes/diseno_documento_pdf.dart';
import 'componentes/filas_detalle_pdf.dart';
import 'componentes/secciones_proforma_pdf.dart';

class ServicioPdf {
  Future<Uint8List> generar(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto> gastosPrevistos = const [],
    String? nombreEmisor,
    DatosNegocio? negocio,
    Cliente? cliente,
    Uint8List? logoEmisor,
    String? codigo,
  }) => _generar(
    proyecto,
    items,
    gastosPrevistos: gastosPrevistos,
    nombreEmisor: nombreEmisor,
    negocio: negocio,
    cliente: cliente,
    logoEmisor: logoEmisor,
    codigo: codigo,
  );

  Future<Uint8List> generarReporteCierre(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto> gastosPrevistos = const [],
    List<Gasto> gastosAdicionales = const [],
    int adicionalesCobradosCentavos = 0,
  }) => _generar(
    proyecto,
    items,
    gastosPrevistos: gastosPrevistos,
    gastosAdicionales: gastosAdicionales,
    reporteCierre: true,
    adicionalesCobradosCentavos: adicionalesCobradosCentavos,
  );

  Future<Uint8List> _generar(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto> gastosPrevistos = const [],
    List<Gasto> gastosAdicionales = const [],
    bool reporteCierre = false,
    int adicionalesCobradosCentavos = 0,
    String? nombreEmisor,
    DatosNegocio? negocio,
    Cliente? cliente,
    Uint8List? logoEmisor,
    String? codigo,
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
    final resultadoCierre = calcularResultadoCierre(
      desglose,
      adicionales,
      adicionalesCobradosCentavos: adicionalesCobradosCentavos,
    );
    final filas = esCierre
        ? filasCostoInterno(partidas)
        : filasCliente(proyecto, partidas, gastos);
    final fuente = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Regular.ttf'),
    );
    final negrita = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Bold.ttf'),
    );
    // La proforma usa el logo del negocio si existe (P-020).
    final pw.ImageProvider logo = logoEmisor != null && !reporteCierre
        ? pw.MemoryImage(logoEmisor)
        : await DisenoDocumentoPdf.cargarLogo();
    final nombreAutor = nombreEmisor?.trim();
    final documento = pw.Document(
      title: '${esCierre ? 'Cierre' : 'Cotización'} ${proyecto.id}',
      author: nombreEmisor?.trim().isNotEmpty == true ? nombreEmisor : 'Coti',
      theme: pw.ThemeData.withFont(base: fuente, bold: negrita),
    );
    final azul = PdfColor.fromHex('#10144C');
    final morado = PdfColor.fromHex('#4C36B8');
    final turquesa = PdfColor.fromHex('#00796F');
    final superficie = PdfColor.fromHex('#F5F4FA');
    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        maxPages: 100,
        header: (contexto) => DisenoDocumentoPdf.encabezadoPagina(
          logo,
          esCierre,
          proyecto.id,
          contexto.pageNumber > 1,
          azul,
          morado,
        ),
        footer: (contexto) => DisenoDocumentoPdf.piePagina(
          esCierre,
          contexto.pageNumber,
          contexto.pagesCount,
        ),
        build: (contexto) => [
          DisenoDocumentoPdf.encabezado(
            logo,
            esCierre,
            proyecto.id,
            azul,
            morado,
            codigo: codigo,
          ),
          pw.SizedBox(height: 20),
          bloquePersonasPdf(
            nombreAutor?.isNotEmpty == true ? nombreAutor! : 'Coti',
            proyecto.nombreCliente,
            azul,
            turquesa,
            detallesEmisor: detallesNegocio(negocio),
            detallesCliente: detallesCliente(cliente),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            proyecto.descripcion,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromHex('#404252'),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              pw.Expanded(
                child: DisenoDocumentoPdf.datoCompacto(
                  esCierre && proyecto.fechaInicioReal != null
                      ? 'INICIO REAL'
                      : 'INICIO PREVISTO',
                  fechaCorta(
                    esCierre && proyecto.fechaInicioReal != null
                        ? proyecto.fechaInicioReal!
                        : proyecto.fechaInicio,
                  ),
                  superficie,
                  azul,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: DisenoDocumentoPdf.datoCompacto(
                  esCierre && proyecto.fechaFinReal != null
                      ? 'FIN REAL'
                      : 'FIN PREVISTO',
                  esCierre && proyecto.fechaFinReal != null
                      ? fechaCorta(proyecto.fechaFinReal!)
                      : proyecto.fechaFin == null
                      ? 'Sin definir'
                      : fechaCorta(proyecto.fechaFin!),
                  superficie,
                  azul,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: DisenoDocumentoPdf.datoCompacto(
                  esCierre ? 'ESTADO' : 'VÁLIDA HASTA',
                  esCierre
                      ? proyecto.estado.etiqueta
                      : fechaCorta(proyecto.validaHasta),
                  superficie,
                  azul,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 22),
          DisenoDocumentoPdf.tituloSeccion(
            esCierre ? 'Detalle de la obra' : 'Detalle de la proforma',
            azul,
          ),
          pw.SizedBox(height: 8),
          if (filas.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: [
                esCierre ? 'Material' : 'Descripción',
                'Cantidad',
                'Unidad',
                'Unitario',
                'Subtotal',
              ],
              data: filas,
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
                color: PdfColor.fromHex('#F3F1FF'),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(),
                2: const pw.FlexColumnWidth(),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
              },
            ),
          pw.SizedBox(height: 20),
          // El cliente no ve costos internos ni margen (D-008).
          if (esCierre) ...[
            DisenoDocumentoPdf.tituloSeccion('Resumen de costos', azul),
            pw.SizedBox(height: 4),
            DisenoDocumentoPdf.fila(
              'Materiales',
              dinero(desglose.totalMaterialesCentavos),
            ),
            if (desglose.cobroManoObraCentavos > 0)
              DisenoDocumentoPdf.fila(
                'Mano de obra propia',
                dinero(desglose.cobroManoObraCentavos),
              ),
            for (final gasto in gastos)
              DisenoDocumentoPdf.fila(
                gasto.descripcion.isEmpty
                    ? gasto.categoria
                    : '${gasto.categoria} · ${gasto.descripcion}',
                dinero(gasto.montoCentavos),
              ),
            DisenoDocumentoPdf.fila(
              'Ajuste comercial',
              dinero(desglose.ajusteComercialCentavos),
            ),
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
                DisenoDocumentoPdf.fila(
                  '${fechaHoraCorta(gasto.fecha)} · ${gasto.categoria}${gasto.nota.isEmpty ? '' : ' · ${gasto.nota}'}',
                  dinero(gasto.montoCentavos),
                ),
            DisenoDocumentoPdf.fila(
              'Total de gastos adicionales',
              dinero(totalAdicionales),
            ),
            pw.Divider(),
            DisenoDocumentoPdf.fila(
              'RESULTADO DESPUÉS DE GASTOS ADICIONALES',
              dinero(resultadoCierre),
              destacado: true,
            ),
          ],
          if (esCierre)
            DisenoDocumentoPdf.panelTotal(
              'TOTAL ORIGINAL COTIZADO',
              dinero(proyecto.totalCotizadoCentavos),
              azul,
            )
          else
            ...cierreProformaPdf(proyecto, azul),
        ],
      ),
    );
    return documento.save();
  }
}
