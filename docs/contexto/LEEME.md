# Contexto del proyecto Coti

Esta carpeta es la memoria del proyecto entre sesiones de trabajo, ya sean de personas o de asistentes de IA. Sirve para saber qué se propuso, qué existe, qué cambió y qué sigue, sin releer todo el código.

## Archivos

| Archivo | Responde a | Cuándo actualizarlo |
| --- | --- | --- |
| [ESTADO.md](ESTADO.md) | ¿Qué tiene la app hoy y qué le falta frente a lo propuesto? | Cuando una funcionalidad cambia de Falta a Parcial o Hecho. |
| [PENDIENTES.md](PENDIENTES.md) | ¿Qué tareas quedan y en qué orden? | Al empezar, terminar o descubrir una tarea. |
| [CAMBIOS.md](CAMBIOS.md) | ¿Qué se cambió, cuándo y por qué? | Al terminar cada tarea, antes del commit. |
| [DECISIONES.md](DECISIONES.md) | ¿Qué se decidió y qué falta decidir? | Cuando se toma o se abre una decisión de diseño. |

Documentación técnica existente:

- [../ARQUITECTURA.md](../ARQUITECTURA.md): cómo está construida la app.
- [../VERIFICACION.md](../VERIFICACION.md): pruebas y verificaciones realizadas.

## Flujo de trabajo

1. Antes de empezar, leer `ESTADO.md` y `PENDIENTES.md`. Elegir una tarea por su ID.
2. Cambiar el estado de la tarea a "En curso".
3. Al terminar:
   - Mover la tarea a "Completadas" en `PENDIENTES.md`, con fecha.
   - Agregar una entrada en `CAMBIOS.md` que cite el ID.
   - Actualizar `ESTADO.md` si cambió la cobertura de alguna funcionalidad.
   - Registrar en `DECISIONES.md` cualquier decisión tomada.
4. Revisar los cambios y hacer el commit manualmente (regla 7 de `AGENTS.md`).

## Convenciones

- IDs: `P-###` para pendientes y `D-###` para decisiones. Un ID no se reutiliza.
- Prioridad:
  - Alta: impide el uso real, pierde datos o muestra información incorrecta.
  - Media: necesaria para cumplir la propuesta.
  - Baja: mejora o limpieza.
- Estados: Pendiente, En curso, Bloqueada (indicar el motivo), Hecha.
- Fechas en formato AAAA-MM-DD.
- Entradas cortas: qué, por qué y archivos afectados. El detalle técnico va en `ARQUITECTURA.md`.
