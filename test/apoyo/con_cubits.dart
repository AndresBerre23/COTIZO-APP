import 'package:coti/aplicacion/coti_cubit.dart';
import 'package:coti/aplicacion/preferencias_cubit.dart';
import 'package:coti/dominio/modelos.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositorio_lectura.dart';

// Provee los cubits que las pantallas esperan, como lo hace CotiApp.
class ConCubits extends StatelessWidget {
  const ConCubits({super.key, required this.cubit, required this.child});

  final CotiCubit cubit;
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
