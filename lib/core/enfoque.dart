import 'package:flutter/widgets.dart';

void cerrarFocoAlTocarFuera(PointerDownEvent _) =>
    FocusManager.instance.primaryFocus?.unfocus();
