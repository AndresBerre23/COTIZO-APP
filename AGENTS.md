# PROPÓSITO

Este proyecto debe mantenerse modular, escalable, mantenible, legible y optimizado para minimizar el consumo de contexto y tokens en futuras interacciones.

La prioridad no es escribir código rápido, sino escribir código limpio, reutilizable y fácil de mantener.

Antes de realizar cualquier cambio, analizar la arquitectura existente y respetar los patrones ya implementados.

---

# REGLAS OBLIGATORIAS

Estas reglas tienen prioridad sobre cualquier preferencia de implementación.

## 1. IDIOMA OBLIGATORIO

### Código
- Todos los comentarios deben estar en español.
- Nunca escribir comentarios en inglés.
- Nunca mezclar idiomas en el código.

### Documentación
- Toda documentación debe escribirse en español.
- Toda explicación debe escribirse en español.

### Planeación
- El Walkthrough debe estar completamente en español.
- El Implementation Plan debe estar completamente en español.
- Nunca generar estos apartados en inglés.

## 2. COMENTARIOS

Los comentarios deben:
- Ser cortos.
- Ser precisos.
- Ser claros.
- Aportar valor.
- Evitar comentarios redundantes.

**Incorrecto:**
```typescript
// Incrementa el contador
contador++;
```

**Correcto:**
```typescript
// Evita solicitudes duplicadas
```

Si el código se entiende fácilmente, no comentar.

## 3. TRADUCCIÓN DE COMENTARIOS

Si se encuentran comentarios en inglés:
- Traducirlos al español.
- Eliminar la versión en inglés.
- Mantener exactamente el mismo significado.

## 4. OPTIMIZACIÓN PARA FUTURAS CONSULTAS

Todo cambio debe realizarse pensando en minimizar tokens futuros.

Por tanto:
- Evitar archivos gigantes.
- Separar responsabilidades.
- Modularizar funcionalidades.
- Reducir acoplamiento.
- Mantener estructuras fáciles de localizar.

**Objetivo:**
Que futuras modificaciones requieran abrir la menor cantidad posible de archivos.

## 5. ARQUITECTURA MODULAR

Siempre que sea posible:
- Separar pantallas.
- Separar componentes.
- Separar hooks.
- Separar servicios.
- Separar utilidades.
- Separar constantes.
- Separar tipos.
- No concentrar múltiples responsabilidades en un mismo archivo.

## 6. ESTRUCTURA DE PANTALLAS

Cada pantalla debe tener su propio módulo siempre que el alcance lo justifique.

**Ejemplo:**
```text
src/
└── pantallas/
    └── usuarios/
        ├── UsuariosPagina.tsx
        ├── componentes/
        ├── hooks/
        ├── servicios/
        ├── tipos/
        └── utilidades/
```

## 7. GITHUB Y COMMITS

Nunca ejecutar automáticamente:
```bash
git commit
```
Nunca ejecutar automáticamente:
```bash
git push
```
Nunca asumir que se debe crear un commit.

Cuando el trabajo haya finalizado:
1. Informar los cambios realizados.
2. Solicitar al usuario que revise los cambios.
3. Solicitar al usuario que realice el commit manualmente.

## 8. RESPONSIVIDAD OBLIGATORIA

Toda modificación visual deberá verificarse para:
- Móviles.
- Tablets.
- Portátiles.
- Escritorio.

Antes de finalizar cualquier tarea visual verificar:
- Diseño responsive móvil.
- Diseño responsive tablet.
- Diseño responsive escritorio.

Ningún elemento debe romperse por tamaño de pantalla.

## 9. NOMBRES EN ESPAÑOL

Cuando no afecte dependencias externas:
- Renombrar funciones al español.
- Renombrar utilidades al español.
- Renombrar variables significativas al español.

**Ejemplo:**
`getUsers()` debe convertirse en `obtenerUsuarios()`

**Ejemplo:**
`handleSubmit()` debe convertirse en `procesarEnvio()`

No modificar nombres pertenecientes a librerías externas.

## 10. PROHIBICIÓN DE EMOJIS

No utilizar emojis en:
- Código.
- Comentarios.
- Logs.
- Documentación.

Si existen emojis:
- Eliminarlos.

**Ejemplos prohibidos:**
```typescript
// [emoji de verificacion] Operacion correcta
console.log("[emoji de cohete] iniciado");
```

## 11. REFACTORIZACIÓN CONTINUA

Si un archivo es demasiado grande, antes de seguir agregando lógica:
- Evaluar refactorización.
- Evaluar extracción de componentes.
- Evaluar extracción de hooks.
- Evaluar extracción de servicios.
- Evaluar extracción de utilidades.

Mantener siempre:
- Funcionalidad.
- Diseño.
- Comportamiento visual.

## 12. CONSISTENCIA VISUAL

Al crear componentes nuevos:
- Mantener colores existentes.
- Mantener tipografías existentes.
- Mantener espaciados existentes.
- Mantener estilo visual existente.
- Mantener experiencia visual consistente.

Nunca introducir estilos que parezcan pertenecer a otra aplicación.

## 13. MEJORA DEL DISEÑO VISUAL

Si una página luce demasiado genérica (por ejemplo: mucho texto, solo iconos, demasiado espacio vacío, diseño plano o poco atractivo), intentar mejorar mediante:
- SVGs.
- Vectores.
- Ilustraciones.
- Microanimaciones.
- Efectos visuales sutiles.
- Transiciones suaves.
- Elementos visuales modernos.

Manteniendo siempre:
- Rendimiento.
- Accesibilidad.
- Consistencia visual del sistema.

El objetivo es generar interfaces atractivas para el usuario final.

## 14. SEGURIDAD

Nunca almacenar:
- API Keys.
- Tokens.
- Secretos.
- Credenciales.

Siempre utilizar `.env`. Agregar o verificar `.env`.
Nunca exponer claves reales en el repositorio.

## 15. REUTILIZACIÓN DE CÓDIGO

Antes de crear cualquier:
- Componente.
- Hook.
- Servicio.
- Utilidad.
- Tipo.

Verificar:
- Si ya existe.
- Si puede reutilizarse.
- Si puede extenderse.

La reutilización tiene prioridad sobre la duplicación.

## 16. RESPONSABILIDAD ÚNICA

Los componentes deben tener una única responsabilidad.

Evitar:
- Componentes que gestionen UI, lógica y llamadas API al mismo tiempo.
- Hooks multipropósito gigantes.
- Servicios con responsabilidades mezcladas.

Cada módulo debe tener una función clara y específica.

## 17. TAMAÑO DE ARCHIVOS

Si es posible mantener:
- Componentes: menos de 200 líneas.
- Hooks: menos de 200 líneas.
- Servicios: menos de 300 líneas.
- Pantallas: menos de 300 líneas.

Si un archivo supera dichos tamaños:
- Evaluar división.
- Evaluar refactorización.
- Evaluar modularización.

## 18. CONSERVACIÓN DEL DISEÑO

Durante cualquier refactorización:

NO cambiar:
- Colores.
- Diseño.
- Distribución visual.
- Experiencia del usuario.

Salvo que el requerimiento lo solicite explícitamente.

## 19. CHECKLIST OBLIGATORIO

Antes de finalizar cualquier tarea verificar:
- [ ] Comentarios en español.
- [ ] Comentarios cortos y precisos.
- [ ] Sin comentarios en inglés.
- [ ] Walkthrough en español.
- [ ] Implementation Plan en español.
- [ ] Arquitectura modular.
- [ ] Sin commits automáticos.
- [ ] Responsive móvil.
- [ ] Responsive tablet.
- [ ] Responsive escritorio.
- [ ] Funciones internas en español cuando sea posible.
- [ ] Sin emojis.
- [ ] Archivos grandes refactorizados.
- [ ] Consistencia visual respetada.
- [ ] Diseño atractivo y moderno.
- [ ] Variables sensibles protegidas mediante `.env`.
- [ ] Sin duplicación de código.

---

# REGLA FINAL

Siempre priorizar:
- Legibilidad.
- Modularidad.
- Reutilización.
- Escalabilidad.
- Mantenimiento futuro.
- Optimización del consumo de contexto y tokens.

Si existe conflicto entre rapidez y calidad, elegir calidad.

