# Pendientes

Última actualización: 2026-11-25 (plan de publicación y monetización).

## Dónde quedamos (2026-11-25)

- Terminadas: el splash animado (P-008), las fases 0 a 3 (salvo la prueba en teléfono, P-006) y la Fase 5 salvo P-055 a P-057. El detalle está en `CAMBIOS.md`.
- Verificación: `flutter analyze` sin errores ni advertencias; `flutter test` 115 de 115; APK de release compilado.
- Commit: el trabajo hasta la Fase 2 está en 489e56c. Lo posterior está sin commit: Fase 3, Fase 5, splash más pausado, ayuda (P-060, P-061), protección del dinero, fotos y bloqueo (P-062 a P-065).
- Siguiente: la Fase 7 (publicar en Google Play), en el orden de su tabla. Lo primero es P-070 (aviso de versión nueva), porque debe ir en la primera versión publicada.
- Del usuario:
  - Crear la clave de publicación y `android/key.properties` (`docs/PUBLICACION.md`).
  - Probar en un teléfono (P-006).
  - Borrar las carpetas vacías `lib/features/` y `lib/data/`.
- Bloqueado: la Fase 4 espera D-101. La monetización (Fase 8) queda para cuando la app crezca (D-028).
- Opcional: P-056 (iOS) y P-057 (consultas por período).

Las tareas están ordenadas por fase. Dentro de cada fase, conviene seguir el orden de los IDs. Las convenciones de prioridad y estado están en [LEEME.md](LEEME.md).

## Fase 0: estabilizar lo que existe

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-006 | Probar en un teléfono Android | Alta | Pendiente | Cámara, galería, Wikimedia, compartir e imprimir PDF y uso sin conexión probados; el resultado queda en `VERIFICACION.md`. |

## Fase 1: ingresos y cobros

Completada el 2026-11-25.

## Fase 2: proforma profesional

Completada el 2026-11-25.

## Fase 3: trabajo durante la obra

Completada el 2026-11-25.

## Fase 4: modo sueldo mensual

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-040 | Selector de modo y navegación según el modo | Media | Bloqueada | Esperando D-101. |
| P-041 | Sueldo mensual, día de pago y períodos | Media | Pendiente | El usuario registra su sueldo y la app calcula el período actual. |
| P-042 | Gastos personales contra el sueldo | Media | Pendiente | Se ve cuánto queda del sueldo y para cuántos días; presupuesto opcional por categoría. |
| P-043 | Registro de actividades del trabajo | Media | Pendiente | Se guardan fecha, horas, descripción y empresa o jefe. |
| P-044 | Informe mensual de actividades | Baja | Pendiente | Se exporta un PDF con las actividades del mes. |

## Fase 6: mejoras tras probar el APK

Completada el 2026-11-25: ayuda al usuario (P-060, P-061), protección del dinero (P-062), fotos de obra (P-063, P-064) y bloqueo (P-065).

## Fase 7: publicar en Google Play

Orden acordado el 2026-11-25. Publicar gratis y sin límites para conseguir usuarios y opiniones (D-028).

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-070 | Aviso de versión nueva desde Google Play | Alta | Pendiente | Con `in_app_update`, la app ofrece actualizar sin interrumpir y puede exigirlo en cambios críticos. Va en la primera versión publicada, o esos usuarios nunca verán el aviso. Solo funciona instalada desde Play Store. |
| P-071 | Clave de publicación y AAB firmado | Alta | Pendiente | El usuario crea su clave (`docs/PUBLICACION.md`) y `flutter build appbundle --release` genera el AAB firmado. |
| P-072 | Política de privacidad publicada | Alta | Pendiente | Página web que explique que los datos quedan en el teléfono y para qué se usan cámara, galería, huella e internet (Wikimedia); enlazada en Play Console y en Mi perfil. |
| P-073 | Ficha de Play Store | Media | Pendiente | Nombre, descripción corta y larga, ícono 512 px, gráfico destacado, capturas de teléfono y tablet, clasificación de contenido y formulario de seguridad de datos. |
| P-074 | Prueba cerrada en Play Console | Alta | Pendiente | Al menos 12 personas durante 14 días (requisito para cuentas personales), con errores corregidos. Depende de P-006. |
| P-075 | Publicación en producción | Alta | Pendiente | Versión 1.0.0 disponible en Play Store para todos. |

## Fase 8: monetización (futuro)

Se retoma cuando la app tenga usuarios (D-028). Sin publicidad por ahora: da poco dinero y molesta mientras la app se da a conocer.

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-080 | Elegir el modelo de pago | Baja | Bloqueada | Espera D-108: suscripción mensual o anual, pago único de por vida, o ambos. |
| P-081 | Cobro con Google Play Billing y RevenueCat | Baja | Bloqueada | Compra, "Restaurar compra" y consulta "¿es Premium?" sin servidor propio. Depende de P-080. |
| P-082 | Límites del plan gratis y pantalla Premium | Baja | Bloqueada | Por ejemplo: 5 proformas PDF al mes con pie "Hecha con Coti" y 20 fotos de obra en el plan gratis. Al llegar al límite, nadie queda bloqueado a mitad de un trabajo. Depende de P-080. |
| P-083 | Respaldo automático en la nube (Premium) | Baja | Bloqueada | Sube el .zip de respaldo al Google Drive del propio usuario (carpeta oculta), con inicio de sesión de Google y restauración en otro teléfono. Revisar si Google exige verificar la app por el permiso de Drive. Depende de P-081. |
| P-084 | Publicidad en el plan gratis | Baja | Descartada por ahora | Solo si los números lo justifican: banner discreto y anuncio con recompensa, nunca en formularios ni en el PDF. |

## Fase 5: publicación y orden del código

| ID | Tarea | Prioridad | Estado | Listo cuando |
| --- | --- | --- | --- | --- |
| P-055 | Vocabulario genérico o por rubro | Baja | Pendiente | Pospuesta por D-015: se mantiene el vocabulario de construcción. |
| P-056 | Proyecto iOS | Baja | Pendiente | Solo si se decide publicar en iPhone. |
| P-057 | Consultas por período cuando crezcan los datos | Baja | Pendiente | La carga deja de leer toda la base en memoria. |

## Completadas

Mover aquí cada tarea terminada, con su fecha y la referencia a `CAMBIOS.md`.

| ID | Tarea | Fecha |
| --- | --- | --- |
| P-001 | Separar la proforma del cliente del desglose interno | 2026-11-25 (ver `CAMBIOS.md`) |
| P-002 | Evitar gastos que no cuentan en ningún total | 2026-11-25 (ver `CAMBIOS.md`) |
| P-003 | No perder gastos al eliminar una obra | 2026-11-25 (ver `CAMBIOS.md`) |
| P-004 | Unificar el código de documento (COT-####) | 2026-11-25 (ver `CAMBIOS.md`) |
| P-005 | Ejecutar análisis, pruebas y compilación | 2026-11-25 (ver `CAMBIOS.md`) |
| P-007 | Respaldo y restauración de datos | 2026-11-25 (ver `CAMBIOS.md`) |
| P-008 | Corregir el splash screen y animar el logo | 2026-11-25 (ver `CAMBIOS.md`) |
| P-010 | Entidad `Ingreso` y tabla `ingresos` | 2026-11-25 (ver `CAMBIOS.md`) |
| P-011 | Anticipos y abonos por obra; saldo pendiente | 2026-11-25 (ver `CAMBIOS.md`) |
| P-012 | Pantalla de ingresos o de movimientos | 2026-11-25 (ver `CAMBIOS.md`) |
| P-013 | Balance real en Inicio | 2026-11-25 (ver `CAMBIOS.md`) |
| P-014 | Reportes por mes y por categoría | 2026-11-25 (ver `CAMBIOS.md`) |
| P-020 | Datos del emisor | 2026-11-25 (ver `CAMBIOS.md`) |
| P-021 | Datos del cliente y lista de clientes | 2026-11-25 (ver `CAMBIOS.md`) |
| P-022 | IVA configurable | 2026-11-25 (ver `CAMBIOS.md`) |
| P-023 | Validez de la oferta, forma de pago y condiciones | 2026-11-25 (ver `CAMBIOS.md`) |
| P-024 | Estado Rechazada o Cancelada y fecha de creación | 2026-11-25 (ver `CAMBIOS.md`) |
| P-025 | Margen configurable | 2026-11-25 (ver `CAMBIOS.md`) |
| P-026 | Partidas de servicio sin material | 2026-11-25 (ver `CAMBIOS.md`) |
| P-030 | Consumos reales de obra | 2026-11-25 (ver `CAMBIOS.md`) |
| P-031 | Adicionales u órdenes de cambio | 2026-11-25 (ver `CAMBIOS.md`) |
| P-032 | Congelar o versionar la proforma enviada | 2026-11-25 (ver `CAMBIOS.md`) |
| P-050 | `applicationId` definitivo y firma de release | 2026-11-25 (ver `CAMBIOS.md`) |
| P-051 | Retirar la capa `lib/screens/` | 2026-11-25 (ver `CAMBIOS.md`) |
| P-052 | Dividir `editor_proyecto_pagina.dart` | 2026-11-25 (ver `CAMBIOS.md`) |
| P-053 | Unificar el nombre del producto (Coti) | 2026-11-25 (ver `CAMBIOS.md`) |
| P-054 | Agregar `.gitattributes` | 2026-11-25 (ver `CAMBIOS.md`) |
| P-060 | Tutorial de bienvenida la primera vez | 2026-11-25 (ver `CAMBIOS.md`) |
| P-061 | Botón de información en pestañas y secciones | 2026-11-25 (ver `CAMBIOS.md`) |
| P-062 | Proyectos con dinero se cancelan; devoluciones al cliente | 2026-11-25 (ver `CAMBIOS.md`) |
| P-063 | Fotos de obra con visor y compartir | 2026-11-25 (ver `CAMBIOS.md`) |
| P-064 | Galería de fotos en Documentos | 2026-11-25 (ver `CAMBIOS.md`) |
| P-065 | Bloqueo con huella o clave del teléfono | 2026-11-25 (ver `CAMBIOS.md`) |
