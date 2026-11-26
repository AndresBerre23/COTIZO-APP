import 'package:coti/aplicacion/coti_cubit.dart';
import 'package:coti/core/theme/app_theme.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:coti/funcionalidades/movimientos/movimientos_pagina.dart';
import 'package:coti/funcionalidades/reportes/reporte_mensual_pagina.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/con_cubits.dart';
import '../apoyo/repositorio_lectura.dart';

class _RepositorioIngresos extends RepositorioLectura {
  _RepositorioIngresos(super.datos);

  @override
  Future<int> guardarIngreso(Ingreso ingreso) async {
    datos = DatosLocales(
      proyectos: datos.proyectos,
      materiales: datos.materiales,
      items: datos.items,
      gastos: datos.gastos,
      ingresos: [
        ...datos.ingresos,
        Ingreso(
          id: datos.ingresos.length + 1,
          proyectoId: ingreso.proyectoId,
          montoCentavos: ingreso.montoCentavos,
          categoria: ingreso.categoria,
          metodo: ingreso.metodo,
          fecha: ingreso.fecha,
          nota: ingreso.nota,
        ),
      ],
    );
    return datos.ingresos.length;
  }
}

Future<_RepositorioIngresos> _montar(WidgetTester tester, Widget pagina) async {
  final repositorio = _RepositorioIngresos(datosMuestra());
  final cubit = CotiCubit(repositorio);
  await cubit.cargar();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    ConCubits(
      cubit: cubit,
      child: MaterialApp(
        theme: appTheme,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: pagina,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repositorio;
}

Future<void> _pulsar(WidgetTester tester, Finder elemento) async {
  await tester.pumpAndSettle();
  // La lista es perezosa: desplaza hasta que el elemento exista.
  if (elemento.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      elemento,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(elemento);
  await tester.pumpAndSettle();
  await tester.tap(elemento);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('registra un ingreso desde Movimientos y actualiza el balance', (
    tester,
  ) async {
    final repositorio = await _montar(tester, const MovimientosPagina());
    await _pulsar(tester, find.text('Ingresos'));
    await _pulsar(tester, find.text('Registrar el primer ingreso'));
    await tester.enterText(find.byType(TextFormField).first, '120,50');
    await _pulsar(tester, find.text('Guardar ingreso'));

    final ingreso = repositorio.datos.ingresos.single;
    expect(ingreso.montoCentavos, 12050);
    expect(ingreso.proyectoId, isNull);
    expect(ingreso.categoria, 'Venta');
    expect(find.text('+ \$ 120,00'), findsNothing);
    expect(find.text('+ \$ 120,50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final ancho in [360.0, 800.0, 1440.0]) {
    testWidgets('movimientos y reporte se adaptan a $ancho px', (tester) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _montar(tester, const MovimientosPagina());
      expect(tester.takeException(), isNull);
      await _pulsar(tester, find.text('Ingresos'));
      expect(tester.takeException(), isNull);
      await _montar(tester, const ReporteMensualPagina());
      expect(find.text('Ingresos por categoría'), findsOneWidget);
      await _pulsar(tester, find.byTooltip('Mes anterior'));
      expect(tester.takeException(), isNull);
    });
  }
}
