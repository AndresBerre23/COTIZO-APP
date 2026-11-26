import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../widgets/estado_vacio.dart';
import '../cotizaciones/cotizaciones_pagina.dart';
import '../inicio/inicio_pagina.dart';
import '../materiales/materiales_pagina.dart';
import '../movimientos/movimientos_pagina.dart';
import '../proformas/archivo_documentos_page.dart';

// Pestañas principales: barra inferior en móvil y riel lateral en pantallas anchas.
class NavegacionPrincipal extends StatefulWidget {
  const NavegacionPrincipal({super.key});
  @override
  State<NavegacionPrincipal> createState() => _NavegacionPrincipalState();
}

class _NavegacionPrincipalState extends State<NavegacionPrincipal> {
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
      InicioPagina(
        cambiarSeccion: (indice) => setState(() => _indice = indice),
      ),
      const MovimientosPagina(),
      const MaterialesPagina(),
      const CotizacionesPagina(),
      const ArchivoDocumentosPage(),
    ];
    return Scaffold(
      body: BlocBuilder<CotiCubit, EstadoCoti>(
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
                    onPressed: context.read<CotiCubit>().cargar,
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
