import 'package:coti/aplicacion/coti_cubit.dart';
import 'package:coti/app.dart';
import 'package:coti/core/theme/app_theme.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:coti/funcionalidades/cotizaciones/detalle_proyecto_pagina.dart';
import 'package:coti/funcionalidades/cotizaciones/editor_proyecto_pagina.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/con_cubits.dart';
import '../apoyo/repositorio_lectura.dart';

class _RepositorioCotizaciones extends RepositorioLectura {
  _RepositorioCotizaciones() : super(datosMuestra());
  Proyecto? proyectoGuardado;
  Cliente? clienteGuardado;
  List<ItemProyecto> partidasGuardadas = [];

  @override
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto>? gastosPrevistos,
    Cliente? cliente,
  }) async {
    proyectoGuardado = proyecto;
    clienteGuardado = cliente;
    partidasGuardadas = List.of(items);
    escrituras++;
    return proyecto.id == 0 ? 2 : proyecto.id;
  }

  @override
  Future<void> iniciarObra(int proyectoId, DateTime fechaInicioReal) async {
    _actualizarProyecto(
      (proyecto) => Proyecto(
        id: proyecto.id,
        nombreCliente: proyecto.nombreCliente,
        descripcion: proyecto.descripcion,
        fechaInicio: proyecto.fechaInicio,
        fechaFin: proyecto.fechaFin,
        fechaInicioReal: fechaInicioReal,
        estado: EstadoProyecto.aprobado,
        totalCotizadoCentavos: proyecto.totalCotizadoCentavos,
      ),
    );
  }

  @override
  Future<void> finalizarObra(int proyectoId, DateTime fechaFinReal) async {
    _actualizarProyecto(
      (proyecto) => Proyecto(
        id: proyecto.id,
        nombreCliente: proyecto.nombreCliente,
        descripcion: proyecto.descripcion,
        fechaInicio: proyecto.fechaInicio,
        fechaFin: proyecto.fechaFin,
        fechaInicioReal: proyecto.fechaInicioReal,
        fechaFinReal: fechaFinReal,
        estado: EstadoProyecto.finalizado,
        totalCotizadoCentavos: proyecto.totalCotizadoCentavos,
      ),
    );
  }

  void _actualizarProyecto(Proyecto Function(Proyecto) actualizar) {
    datos = DatosLocales(
      proyectos: datos.proyectos.map(actualizar).toList(),
      materiales: datos.materiales,
      items: datos.items,
      gastos: datos.gastos,
    );
  }
}

Future<CotiCubit> _montarEditor(
  WidgetTester tester,
  _RepositorioCotizaciones repositorio, {
  Proyecto? proyecto,
}) async {
  final cubit = CotiCubit(repositorio);
  await cubit.cargar();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    ConCubits(
      cubit: cubit,
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
  await tester.pumpAndSettle();
  await tester.enterText(campo, texto);
  await tester.pumpAndSettle();
}

Future<void> _pulsar(WidgetTester tester, String texto) async {
  final control = find.text(texto);
  await tester.ensureVisible(control);
  await tester.pumpAndSettle();
  await tester.tap(control);
  await tester.pumpAndSettle();
}

// Pulsa "Continuar" u "Omitir por ahora" en la barra inferior del asistente.
Future<void> _avanzar(WidgetTester tester, [int pasos = 1]) async {
  for (var i = 0; i < pasos; i++) {
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
  }
}

// Guarda desde el último paso y acepta el resumen final.
Future<void> _guardarYConfirmar(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.save_outlined).first);
  await tester.pumpAndSettle();
  final confirmar = find.descendant(
    of: find.byType(Dialog),
    matching: find.text('Guardar cotización'),
  );
  await tester.ensureVisible(confirmar);
  await tester.pumpAndSettle();
  await tester.tap(confirmar);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('valida y guarda una cotización con cantidades decimales', (
    tester,
  ) async {
    final repositorio = _RepositorioCotizaciones();
    await _montarEditor(tester, repositorio);
    await _avanzar(tester);
    expect(repositorio.proyectoGuardado, isNull);
    expect(find.text('Completa este campo.'), findsNWidgets(2));
    await _escribir(tester, 'Cliente / titular', 'Cliente de prueba');
    await _escribir(
      tester,
      'Descripción del proyecto',
      'Revestimiento de baño',
    );
    await _avanzar(tester);
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
    await _avanzar(tester, 2);
    await _escribir(tester, 'Total que cobrarás al cliente', '1000,00');
    await _guardarYConfirmar(tester);
    expect(repositorio.proyectoGuardado!.nombreCliente, 'Cliente de prueba');
    expect(repositorio.proyectoGuardado!.totalCotizadoCentavos, 100000);
    expect(repositorio.partidasGuardadas.single.cantidad, 2.5);
    expect(repositorio.partidasGuardadas.single.subtotalCentavos, 5125);
    expect(find.byType(EditorProyectoPagina), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cotiza un servicio con IVA, condiciones y datos del cliente', (
    tester,
  ) async {
    final repositorio = _RepositorioCotizaciones();
    await _montarEditor(tester, repositorio);
    await _escribir(tester, 'Cliente / titular', 'Ana Ruiz');
    await _escribir(tester, 'Descripción del proyecto', 'Diseño de cocina');
    await _pulsar(tester, 'Datos de contacto (opcional)');
    await _escribir(tester, 'Teléfono', '0999999999');
    await _avanzar(tester);
    await _pulsar(tester, 'Añadir servicio');
    await _escribir(tester, 'Descripción del servicio', 'Diseño 3D');
    await _escribir(tester, 'Precio unitario al cliente', '200');
    await _pulsar(tester, 'Añadir');
    expect(find.text('Servicio · precio al cliente'), findsOneWidget);
    await _avanzar(tester, 2);
    await _escribir(tester, 'Total que cobrarás al cliente', '200');
    await _escribir(tester, 'Forma de pago', 'Contado');
    expect(find.text('\$ 230,00'), findsOneWidget);
    await _guardarYConfirmar(tester);

    final guardado = repositorio.proyectoGuardado!;
    expect(guardado.ivaPuntos, 1500);
    expect(guardado.validezDias, 15);
    expect(guardado.formaPago, 'Contado');
    expect(guardado.margenDeseadoPuntos, 2000);
    expect(repositorio.partidasGuardadas.single.esServicio, isTrue);
    expect(repositorio.clienteGuardado!.nombre, 'Ana Ruiz');
    expect(repositorio.clienteGuardado!.telefono, '0999999999');
    expect(tester.takeException(), isNull);
  });

  testWidgets('agrega un gasto previsto sin usar controladores liberados', (
    tester,
  ) async {
    final repositorio = _RepositorioCotizaciones();
    await _montarEditor(
      tester,
      repositorio,
      proyecto: repositorio.datos.proyectos.single,
    );
    await _avanzar(tester, 2);

    await _pulsar(tester, 'Añadir gasto previsto');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transporte de materiales').last);
    await tester.pumpAndSettle();
    await _escribir(tester, 'Importe previsto', '45,50');
    await tester.enterText(
      find.widgetWithText(TextField, 'Descripción (opcional)'),
      'Traslado de material',
    );
    await _pulsar(tester, 'Guardar');

    expect(find.text('Transporte de materiales'), findsOneWidget);
    expect(find.text('Traslado de material'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('usa el margen fijo del 20 % y conserva el total editable', (
    tester,
  ) async {
    final repositorio = _RepositorioCotizaciones();
    await _montarEditor(
      tester,
      repositorio,
      proyecto: repositorio.datos.proyectos.single,
    );
    await _avanzar(tester, 3);

    expect(find.textContaining('Aplica un margen del 20 %'), findsOneWidget);
    await _pulsar(tester, 'Usar este precio');
    await _escribir(tester, 'Total que cobrarás al cliente', '999');
    await _guardarYConfirmar(tester);

    expect(repositorio.proyectoGuardado!.totalCotizadoCentavos, 99900);
    expect(repositorio.proyectoGuardado!.margenDeseadoPuntos, 2000);
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
    await _avanzar(tester);
    await tester.ensureVisible(find.byTooltip('Editar partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Editar partida'));
    await tester.pumpAndSettle();
    final campoCosto = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Costo unitario aplicado'),
    );
    expect(campoCosto.controller!.text, '22.50');
    await _escribir(tester, 'Cantidad', '3');
    await _pulsar(tester, 'Aplicar');
    await _avanzar(tester, 2);
    await _guardarYConfirmar(tester);
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

  testWidgets('inicia y finaliza una obra desde su detalle', (tester) async {
    final repositorio = _RepositorioCotizaciones();
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

    expect(find.text('Editar'), findsOneWidget);
    await _pulsar(tester, 'Iniciar obra');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Iniciar obra'),
      ),
    );
    await tester.pumpAndSettle();
    expect(repositorio.datos.proyectos.single.fechaInicioReal, isNotNull);
    expect(cubit.state.datos.proyectos.single.fechaInicioReal, isNotNull);
    expect(cubit.state.datos.proyectos.single.estaEnCurso, isTrue);
    await tester.fling(find.byType(ListView), const Offset(0, 1000), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Finalizar obra'), findsOneWidget);

    await _pulsar(tester, 'Finalizar obra');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Finalizar obra'),
      ),
    );
    await tester.pumpAndSettle();
    expect(cubit.state.datos.proyectos.single.estaFinalizada, isTrue);
    await tester.fling(find.byType(ListView), const Offset(0, 1000), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Ver proforma'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aviso de retraso abre el detalle y permite continuar la obra', (
    tester,
  ) async {
    final hoy = DateTime.now();
    final base = datosMuestra();
    final obra = Proyecto(
      id: 1,
      nombreCliente: 'María Gómez',
      descripcion: 'Remodelación de cocina',
      fechaInicio: hoy.subtract(const Duration(days: 10)),
      fechaFin: hoy.subtract(const Duration(days: 2)),
      fechaInicioReal: hoy.subtract(const Duration(days: 9)),
      estado: EstadoProyecto.aprobado,
      totalCotizadoCentavos: 180000,
    );
    final repositorio = RepositorioLectura(
      DatosLocales(
        proyectos: [obra],
        materiales: base.materiales,
        items: base.items,
        gastos: base.gastos,
      ),
    );
    await tester.pumpWidget(CotiApp(repositorio: repositorio));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('Obra en retraso'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.textContaining('Obra en retraso'));
    await tester.pumpAndSettle();
    expect(find.text('La fecha prevista terminó'), findsOneWidget);
    await tester.tap(find.text('Aún no termino'));
    await tester.pumpAndSettle();
    expect(find.byType(DetalleProyectoPagina), findsOneWidget);
    expect(repositorio.datos.proyectos.single.estaEnCurso, isTrue);
  });

  testWidgets('separa cotizaciones pendientes de obras iniciadas', (
    tester,
  ) async {
    final base = datosMuestra();
    final pendiente = base.proyectos.single;
    final obra = Proyecto(
      id: 2,
      nombreCliente: 'Cliente obra',
      descripcion: 'Obra visible',
      fechaInicio: DateTime(2026, 11, 1),
      fechaFin: DateTime(2026, 11, 20),
      fechaInicioReal: DateTime(2026, 11, 2),
      estado: EstadoProyecto.aprobado,
      totalCotizadoCentavos: 10000,
    );
    await tester.pumpWidget(
      CotiApp(
        repositorio: RepositorioLectura(
          DatosLocales(
            proyectos: [pendiente, obra],
            materiales: base.materiales,
            items: base.items,
            gastos: base.gastos,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Cotizaciones'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Remodelación de cocina'), findsOneWidget);
    expect(find.text('Obra visible'), findsNothing);
    await tester.tap(find.text('Obras (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Remodelación de cocina'), findsNothing);
    expect(find.text('Obra visible'), findsOneWidget);
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
      await _avanzar(tester, 3);
      await _escribir(tester, 'Total que cobrarás al cliente', '999999999,99');
      await tester.ensureVisible(find.text('Guardar cotización'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Editor a $ancho px');
      await tester.pumpWidget(const SizedBox());
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
      for (var paso = 0; paso < 4; paso++) {
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Detalle a $ancho px');
      }
    });
  }
}
