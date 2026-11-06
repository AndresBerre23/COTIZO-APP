import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'aplicacion/cotizo_cubit.dart';
import 'core/theme/app_theme.dart';
import 'datos/repositorio_sqlite.dart';
import 'dominio/repositorio_local.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/materials_screen.dart';
import 'screens/quote_screen.dart';
import 'screens/proforma_screen.dart';
import 'widgets/estado_vacio.dart';

class CotizoApp extends StatefulWidget {
  const CotizoApp({super.key, this.repositorio});
  final RepositorioLocal? repositorio;
  @override
  State<CotizoApp> createState() => _CotizoAppState();
}

class _CotizoAppState extends State<CotizoApp> {
  late Future<RepositorioLocal> _apertura;
  final _mensajero = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    _abrir();
  }

  void _abrir() {
    _apertura = widget.repositorio != null
        ? Future.value(widget.repositorio!)
        : RepositorioSqlite.abrir();
  }

  Widget _aplicacion(Widget inicio) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ObraPro',
    theme: appTheme,
    scaffoldMessengerKey: _mensajero,
    locale: const Locale('es'),
    supportedLocales: const [Locale('es')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: inicio,
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<RepositorioLocal>(
    future: _apertura,
    builder: (context, resultado) {
      if (!resultado.hasData) {
        return _aplicacion(
          Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: resultado.hasError
                      ? EstadoVacio(
                          icono: Icons.storage_outlined,
                          titulo: 'No se pudo abrir el almacenamiento',
                          mensaje:
                              'Vuelve a intentar. No se eliminará ningún registro.',
                          accion: FilledButton(
                            onPressed: () => setState(_abrir),
                            child: const Text('Reintentar'),
                          ),
                        )
                      : const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'OBRAPRO',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 20),
                            LinearProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Abriendo tus datos locales'),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      }
      return BlocProvider(
        create: (_) => CotizoCubit(resultado.data!)..cargar(),
        child: BlocListener<CotizoCubit, EstadoCotizo>(
          listenWhen: (anterior, actual) =>
              actual.error != null && anterior.error != actual.error,
          listener: (_, estado) => _mensajero.currentState?.showSnackBar(
            SnackBar(content: Text(estado.error!)),
          ),
          child: _aplicacion(const AppShell()),
        ),
      );
    },
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indice = 0;
  static const _etiquetas = [
    'Inicio',
    'Gastos',
    'Materiales',
    'Cotizaciones',
    'Proforma',
  ];
  static const _iconos = [
    Icons.dashboard_outlined,
    Icons.receipt_long_outlined,
    Icons.inventory_2_outlined,
    Icons.request_quote_outlined,
    Icons.picture_as_pdf_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final amplio = MediaQuery.sizeOf(context).width >= 840;
    final pantallas = [
      DashboardPage(
        cambiarSeccion: (indice) => setState(() => _indice = indice),
      ),
      const ExpensePage(),
      const MaterialsPage(),
      const QuotePage(),
      const ProformaPage(),
    ];
    return Scaffold(
      body: BlocBuilder<CotizoCubit, EstadoCotizo>(
        builder: (context, estado) {
          if (estado.cargando) {
            return const Center(
              child: SizedBox(width: 240, child: LinearProgressIndicator()),
            );
          }
          if (estado.falloCarga) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EstadoVacio(
                  icono: Icons.storage_outlined,
                  titulo: 'No se pudieron cargar tus datos',
                  mensaje: estado.error!,
                  accion: FilledButton(
                    onPressed: context.read<CotizoCubit>().cargar,
                    child: const Text('Reintentar'),
                  ),
                ),
              ),
            );
          }
          return Row(
            children: [
              if (amplio)
                NavigationRail(
                  selectedIndex: _indice,
                  onDestinationSelected: (indice) =>
                      setState(() => _indice = indice),
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(
                    5,
                    (indice) => NavigationRailDestination(
                      icon: Icon(_iconos[indice]),
                      label: Text(_etiquetas[indice]),
                    ),
                  ),
                ),
              Expanded(
                child: IndexedStack(index: _indice, children: pantallas),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: amplio
          ? null
          : NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: (indice) =>
                  setState(() => _indice = indice),
              destinations: List.generate(
                5,
                (indice) => NavigationDestination(
                  icon: Icon(_iconos[indice]),
                  label: _etiquetas[indice],
                ),
              ),
            ),
    );
  }
}
