# RF-017 — Creación de Días de Rodaje en el Plan de Rodaje

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-017 |
| Título | Creación de Días de Rodaje en el Plan de Rodaje |
| Módulo | Gestión de Calendario y Planeación |
| Prioridad | Crítica |
| Estado | Pendiente |
| RNF asociados | RNF-010, RNF-019 |

---

**Descripción**: El sistema debe permitir crear días de rodaje en el Plan de Rodaje (cronograma tipo stripboard) y asignarles las escenas que se filmarán ese día.

**Entradas**:

- Versión del plan
- Semana de grabación y número de día de rodaje
- Hora de inicio y hora de fin (call time)
- Locación
- Notas generales del día
- Escenas a filmar ese día

**Proceso**:

- Quien tenga permiso de edición del plan crea un día de rodaje con los datos anteriores.
- Asigna escenas al día; el orden de las escenas dentro del día se define arrastrando y soltando.
- Cada escena muestra un ícono de espacio y momento del día (por ejemplo interior/exterior, día/noche), sin colores por categoría.
- El plan queda asociado al proyecto activo.

**Salidas**:

- Día de rodaje guardado con sus escenas ordenadas

**Precondiciones**:

- Proyecto activo
- Usuario con permiso de edición del Plan de Rodaje (Administrador o Director)

**Postcondiciones**:

- El día aparece en el plan para todo el equipo con acceso al módulo

**Actores**: Administrador, Director (edición); demás roles (consulta)

**Dependencias**:

- RF-016 (Creación de proyectos)
- RF-027 (Desglose editable, de donde provienen las escenas)
