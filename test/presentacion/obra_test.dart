import 'package:coti/aplicacion/coti_cubit.dart';
import 'package:coti/core/theme/app_theme.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:coti/funcionalidades/cotizaciones/detalle_proyecto_pagina.dart';
import 'package:coti/funcionalidades/proformas/archivo_documentos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/con_cubits.dart';
import '../apoyo/repositorio_lectura.dart';

class _RepositorioObra extends RepositorioLectura {
  _RepositorioObra(super.datos);

  Adicional? adicionalGuardado;

  @override
  Future<int> guardarAdicional(Adicional adicional) async {
    adicionalGuardado = adicional;
    return 1;
  }
}

DatosLocales _datos() {
  final base = datosMuestra();
  final proyecto = base.proyectos.single;
  return DatosLocales(
    proyectos: base.proyectos,
    materiales: base.materiales,
    items: base.items,
    gastos: [
      Gasto(
        proyectoId: proyecto.id,
        montoCentavos: 9000,
        categoria: Gasto.categoriaConsumo,
        fecha: DateTime(2026, 11, 10),
        materialId: base.items.first.materialId,
        cantidad: 4,
        costoUnitarioCentavos: 2250,
        nombreMaterial: base.items.first.nombreMaterial,
      ),
    ],
    adicionales: [
      Adicional(
        proyectoId: proyecto.id,
        descripcion: 'Repisa adicional',
        montoCentavos: 15000,
        fecha: DateTime(2026, 11, 12),
      ),
    ],
    versiones: [
      VersionProforma(
        proyectoId: proyecto.id,
        numero: 1,
        fecha: DateTime(2026, 11, 9),
        proyecto: proyecto,
        items: base.items,
        gastosPrevistos: const [],
      ),
    ],
  );
}

Future<_RepositorioObra> _montar(WidgetTester tester) async {
  final repositorio = _RepositorioObra(_datos());
  final cubit = CotiCubit(repositorio);
  await cubit.cargar();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    ConCubits(
      cubit: cubit,
      child: MaterialApp(
        theme: appTheme,
        home: const DetalleProyectoPagina(proyectoId: 1),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repositorio;
}

Future<void> _mostrar(WidgetTester tester, Finder elemento) async {
  await tester.scrollUntilVisible(
    elemento,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('registra un adicional desde el detalle de la obra', (
    tester,
  ) async {
    final repositorio = await _montar(tester);
    await _mostrar(tester, find.text('Registrar adicional'));
    await tester.tap(find.text('Registrar adicional'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Trabajo adicional'),
      'Pintar una pared extra',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '80');
    await tester.tap(find.text('Guardar adicional'));
    await tester.pumpAndSettle();
    expect(repositorio.adicionalGuardado!.montoCentavos, 8000);
    expect(repositorio.adicionalGuardado!.proyectoId, 1);
    expect(tester.takeException(), isNull);
  });

  for (final ancho in [360.0, 800.0, 1440.0]) {
    testWidgets('consumos, adicionales y versiones a $ancho px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _montar(tester);
      await _mostrar(tester, find.text('Repisa adicional'));
      await _mostrar(tester, find.textContaining('Ahorro'));
      await _mostrar(tester, find.text('Versiones de la proforma'));
      expect(find.textContaining('Vigente: versión 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('un proyecto con dinero se cancela en lugar de eliminarse', (
    tester,
  ) async {
    final repositorio = await _montar(tester);
    await _mostrar(tester, find.text('Cancelar cotización'));
    expect(find.textContaining('Eliminar cotización'), findsNothing);
    await tester.tap(find.text('Cancelar cotización'));
    await tester.pumpAndSettle();
    expect(find.textContaining('conserva su historial'), findsOneWidget);
    expect(repositorio.adicionalGuardado, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la galería de Documentos agrupa las fotos por obra', (
    tester,
  ) async {
    final base = _datos();
    final repositorio = _RepositorioObra(
      DatosLocales(
        proyectos: base.proyectos,
        materiales: base.materiales,
        items: base.items,
        fotos: [
          FotoObra(
            proyectoId: 1,
            ruta: 'a.jpg',
            miniatura: 'a-m.jpg',
            fecha: DateTime(2026, 11, 20),
            nota: 'Mesón terminado',
          ),
        ],
      ),
    );
    final cubit = CotiCubit(repositorio);
    await cubit.cargar();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      ConCubits(
        cubit: cubit,
        child: MaterialApp(
          theme: appTheme,
          home: const Scaffold(body: ArchivoDocumentosPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fotos (1)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 fotos'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'mesón');
    await tester.pumpAndSettle();
    expect(find.textContaining('1 fotos'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'otra cosa');
    await tester.pumpAndSettle();
    expect(find.text('No hay coincidencias'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
