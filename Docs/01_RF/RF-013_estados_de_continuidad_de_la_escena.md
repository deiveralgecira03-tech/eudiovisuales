# RF-013 — Estados de Continuidad de la Escena

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-013 |
| Título | Estados de Continuidad de la Escena |
| Módulo | Gestión de Fotografías de Continuidad |
| Prioridad | Alta |
| Estado | Completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe llevar el estado de seguimiento de cada escena (Pendiente, En proceso, Finalizada) para saber qué tiene registrada la continuidad y qué falta.

**Entradas**:

- Escena
- Estado: Pendiente, En proceso o Finalizada

**Proceso**:

- Toda escena nueva se crea en estado "Pendiente".
- Quien tenga permiso de edición de escenas cambia el estado desde la pantalla de edición de la escena.
- El estado se muestra con un color distintivo en el listado de escenas y en el plan de rodaje.
- El panel del proyecto resume la cantidad de escenas por estado (RF-029).
- Una escena eliminada se cuenta aparte como "Eliminada".

**Salidas**:

- Estado actualizado de la escena
- Resumen por estado en el panel del proyecto

**Precondiciones**:

- La escena existe en el proyecto
- Usuario con permiso de edición de escenas

**Postcondiciones**:

- El estado queda visible para todo el equipo con acceso al módulo Escenas

**Actores**: Administrador, Director (edición); demás roles (consulta)

**Dependencias**:

- RF-027 (Desglose editable) para la creación de escenas
