import 'package:cotizo_app/aplicacion/cotizo_cubit.dart';
import 'package:cotizo_app/core/theme/app_theme.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:cotizo_app/funcionalidades/cotizaciones/detalle_proyecto_pagina.dart';
import 'package:cotizo_app/funcionalidades/cotizaciones/editor_proyecto_pagina.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/repositorio_lectura.dart';

class _RepositorioCotizaciones extends RepositorioLectura {
  _RepositorioCotizaciones() : super(datosMuestra());
  Proyecto? proyectoGuardado;
  List<ItemProyecto> partidasGuardadas = [];

  @override
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items,
  ) async {
    proyectoGuardado = proyecto;
    partidasGuardadas = List.of(items);
    escrituras++;
    return proyecto.id == 0 ? 2 : proyecto.id;
  }
}

Future<CotizoCubit> _montarEditor(
  WidgetTester tester,
  _RepositorioCotizaciones repositorio, {
  Proyecto? proyecto,
}) async {
  final cubit = CotizoCubit(repositorio);
  await cubit.cargar();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => EditorProyectoPagina(proyecto: proyecto),
                ),
              ),
              child: const Text('Abrir editor'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir editor'));
  await tester.pumpAndSettle();
  return cubit;
}

Future<void> _escribir(
  WidgetTester tester,
  String etiqueta,
  String texto,
) async {
  final campo = find.widgetWithText(TextFormField, etiqueta);
  await tester.ensureVisible(campo);
  await tester.enterText(campo, texto);
  await tester.pumpAndSettle();
}

Future<void> _pulsar(WidgetTester tester, String texto) async {
  final control = find.text(texto);
  await tester.ensureVisible(control);
  await tester.tap(control);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('valida y guarda una cotización con cantidades decimales', (
    tester,
  ) async {
    final repositorio = _RepositorioCotizaciones();
    await _montarEditor(tester, repositorio);
    await _pulsar(tester, 'Guardar cotización');
    expect(repositorio.proyectoGuardado, isNull);
    expect(find.text('Completa este campo.'), findsNWidgets(2));
    await _escribir(tester, 'Cliente / titular', 'Cliente de prueba');
    await _escribir(
      tester,
      'Descripción del proyecto',
      'Revestimiento de baño',
    );
    await _pulsar(tester, 'Añadir material');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Porcelanato gris 60 × 60').last);
    await tester.pumpAndSettle();
    await _escribir(tester, 'Cantidad', '0');
    await _pulsar(tester, 'Añadir');
    expect(find.text('Ingresa una cantidad mayor a cero'), findsOneWidget);
    await _escribir(tester, 'Cantidad', '2,5');
    await _escribir(tester, 'Costo unitario aplicado', '20,50');
    await _pulsar(tester, 'Añadir');
    await _escribir(tester, 'Total cotizado', '1000,00');
    await _pulsar(tester, 'Guardar cotización');
    expect(repositorio.proyectoGuardado!.nombreCliente, 'Cliente de prueba');
    expect(repositorio.proyectoGuardado!.totalCotizadoCentavos, 100000);
    expect(repositorio.partidasGuardadas.single.cantidad, 2.5);
    expect(repositorio.partidasGuardadas.single.subtotalCentavos, 5125);
    expect(find.byType(EditorProyectoPagina), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editar una partida conserva su precio histórico', (
    tester,
  ) async {
    final repositorio = _RepositorioCotizaciones();
    final originales = repositorio.datos;
    repositorio.datos = DatosLocales(
      proyectos: originales.proyectos,
      items: originales.items,
      gastos: originales.gastos,
      materiales: const [
        MaterialObra(
          id: 1,
          nombre: 'Porcelanato nuevo',
          unidadMedida: 'm²',
          costoBaseCentavos: 9999,
        ),
      ],
    );
    await _montarEditor(
      tester,
      repositorio,
      proyecto: originales.proyectos.single,
    );
    await tester.ensureVisible(find.byTooltip('Editar partida'));
    await tester.tap(find.byTooltip('Editar partida'));
    await tester.pumpAndSettle();
    final campoCosto = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Costo unitario aplicado'),
    );
    expect(campoCosto.controller!.text, '22.50');
    await _escribir(tester, 'Cantidad', '3');
    await _pulsar(tester, 'Aplicar');
    await _pulsar(tester, 'Guardar cotización');
    expect(repositorio.proyectoGuardado!.id, 1);
    expect(repositorio.partidasGuardadas.single.subtotalCentavos, 6750);
    expect(
      repositorio.partidasGuardadas.single.nombreMaterial,
      'Porcelanato gris 60 × 60',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('avisa antes de perder cambios del cliente', (tester) async {
    await _montarEditor(tester, _RepositorioCotizaciones());
    await _escribir(tester, 'Cliente / titular', 'Cambios sin guardar');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('¿Descartar cambios?'), findsOneWidget);
    await _pulsar(tester, 'Seguir editando');
    expect(find.byType(EditorProyectoPagina), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _pulsar(tester, 'Descartar');
    expect(find.byType(EditorProyectoPagina), findsNothing);
  });

  for (final ancho in [360.0, 800.0, 1280.0, 1440.0]) {
    testWidgets('editor y detalle se adaptan a $ancho px', (tester) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repositorio = _RepositorioCotizaciones();
      final cubit = await _montarEditor(
        tester,
        repositorio,
        proyecto: repositorio.datos.proyectos.single,
      );
      await _escribir(tester, 'Total cotizado', '999999999,99');
      await tester.ensureVisible(find.text('Guardar cotización'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Editor a $ancho px');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: appTheme,
            home: const DetalleProyectoPagina(proyectoId: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var paso = 0; paso < 4; paso++) {
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Detalle a $ancho px');
      }
    });
  }
}
