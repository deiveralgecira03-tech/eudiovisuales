# RF-018 — Modificación del Plan de Rodaje

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-018 |
| Título | Modificación del Plan de Rodaje |
| Módulo | Gestión de Calendario y Planeación |
| Prioridad | Crítica |
| Estado | Pendiente |
| RNF asociados | RNF-010, RNF-011 |

---

**Descripción**: El sistema debe permitir modificar o cancelar días de rodaje y reordenar o reasignar sus escenas, llevando registro de los cambios para poder notificarlos al equipo.

**Entradas**:

- Día de rodaje a modificar
- Nuevos valores (fecha, horario, locación, notas) o nueva asignación/orden de escenas

**Proceso**:

- Quien tenga permiso de edición cambia los datos del día, mueve escenas entre días o reordena escenas arrastrando.
- El sistema guarda los cambios y detecta qué se modificó desde la última notificación.
- Al terminar, el usuario puede elegir "Notificar estos cambios al equipo": se genera una notificación del proyecto (RF-020) con el resumen de cambios.
- Si la persona cierra sesión por inactividad con cambios sin notificar, el sistema los envía automáticamente.
- Un día de rodaje se puede desactivar o eliminar.

**Salidas**:

- Plan actualizado
- Notificación del proyecto con el resumen de cambios (opcional o automática)

**Precondiciones**:

- El día de rodaje existe
- Usuario con permiso de edición del Plan de Rodaje

**Postcondiciones**:

- El equipo ve el plan vigente; los cambios notificados quedan registrados como notificación de origen "plan de rodaje"

**Actores**: Administrador, Director

**Dependencias**:

- RF-017 (Creación de días de rodaje)
- RF-020 (Notificaciones del proyecto)
