import 'package:coti/app.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:coti/funcionalidades/bienvenida/pantalla_bienvenida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/autenticacion_falsa.dart';
import '../apoyo/repositorio_lectura.dart';

RepositorioLectura _repositorioNuevo() =>
    RepositorioLectura(datosMuestra())..preferencias = const PreferenciasApp();

void main() {
  testWidgets('la primera vez muestra el tutorial y luego no', (tester) async {
    final repositorio = _repositorioNuevo();
    await tester.pumpWidget(
      CotiApp(repositorio: repositorio, autenticacion: AutenticacionFalsa()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cotiza en minutos'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Tus datos son tuyos'), findsOneWidget);
    expect(find.text('Configurar mi negocio'), findsOneWidget);
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaBienvenida), findsNothing);
    expect(find.text('Inicio'), findsWidgets);
    expect(repositorio.preferencias.tutorialVisto, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saltar el tutorial también lo marca como visto', (tester) async {
    final repositorio = _repositorioNuevo();
    await tester.pumpWidget(
      CotiApp(repositorio: repositorio, autenticacion: AutenticacionFalsa()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
    expect(repositorio.preferencias.tutorialVisto, isTrue);
    expect(find.byType(PantallaBienvenida), findsNothing);
  });

  testWidgets('tras el tutorial ofrece el bloqueo y lo activa', (tester) async {
    final repositorio = _repositorioNuevo();
    final autenticacion = AutenticacionFalsa(hayBloqueo: true);
    await tester.pumpWidget(
      CotiApp(repositorio: repositorio, autenticacion: autenticacion),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
    expect(find.text('Protege tu información'), findsOneWidget);
    await tester.tap(find.text('Activar bloqueo'));
    await tester.pumpAndSettle();
    expect(repositorio.preferencias.bloqueoActivo, isTrue);
    expect(repositorio.preferencias.tutorialVisto, isTrue);
    // Recién activado no bloquea la sesión actual.
    expect(find.text('Coti está protegida'), findsNothing);
  });

  testWidgets('con bloqueo activo pide huella al abrir', (tester) async {
    final repositorio = RepositorioLectura(datosMuestra())
      ..preferencias = const PreferenciasApp(
        tutorialVisto: true,
        bloqueoActivo: true,
      );
    final autenticacion = AutenticacionFalsa(hayBloqueo: true, aceptar: false);
    await tester.pumpWidget(
      CotiApp(repositorio: repositorio, autenticacion: autenticacion),
    );
    await tester.pumpAndSettle();
    expect(find.text('Coti está protegida'), findsOneWidget);
    expect(autenticacion.intentos, 1);
    expect(find.text('Inicio'), findsNothing);
  });

  testWidgets('el botón de información explica la pestaña', (tester) async {
    await tester.pumpWidget(
      CotiApp(repositorio: RepositorioLectura(datosMuestra())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Información: Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Cómo se usa'), findsOneWidget);
    expect(find.textContaining('Ejemplo:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final tam in const [
    Size(360, 760),
    Size(800, 1100),
    Size(1440, 900),
    Size(760, 360),
  ]) {
    testWidgets('el tutorial se adapta a ${tam.width}x${tam.height}', (
      tester,
    ) async {
      tester.view.physicalSize = tam;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(home: PantallaBienvenida(alTerminar: (_) {})),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
