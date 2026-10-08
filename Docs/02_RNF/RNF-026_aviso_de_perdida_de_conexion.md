# RNF-026 — Aviso de Pérdida de Conexión

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-026 |
| Título | Aviso de Pérdida de Conexión |
| Categoría | Confiabilidad / Usabilidad |
| Prioridad | Media |
| Estado | Pendiente |
| RF asociados | RF-011 |

---

**Descripción**: La aplicación debe avisar a la persona, en cualquier pantalla, cuando el dispositivo se quede sin conexión de red, para que entienda por qué una acción puede fallar. En esta versión no existe modo offline: no se guardan datos en cola ni se sincronizan después; el modo offline completo queda como mejora futura.

**Métrica**:
- Banner visible en menos de 3 segundos tras perder la conexión (Wi-Fi o datos)
- El banner se oculta al recuperarse la conexión
- Funciona en todas las pantallas, incluida la de inicio de sesión
- Las acciones que requieren servidor muestran su propio mensaje de error si fallan

**Aplica a**:
- Toda la aplicación

**Estándar/Norma**: ISO/IEC 25010 - Confiabilidad

**Método de Verificación**:
- Activar modo avión con la app abierta y verificar que aparece el aviso
- Desactivarlo y verificar que el aviso desaparece
- Abrir la app ya sin conexión y verificar que el aviso aparece desde el inicio
