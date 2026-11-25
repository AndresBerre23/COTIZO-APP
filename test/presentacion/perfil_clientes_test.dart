import 'package:cotizo_app/aplicacion/cotizo_cubit.dart';
import 'package:cotizo_app/aplicacion/preferencias_cubit.dart';
import 'package:cotizo_app/core/theme/app_theme.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:cotizo_app/funcionalidades/clientes/clientes_pagina.dart';
import 'package:cotizo_app/funcionalidades/perfil/mi_perfil_pagina.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/con_cubits.dart';
import '../apoyo/repositorio_lectura.dart';

Future<void> _montar(WidgetTester tester, Widget pagina) async {
  final base = datosMuestra();
  final cubit = CotizoCubit(
    RepositorioLectura(
      DatosLocales(
        proyectos: base.proyectos,
        materiales: base.materiales,
        items: base.items,
        clientes: const [
          Cliente(id: 1, nombre: 'María Gómez', telefono: '0999999999'),
        ],
      ),
    ),
  );
  await cubit.cargar();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    ConCubits(
      cubit: cubit,
      child: MaterialApp(theme: appTheme, home: pagina),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pulsar(WidgetTester tester, Finder elemento) async {
  await tester.pumpAndSettle();
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
  testWidgets('guarda el margen y el IVA de las cotizaciones nuevas', (
    tester,
  ) async {
    await _montar(tester, const MiPerfilPagina());
    final margen = find.widgetWithText(TextFormField, 'Margen sugerido');
    await tester.scrollUntilVisible(
      margen,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(margen, '35');
    await _pulsar(tester, find.text('Guardar ajustes'));
    final ajustes = tester
        .element(find.byType(MiPerfilPagina))
        .read<PreferenciasCubit>()
        .state;
    expect(ajustes.margenPuntos, 3500);
    expect(ajustes.ivaPuntos, 1500);
    expect(tester.takeException(), isNull);
  });

  for (final ancho in [360.0, 800.0, 1440.0]) {
    testWidgets('perfil y clientes se adaptan a $ancho px', (tester) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _montar(tester, const MiPerfilPagina());
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _montar(tester, const ClientesPagina());
      expect(find.text('María Gómez'), findsOneWidget);
      await _pulsar(tester, find.text('María Gómez'));
      expect(find.text('Editar cliente'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
