# RF-020 — Notificaciones del Proyecto

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-020 |
| Título | Notificaciones del Proyecto |
| Módulo | Gestión de Calendario y Planeación |
| Prioridad | Alta |
| Estado | Completado |
| RNF asociados | RNF-011, RNF-012, RNF-019 |

---

**Descripción**: El sistema debe ofrecer un tablón de notificaciones por proyecto con el que se comunican avisos y cambios al equipo, ya sea a todo el proyecto o solo a uno o más departamentos. Cada persona ve cuántas notificaciones no ha leído. Este requisito reemplaza a los antiguos de notificaciones push, canales por departamento y comunicados oficiales.

**Entradas**:

- Texto de la notificación
- Alcance: general (todo el equipo) o específica (uno o varios departamentos)
- Foto opcional adjunta
- Origen: manual, o automática desde cambios del Plan de Rodaje (RF-018)

**Proceso**:

- Solo Director y Jefe de Departamento pueden publicar; ambos pueden elegir varios departamentos a la vez.
- Al publicar, la notificación queda visible para los destinatarios al abrir o actualizar la app.
- Cada destinatario ve la lista de notificaciones que le corresponden, con un contador de no leídas en la campana.
- Al abrir una notificación, el sistema registra su lectura por usuario (con fecha y hora).
- La foto adjunta se sirve desde el almacenamiento solo a quienes pueden ver la notificación.

**Salidas**:

- Notificación publicada y visible para el alcance elegido
- Contador de no leídas por usuario
- Registro de lectura por usuario

**Precondiciones**:

- Proyecto activo
- Para publicar: rol Director o Jefe de Departamento

**Postcondiciones**:

- Los destinatarios pueden consultar el aviso y quedó registrado quién lo leyó

**Actores**: Director, Jefe de Departamento (publican); todos los usuarios del proyecto (leen)

**Dependencias**:

- RF-005 (Roles y permisos)
- RF-018 (Modificación del plan de rodaje)
