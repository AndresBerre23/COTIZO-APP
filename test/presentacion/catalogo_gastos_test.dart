import 'package:cotizo_app/aplicacion/cotizo_cubit.dart';
import 'package:cotizo_app/aplicacion/edicion_material.dart';
import 'package:cotizo_app/core/formato.dart';
import 'package:cotizo_app/core/theme/app_theme.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:cotizo_app/funcionalidades/gastos/formulario_gasto.dart';
import 'package:cotizo_app/funcionalidades/materiales/formulario_material.dart';
import 'package:cotizo_app/screens/expense_screen.dart';
import 'package:cotizo_app/screens/materials_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/con_cubits.dart';
import '../apoyo/repositorio_lectura.dart';

class _RepositorioCatalogo extends RepositorioLectura {
  _RepositorioCatalogo() : super(const DatosLocales());

  @override
  Future<int> guardarMaterial(MaterialObra material) async {
    final id = material.id == 0 ? datos.materiales.length + 1 : material.id;
    datos = DatosLocales(
      materiales: [
        ...datos.materiales.where((existente) => existente.id != id),
        MaterialObra(
          id: id,
          nombre: material.nombre,
          unidadMedida: material.unidadMedida,
          costoBaseCentavos: material.costoBaseCentavos,
        ),
      ],
      gastos: datos.gastos,
    );
    return id;
  }

  @override
  Future<void> eliminarMaterial(int id) async {
    datos = DatosLocales(
      materiales: datos.materiales
          .where((material) => material.id != id)
          .toList(),
      gastos: datos.gastos,
    );
  }

  @override
  Future<int> guardarGasto(Gasto gasto) async {
    final id = gasto.id == 0 ? datos.gastos.length + 1 : gasto.id;
    datos = DatosLocales(
      materiales: datos.materiales,
      gastos: [
        ...datos.gastos.where((existente) => existente.id != id),
        Gasto(
          id: id,
          proyectoId: gasto.proyectoId,
          montoCentavos: gasto.montoCentavos,
          categoria: gasto.categoria,
          fecha: gasto.fecha,
          nota: gasto.nota,
        ),
      ],
    );
    return id;
  }

  @override
  Future<void> eliminarGasto(int id) async {
    datos = DatosLocales(
      materiales: datos.materiales,
      gastos: datos.gastos.where((gasto) => gasto.id != id).toList(),
    );
  }
}

Widget _aplicacion(Widget pagina) => MaterialApp(
  theme: appTheme,
  locale: const Locale('es'),
  supportedLocales: const [Locale('es')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: Scaffold(body: pagina),
);

Future<void> _pulsar(WidgetTester tester, Finder elemento) async {
  // Deja terminar el desplazamiento automático hacia el campo enfocado.
  await tester.pumpAndSettle();
  await tester.ensureVisible(elemento);
  await tester.pumpAndSettle();
  await tester.tap(elemento);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'materiales: validación, creación, edición, búsqueda y eliminación',
    (tester) async {
      final repositorio = _RepositorioCatalogo();
      final cubit = CotizoCubit(repositorio);
      await cubit.cargar();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        ConCubits(cubit: cubit, child: _aplicacion(const MaterialsPage())),
      );
      await _pulsar(tester, find.text('Añadir material'));
      await _pulsar(tester, find.text('Guardar material'));
      expect(find.text('Completa este campo.'), findsOneWidget);
      expect(repositorio.datos.materiales, isEmpty);
      await tester.enterText(find.byType(TextFormField).at(0), 'Cemento');
      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();
      final campoUnidad = find.descendant(
        of: find.byType(DropdownMenu<String>),
        matching: find.byType(TextField),
      );
      await tester.enterText(campoUnidad, 'm2');
      await tester.pumpAndSettle();
      expect(find.text('m²'), findsOneWidget);
      await tester.tap(find.text('m²').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), '12,50');
      await _pulsar(tester, find.text('Guardar material'));
      expect(repositorio.datos.materiales.single.costoBaseCentavos, 1250);
      expect(repositorio.datos.materiales.single.unidadMedida, 'm²');
      expect(find.text('Cemento'), findsOneWidget);
      await _pulsar(tester, find.byTooltip('Opciones del material'));
      await _pulsar(tester, find.text('Editar'));
      await tester.enterText(find.byType(TextFormField).at(1), '14.20');
      await _pulsar(tester, find.text('Guardar material'));
      expect(repositorio.datos.materiales.single.costoBaseCentavos, 1420);
      await tester.enterText(find.byType(TextField), 'pintura');
      await tester.pumpAndSettle();
      expect(find.text('Sin coincidencias'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await _pulsar(tester, find.byTooltip('Opciones del material'));
      await _pulsar(tester, find.text('Eliminar'));
      await _pulsar(tester, find.text('Cancelar'));
      expect(repositorio.datos.materiales, hasLength(1));
      await _pulsar(tester, find.byTooltip('Opciones del material'));
      await _pulsar(tester, find.text('Eliminar'));
      await _pulsar(tester, find.widgetWithText(FilledButton, 'Eliminar'));
      expect(repositorio.datos.materiales, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('gastos: rechaza cero, guarda general, edita y elimina', (
    tester,
  ) async {
    final repositorio = _RepositorioCatalogo();
    final cubit = CotizoCubit(repositorio);
    await cubit.cargar();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      ConCubits(cubit: cubit, child: _aplicacion(const ExpensePage())),
    );
    final inicioRegistro = DateTime.now();
    await _pulsar(tester, find.text('Registrar el primer gasto'));
    await tester.enterText(find.byType(TextFormField).first, '0');
    await _pulsar(tester, find.text('Guardar gasto'));
    expect(
      find.text('Ingresa un monto mayor a cero, con hasta 2 decimales.'),
      findsOneWidget,
    );
    expect(repositorio.datos.gastos, isEmpty);
    await tester.enterText(find.byType(TextFormField).first, '3,25');
    await tester.enterText(find.byType(TextFormField).last, 'Taxi');
    await _pulsar(tester, find.text('Guardar gasto'));
    expect(repositorio.datos.gastos.single.proyectoId, isNull);
    expect(repositorio.datos.gastos.single.montoCentavos, 325);
    expect(
      find.text(fechaHoraCorta(repositorio.datos.gastos.single.fecha)),
      findsOneWidget,
    );
    expect(
      repositorio.datos.gastos.single.fecha.isAfter(
        inicioRegistro.subtract(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    expect(
      repositorio.datos.gastos.single.fecha.isBefore(DateTime.now()),
      isTrue,
    );
    await _pulsar(tester, find.byTooltip('Opciones del gasto'));
    await _pulsar(tester, find.text('Editar'));
    await tester.enterText(find.byType(TextFormField).first, '4.50');
    await _pulsar(tester, find.text('Guardar gasto'));
    expect(repositorio.datos.gastos.single.montoCentavos, 450);
    await _pulsar(tester, find.byTooltip('Opciones del gasto'));
    await _pulsar(tester, find.text('Eliminar'));
    await _pulsar(tester, find.widgetWithText(FilledButton, 'Eliminar'));
    expect(repositorio.datos.gastos, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gasto desde proyecto conserva la asociación seleccionada', (
    tester,
  ) async {
    Gasto? resultado;
    await tester.pumpWidget(
      _aplicacion(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => resultado = await mostrarFormularioGasto(
              context,
              proyectos: datosMuestra().proyectos,
              proyectoId: 1,
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await _pulsar(tester, find.text('Abrir'));
    await tester.enterText(find.byType(TextFormField).first, '25');
    await _pulsar(tester, find.text('Guardar gasto'));
    expect(resultado?.proyectoId, 1);
    expect(resultado?.montoCentavos, 2500);
  });

  testWidgets('material permite conservar una unidad personalizada', (
    tester,
  ) async {
    EdicionMaterial? guardado;
    await tester.pumpWidget(
      _aplicacion(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                guardado = await mostrarFormularioMaterial(context),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await _pulsar(tester, find.text('Abrir'));
    await tester.enterText(find.byType(TextFormField).first, 'Pintura');
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Otra unidad').last);
    await tester.pumpAndSettle();
    final campoUnidad = find.descendant(
      of: find.byType(DropdownMenu<String>),
      matching: find.byType(TextField),
    );
    await tester.enterText(campoUnidad, 'balde especial');
    await tester.enterText(find.byType(TextFormField).last, '8,50');
    await _pulsar(tester, find.text('Guardar material'));

    expect(guardado?.material.unidadMedida, 'balde especial');
    expect(tester.takeException(), isNull);
  });

  for (final ancho in [360.0, 800.0, 1280.0, 1440.0]) {
    testWidgets('formularios a $ancho px con teclado y texto ampliado', (
      tester,
    ) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        _aplicacion(
          Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => mostrarFormularioMaterial(context),
                  child: const Text('Material'),
                ),
                TextButton(
                  onPressed: () => mostrarFormularioGasto(
                    context,
                    proyectos: datosMuestra().proyectos,
                  ),
                  child: const Text('Gasto'),
                ),
              ],
            ),
          ),
        ),
      );
      await _pulsar(tester, find.text('Material'));
      await tester.ensureVisible(find.text('Guardar material'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _pulsar(tester, find.text('Cancelar'));
      await _pulsar(tester, find.text('Gasto'));
      await tester.ensureVisible(find.text('Guardar gasto'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _pulsar(tester, find.text('Cancelar'));
    });
  }
}
