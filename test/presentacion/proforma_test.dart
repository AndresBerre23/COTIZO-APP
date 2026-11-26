import 'package:coti/core/theme/app_theme.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:coti/funcionalidades/proformas/vista_proforma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra al cliente precios finales sin costos internos', (
    tester,
  ) async {
    final proyecto = Proyecto(
      id: 1,
      nombreCliente: 'Cliente',
      descripcion: 'Instalación',
      fechaInicio: DateTime(2026, 11, 8),
      fechaFin: DateTime(2026, 11, 8),
      totalCotizadoCentavos: 10000,
      ivaPuntos: 1500,
      formaPago: 'Mitad al iniciar',
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

    expect(find.text('Transporte propio · Traslado a la obra'), findsNothing);
    expect(find.text('Ajuste comercial'), findsNothing);
    expect(find.text('Mano de obra y ejecución'), findsOneWidget);
    expect(find.text('\$ 66,67'), findsOneWidget);
    expect(find.text('\$ 33,33'), findsOneWidget);
    // Subtotal, IVA del 15 % y total para el cliente.
    expect(find.text('\$ 100,00'), findsOneWidget);
    expect(find.text('\$ 15,00'), findsOneWidget);
    expect(find.text('\$ 115,00'), findsOneWidget);
    expect(find.text('Forma de pago: Mitad al iniciar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
