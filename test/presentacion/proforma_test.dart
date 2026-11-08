import 'package:cotizo_app/core/theme/app_theme.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:cotizo_app/funcionalidades/proformas/vista_proforma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('separa materiales, gastos previstos y ajuste comercial', (
    tester,
  ) async {
    final proyecto = Proyecto(
      id: 1,
      nombreCliente: 'Cliente',
      descripcion: 'Instalación',
      fechaInicio: DateTime(2026, 11, 8),
      fechaFin: DateTime(2026, 11, 8),
      totalCotizadoCentavos: 10000,
    );
    const item = ItemProyecto(
      proyectoId: 1,
      materialId: 1,
      cantidad: 1,
      costoUnitarioAplicadoCentavos: 6000,
      nombreMaterial: 'Cable',
      unidadMedida: 'm',
    );
    const previsto = GastoPrevisto(
      proyectoId: 1,
      categoria: 'Transporte propio',
      montoCentavos: 3000,
      descripcion: 'Traslado a la obra',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: VistaProforma(
              proyecto: proyecto,
              items: const [item],
              gastosPrevistos: const [previsto],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Transporte propio · Traslado a la obra'), findsOneWidget);
    expect(find.text('Ajuste comercial'), findsOneWidget);
    expect(find.text('\$ 10,00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
