# RF-009 — Log de Auditoría de Accesos y Acciones

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-009 |
| Título | Log de Auditoría de Accesos y Acciones |
| Módulo | Autenticación y Gestión de Usuarios |
| Prioridad | Alta |
| Estado | Pendiente |
| RNF asociados | RNF-015 |

---

**Descripción**: El sistema debe registrar en un log de auditoría las acciones sensibles realizadas en un conjunto acotado de módulos (no en toda la aplicación), de modo que el Administrador y el Director puedan investigar accesos sospechosos o una posible filtración de material confidencial.

**Módulos y acciones auditadas**:

- Autenticación: inicios de sesión exitosos y fallidos, cierres de sesión, recuperación de contraseña
- Usuarios y roles: invitación, cambio de rol, suspensión/reactivación, cambios de acceso por módulo
- Guiones: subida de un guion, visualización y descarga del PDF
- Fotografías: subida, descarga, envío a la papelera, restauración y eliminación definitiva

Fuera del alcance de la auditoría: escenas, desglose, plan de rodaje, personajes/actores, crew list y notificaciones.

**Entradas** (capturadas automáticamente):

- Fecha y hora de la acción
- Usuario que la realiza
- Acción y módulo
- Elemento afectado (guion, foto, usuario)
- Dirección IP y dispositivo
- Resultado (exitoso / fallido)

**Proceso**:

- Cada acción auditada genera un registro en el servidor, sin intervención del usuario.
- Los registros no se pueden editar ni eliminar desde la aplicación.
- La consulta del log queda limitada a Administrador y Director (ver RF-030).

**Salidas**:

- Registros de auditoría consultables por proyecto

**Precondiciones**:

- Usuario autenticado (excepto en intentos fallidos de inicio de sesión)

**Postcondiciones**:

- Trazabilidad de quién accedió o descargó material sensible

**Actores**: Sistema (registro automático), Administrador y Director (consulta)

**Dependencias**:

- RF-003 (Inicio de sesión)
- RF-005 (Roles y permisos)
