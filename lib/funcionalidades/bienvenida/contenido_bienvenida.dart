import 'componentes/pintor_escena.dart';

// Textos del tutorial de bienvenida, en el orden en que se muestran.
const pasosBienvenida =
    <({EscenaBienvenida escena, String titulo, String texto})>[
      (
        escena: EscenaBienvenida.cotizar,
        titulo: 'Cotiza en minutos',
        texto:
            'Guarda tus materiales con su precio, arma la cotización por pasos '
            'y Coti te sugiere cuánto cobrar. Comparte la proforma en PDF.',
      ),
      (
        escena: EscenaBienvenida.obra,
        titulo: 'Controla la obra',
        texto:
            'Registra gastos, el material que de verdad usaste y los trabajos '
            'extra que te pida el cliente, sin tocar la proforma enviada.',
      ),
      (
        escena: EscenaBienvenida.ganancias,
        titulo: 'Sabe cuánto ganas',
        texto:
            'Anota anticipos y abonos, mira el saldo pendiente, el balance real '
            'del mes y reportes por categoría.',
      ),
      (
        escena: EscenaBienvenida.datos,
        titulo: 'Tus datos son tuyos',
        texto:
            'Todo queda en tu teléfono y funciona sin internet. Crea respaldos '
            'cuando quieras desde Mi perfil.',
      ),
    ];
