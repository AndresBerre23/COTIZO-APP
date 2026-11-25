import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'aplicacion/control_datos_app.dart';
import 'aplicacion/cotizo_cubit.dart';
import 'aplicacion/preferencias_cubit.dart';
import 'core/theme/app_theme.dart';
import 'datos/repositorio_sqlite.dart';
import 'dominio/repositorio_local.dart';
import 'dominio/modelos.dart';
import 'funcionalidades/arranque/componentes/cortina_arranque.dart';
import 'funcionalidades/arranque/pantalla_arranque.dart';
import 'screens/dashboard_screen.dart';
import 'funcionalidades/movimientos/movimientos_pagina.dart';
import 'screens/materials_screen.dart';
import 'screens/quote_screen.dart';
import 'screens/proforma_screen.dart';
import 'widgets/estado_vacio.dart';

// Repositorio abierto y preferencias leídas al iniciar.
typedef _DatosIniciales = (RepositorioLocal, PreferenciasApp);

class CotizoApp extends StatefulWidget {
  const CotizoApp({super.key, this.repositorio});
  final RepositorioLocal? repositorio;
  @override
  State<CotizoApp> createState() => _CotizoAppState();
}

class _CotizoAppState extends State<CotizoApp> {
  late Future<_DatosIniciales> _carga;
  late Future<RepositorioLocal> _apertura;
  bool _almacenamientoAbierto = false;
  bool _arranqueTerminado = false;
  String? _avisoPendiente;
  final _mensajero = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    _abrir();
  }

  void _abrir() {
    _almacenamientoAbierto = false;
    _apertura = widget.repositorio != null
        ? Future.value(widget.repositorio!)
        : RepositorioSqlite.abrir();
    _cargarPreferencias();
  }

  void _cargarPreferencias() {
    _carga = _apertura.then((repositorio) async {
      _almacenamientoAbierto = true;
      return (repositorio, await repositorio.obtenerPreferencias());
    });
  }

  Future<void> _reemplazarDatos(Future<void> Function() tarea) async {
    await (await _apertura).cerrar();
    try {
      await tarea();
      _avisoPendiente = 'Respaldo restaurado.';
    } catch (_) {
      // La copia previa queda en el almacenamiento interno de la app.
      _avisoPendiente = 'No se pudo restaurar el respaldo.';
    } finally {
      if (mounted) {
        setState(() {
          _arranqueTerminado = false;
          _abrir();
        });
      }
    }
  }

  void _mostrarAvisoPendiente() {
    final aviso = _avisoPendiente;
    if (aviso == null) return;
    _avisoPendiente = null;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          _mensajero.currentState?.showSnackBar(SnackBar(content: Text(aviso))),
    );
  }

  void _reintentar() =>
      setState(_almacenamientoAbierto ? _cargarPreferencias : _abrir);

  Widget _aplicacion(Widget inicio, {ThemeMode modoTema = ThemeMode.system}) =>
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Coti',
        theme: appTheme,
        darkTheme: darkAppTheme,
        themeMode: modoTema,
        scaffoldMessengerKey: _mensajero,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: inicio,
      );

  Widget _aplicacionConPreferencias(Widget inicio) =>
      BlocBuilder<PreferenciasCubit, PreferenciasApp>(
        builder: (context, preferencias) => _aplicacion(
          inicio,
          modoTema: switch (preferencias.modoTema) {
            ModoTema.sistema => ThemeMode.system,
            ModoTema.claro => ThemeMode.light,
            ModoTema.oscuro => ThemeMode.dark,
          },
        ),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder<_DatosIniciales>(
    future: _carga,
    builder: (context, resultado) {
      if (resultado.hasError) return _aplicacion(_pantallaError());
      if (!resultado.hasData || !_arranqueTerminado) {
        return _aplicacion(
          PantallaArranque(
            alTerminar: () {
              if (mounted) setState(() => _arranqueTerminado = true);
            },
          ),
        );
      }
      final (repositorio, preferencias) = resultado.data!;
      return _aplicacionConDatos(repositorio, preferencias);
    },
  );

  Widget _pantallaError() => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _almacenamientoAbierto
              ? EstadoVacio(
                  icono: Icons.settings_outlined,
                  titulo: 'No se pudieron cargar tus ajustes',
                  mensaje: 'Vuelve a intentar. Tus datos siguen guardados.',
                  accion: FilledButton(
                    onPressed: _reintentar,
                    child: const Text('Reintentar'),
                  ),
                )
              : EstadoVacio(
                  icono: Icons.storage_outlined,
                  titulo: 'No se pudo abrir el almacenamiento',
                  mensaje:
                      'Vuelve a intentar. No se eliminará ningún registro.',
                  accion: FilledButton(
                    onPressed: _reintentar,
                    child: const Text('Reintentar'),
                  ),
                ),
        ),
      ),
    ),
  );

  Widget _aplicacionConDatos(
    RepositorioLocal repositorio,
    PreferenciasApp preferencias,
  ) {
    _mostrarAvisoPendiente();
    return ControlDatosApp(
      prepararRespaldo: repositorio.prepararRespaldo,
      reemplazarDatos: _reemplazarDatos,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CotizoCubit(repositorio)..cargar()),
          BlocProvider(
            create: (_) =>
                PreferenciasCubit(repositorio, inicial: preferencias),
          ),
        ],
        child: BlocListener<CotizoCubit, EstadoCotizo>(
          listenWhen: (anterior, actual) =>
              actual.error != null && anterior.error != actual.error,
          listener: (_, estado) => _mensajero.currentState?.showSnackBar(
            SnackBar(content: Text(estado.error!)),
          ),
          child: _aplicacionConPreferencias(
            const CortinaArranque(child: AppShell()),
          ),
        ),
      ),
    );
  }
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
    'Movimientos',
    'Materiales',
    'Cotizaciones',
    'Documentos',
  ];
  static const _iconos = [
    Icons.dashboard_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.inventory_2_outlined,
    Icons.request_quote_outlined,
    Icons.folder_open_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final amplio = MediaQuery.sizeOf(context).width >= 840;
    final pantallas = [
      DashboardPage(
        cambiarSeccion: (indice) => setState(() => _indice = indice),
      ),
      const MovimientosPagina(),
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
