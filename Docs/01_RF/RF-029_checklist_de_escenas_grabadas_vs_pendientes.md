# RF-029 — Checklist de Escenas Grabadas vs Pendientes

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-029 |
| Título | Checklist de Escenas Grabadas vs Pendientes |
| Módulo | Reportes y Analítica |
| Prioridad | Media |
| Estado | Completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe mostrar en el panel del proyecto el avance de la producción con gráficas de escenas por estado (Pendiente, En proceso, Finalizada, Eliminada) y otros resúmenes del proyecto.

**Entradas**:

- Escenas del proyecto y su estado (RF-013)
- Días de rodaje, personajes y guiones del proyecto

**Proceso**:

- Al abrir el panel del proyecto, el sistema calcula los totales: guiones, escenas, días dramáticos, fechas de grabación y personajes.
- Muestra gráficas de barras: escenas por estado, por momento del día, por espacio (INT/EXT), por ciudad y horario de grabación (día/noche).
- Los datos se recalculan cada vez que se abre o actualiza el panel.

**Salidas**:

- Resumen y gráficas del avance del proyecto

**Precondiciones**:

- Usuario con acceso al proyecto

**Postcondiciones**:

- Ninguna (consulta de solo lectura)

**Actores**: Todos los usuarios del proyecto

**Dependencias**:

- RF-013 (Estados de la escena)
- RF-017 (Plan de rodaje)
