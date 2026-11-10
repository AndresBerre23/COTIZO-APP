import 'dart:io';
import 'dart:ui' as ui;
import 'package:cotizo_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../apoyo/repositorio_lectura.dart';

void main() {
  final capturar = Platform.environment['CAPTURAR_UI'] == '1';
  setUpAll(() async {
    final fuente = File('C:/Windows/Fonts/segoeui.ttf');
    if (capturar && fuente.existsSync()) {
      final cargador = FontLoader('Inter')
        ..addFont(Future.value(ByteData.sublistView(fuente.readAsBytesSync())));
      await cargador.load();
      final monoespaciada = FontLoader('monospace')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('C:/Windows/Fonts/consola.ttf').readAsBytesSync(),
            ),
          ),
        );
      await monoespaciada.load();
      final iconos = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await iconos.load();
    }
  });
  for (final ancho in [360.0, 800.0, 1280.0, 1440.0]) {
    testWidgets('navegación y pantallas sin desbordamientos a $ancho px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final captura = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: captura,
          child: CotizoApp(repositorio: RepositorioLectura(datosMuestra())),
        ),
      );
      await tester.pumpAndSettle();
      final etiquetas = [
        'Inicio',
        'Gastos',
        'Materiales',
        'Cotizaciones',
        'Documentos',
      ];
      for (var indice = 0; indice < etiquetas.length; indice++) {
        final destino = ancho >= 840
            ? find.descendant(
                of: find.byType(NavigationRail),
                matching: find.text(etiquetas[indice]),
              )
            : find.descendant(
                of: find.byType(NavigationBar),
                matching: find.text(etiquetas[indice]),
              );
        await tester.tap(destino);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${etiquetas[indice]} a $ancho px',
        );
        if (capturar && (ancho == 360 || ancho == 1440)) {
          await tester.runAsync(() async {
            final limite =
                captura.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final imagen = await limite.toImage(pixelRatio: 1);
            final datos = await imagen.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final archivo = File(
              'build/verificacion/${etiquetas[indice].toLowerCase()}-${ancho.toInt()}.png',
            );
            archivo.parent.createSync(recursive: true);
            archivo.writeAsBytesSync(datos!.buffer.asUint8List());
            imagen.dispose();
          });
        }
      }
      await tester.tap(find.byTooltip('Mi perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Mi perfil'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Apellido'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Mi perfil a $ancho px');
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('navegación móvil con texto ampliado', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      CotizoApp(repositorio: RepositorioLectura(datosMuestra())),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
