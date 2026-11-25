import 'package:cotizo_app/aplicacion/cotizo_cubit.dart';
import 'package:cotizo_app/aplicacion/preferencias_cubit.dart';
import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositorio_lectura.dart';

// Provee los cubits que las pantallas esperan, como lo hace CotizoApp.
class ConCubits extends StatelessWidget {
  const ConCubits({super.key, required this.cubit, required this.child});

  final CotizoCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: cubit),
      BlocProvider(
        create: (_) =>
            PreferenciasCubit(RepositorioLectura(const DatosLocales())),
      ),
    ],
    child: child,
  );
}
