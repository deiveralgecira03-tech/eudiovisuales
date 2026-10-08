# RF-030 — Reporte de Auditoría de Accesos

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-030 |
| Título | Reporte de Auditoría de Accesos |
| Módulo | Reportes y Analítica |
| Prioridad | Alta |
| Estado | Pendiente |
| RNF asociados | RNF-015 |

---

**Descripción**: El sistema debe permitir consultar el log de auditoría (RF-009) con filtros, para investigar accesos sospechosos o una posible filtración. Cubre únicamente los módulos auditados: autenticación, usuarios y roles, guiones y fotografías.

**Entradas**:

- Usuario
- Rango de fechas
- Módulo y tipo de acción
- Resultado (exitoso / fallido)

**Proceso**:

- Administrador o Director abre el reporte de auditoría del proyecto.
- Aplica filtros y consulta los registros: fecha y hora, usuario, acción, elemento, IP, dispositivo y resultado.
- Puede exportar el resultado en PDF; la exportación también queda registrada en el log.

**Salidas**:

- Lista filtrada de registros de auditoría
- Exportación en PDF

**Precondiciones**:

- Existen registros de auditoría
- Usuario con rol Administrador o Director

**Postcondiciones**:

- La consulta y exportación quedan registradas

**Actores**: Administrador, Director

**Dependencias**:

- RF-009 (Log de auditoría)
