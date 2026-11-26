// Textos del botón de información. Para cambiar una ayuda, editar solo aquí.
enum TemaAyuda {
  inicio(
    'Inicio',
    'Resume cómo va tu negocio: el dinero real del mes y lo que esperas ganar con tus obras.',
    [
      'El balance real compara lo que cobraste con lo que gastaste este mes.',
      'El balance estimado suma tus cotizaciones aprobadas y obras, menos sus costos.',
      'Toca una obra para ver su detalle.',
    ],
    'Si cobraste \$500 y gastaste \$120 este mes, tu balance real es \$380.',
  ),
  movimientos(
    'Movimientos',
    'Aquí registras todo el dinero que entra y sale, ligado a un proyecto o como general.',
    [
      'Cambia entre Gastos e Ingresos con el selector.',
      'Usa la búsqueda y los filtros para encontrar un registro.',
      'Abre el reporte mensual para ver totales por categoría y compartirlos en PDF.',
    ],
    'Un anticipo de \$200 de la obra de María es un ingreso ligado a ese proyecto.',
  ),
  materiales(
    'Materiales',
    'Tu catálogo de materiales con su unidad y precio de referencia, para reutilizarlos al cotizar.',
    [
      'Agrega cada material una vez, con foto si quieres.',
      'Al cotizar, el precio se copia: puedes ajustarlo en cada cotización.',
      'Cambiar el catálogo no altera cotizaciones ya guardadas.',
    ],
    'Cable #12 a \$0,85 por metro.',
  ),
  cotizaciones(
    'Cotizaciones',
    'Tus proyectos desde el presupuesto hasta la entrega.',
    [
      'Crea una cotización en 4 pasos: cliente, materiales, gastos previstos y precio.',
      'Cámbiale el estado según lo que diga el cliente.',
      'Al iniciar la obra, pasa a la pestaña Obras y puedes registrar gastos y consumos.',
    ],
    'Una cotización aprobada se convierte en obra cuando registras su inicio.',
  ),
  documentos(
    'Documentos',
    'Todas tus proformas y reportes de cierre en PDF, listos para compartir o imprimir.',
    [
      'Busca por cliente, proyecto o código COT.',
      'La proforma muestra al cliente solo precios finales, sin tus costos.',
      'El reporte de cierre resume cómo terminó una obra.',
    ],
    'Busca "COT-0012" para encontrar esa proforma.',
  ),
  partidas(
    'Materiales y servicios',
    'Lo que necesita el trabajo. Los materiales son costos; los servicios son trabajos con precio propio.',
    [
      'Añade materiales del catálogo con su cantidad.',
      'Añade servicios para cobrar trabajos como diseño o instalación.',
      'El margen se aplica a los materiales, no a los servicios.',
    ],
    'Instalación eléctrica: 1 servicio a \$150.',
  ),
  precio(
    'Precio de tu trabajo',
    'Coti calcula un precio sugerido con tu margen; tú decides el total final.',
    [
      'El margen sugerido se cambia en Mi perfil.',
      'Si cobras tu mano de obra, actívala y escribe cuánto.',
      'El total que escribas es sin IVA.',
    ],
    'Con \$400 en materiales y un margen del 20 %, el precio sugerido es \$500.',
  ),
  condiciones(
    'Condiciones de la proforma',
    'El IVA, la validez y los acuerdos de pago que verá el cliente.',
    [
      'Elige IVA 15 %, 0 % o no cobrar IVA si estás en RIMPE.',
      'La validez indica hasta qué fecha respetas el precio.',
      'La forma de pago y las condiciones aparecen al final del PDF.',
    ],
    'Válida 15 días, 50 % de anticipo y 50 % al terminar.',
  ),
  cobros(
    'Cobros',
    'Lo que el cliente ya te pagó y lo que todavía te debe.',
    [
      'Registra cada anticipo o abono con su método de pago.',
      'El saldo incluye el IVA y los adicionales.',
      'Los cobros también aparecen en Movimientos.',
    ],
    'Total \$1.150, anticipo \$500: saldo pendiente \$650.',
  ),
  adicionales(
    'Adicionales',
    'Trabajos extra que el cliente pidió durante la obra.',
    [
      'Registra la descripción y el precio sin IVA.',
      'Se suman a lo que el cliente te debe.',
      'Comparte la orden de cambio en PDF para que quede por escrito.',
    ],
    'Dos tomacorrientes extra por \$40.',
  ),
  consumos(
    'Consumo real de materiales',
    'El material que realmente usaste, para compararlo con lo cotizado.',
    [
      'Registra material, cantidad y costo real.',
      'Desde el primer consumo, la rentabilidad usa lo consumido en lugar de lo cotizado.',
      'Registra todos los materiales de la obra para que el cálculo sea correcto.',
    ],
    'Cotizaste 10 m de cable y usaste 12 m: verás el sobrecosto.',
  ),
  versiones(
    'Versiones de la proforma',
    'Si editas una proforma que ya enviaste, la anterior se guarda.',
    [
      'Solo se guarda una versión cuando cambia algo que el cliente vio.',
      'Puedes volver a compartir el PDF de cualquier versión.',
    ],
    'v1 con \$1.800 y la vigente v2 con \$1.950.',
  ),
  ajustesCotizacion(
    'Ajustes de cotización',
    'Los valores con los que nace cada cotización nueva.',
    [
      'IVA, margen, validez, forma de pago y condiciones.',
      'Cada cotización puede cambiarlos sin afectar a las demás.',
    ],
    'Si no cobras IVA, elige "No cobro IVA" una sola vez aquí.',
  ),
  fotos(
    'Fotos de la obra',
    'Guarda el avance y el resultado de tus trabajos para mostrarlos a tus clientes.',
    [
      'Toma una foto o elige varias de la galería; Coti las optimiza para que ocupen poco.',
      'Toca una foto para verla grande, agregarle una nota o compartirla por WhatsApp.',
      'Encuentra todas tus fotos en Documentos, en la vista Fotos.',
    ],
    'Comparte el antes y el después de una cocina con un nuevo cliente.',
  ),
  galeriaFotos(
    'Fotos de tus obras',
    'Todas las fotos guardadas, agrupadas por obra.',
    [
      'Busca por cliente, obra, código COT o nota.',
      'Filtra por mes para encontrar un trabajo de una fecha.',
      'Toca una foto para verla o compartirla.',
    ],
    'Busca "baño" y elige marzo para ver ese trabajo.',
  ),
  seguridad(
    'Seguridad',
    'Evita que otra persona vea tus cobros y ganancias si toma tu teléfono.',
    [
      'Activa el interruptor y confirma con tu huella o la clave del teléfono.',
      'Coti pedirá desbloquearse al abrirse y al volver después de un minuto fuera.',
      'Coti no guarda ninguna clave: usa el bloqueo de tu teléfono.',
    ],
    'Si prestas tu teléfono, nadie verá tus cuentas sin tu huella.',
  ),
  respaldo(
    'Respaldo de datos',
    'Tus datos viven solo en este teléfono; el respaldo evita perderlos.',
    [
      'Crea un respaldo .zip y guárdalo en tu correo o en la nube.',
      'Para recuperar tus datos, restaura ese archivo.',
      'Restaurar reemplaza los datos actuales del teléfono.',
    ],
    'Haz un respaldo cada semana o antes de cambiar de teléfono.',
  );

  const TemaAyuda(this.titulo, this.paraQue, this.pasos, this.ejemplo);

  final String titulo;
  final String paraQue;
  final List<String> pasos;
  final String ejemplo;
}
