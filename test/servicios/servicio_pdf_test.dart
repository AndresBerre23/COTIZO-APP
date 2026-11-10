import 'dart:convert';
import 'dart:io';
import 'package:cotizo_app/funcionalidades/proformas/servicio_pdf.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import '../apoyo/repositorio_lectura.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('genera PDF con fuentes locales sin servicios remotos', () async {
    final datos = datosMuestra();
    const gastosPrevistos = [
      GastoPrevisto(
        proyectoId: 1,
        categoria: 'Transporte propio',
        montoCentavos: 2500,
        descripcion: 'Traslado del usuario',
      ),
    ];
    final bytes = await ServicioPdf().generar(
      datos.proyectos.single,
      datos.items,
      gastosPrevistos: gastosPrevistos,
      nombreEmisor: 'Ana Pérez',
    );
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(1000));
    if (Platform.environment['CAPTURAR_UI'] == '1') {
      final archivo = File('build/verificacion/proforma.pdf');
      archivo.parent.createSync(recursive: true);
      archivo.writeAsBytesSync(bytes);
    }
  });
  test('admite cotizaciones con varias páginas y nombres extensos', () async {
    final datos = datosMuestra();
    final items = List.generate(
      100,
      (indice) => ItemProyecto(
        proyectoId: 1,
        materialId: 1,
        cantidad: 2.5,
        costoUnitarioAplicadoCentavos: 12345,
        nombreMaterial:
            'Material $indice con descripción de instalación, acabado y suministro',
        unidadMedida: 'unidad',
      ),
    );
    final gastosPrevistos = List.generate(
      30,
      (indice) => GastoPrevisto(
        proyectoId: 1,
        categoria: 'Transporte de materiales',
        montoCentavos: 2500,
        descripcion: 'Gasto previsto $indice para traslado de materiales',
      ),
    );
    final bytes = await ServicioPdf().generar(
      datos.proyectos.single,
      items,
      gastosPrevistos: gastosPrevistos,
    );
    expect(bytes.length, greaterThan(5000));
  });
}
