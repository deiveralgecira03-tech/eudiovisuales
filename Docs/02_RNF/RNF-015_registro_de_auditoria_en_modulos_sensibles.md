# RNF-015 — Registro de Auditoría en Módulos Sensibles

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-015 |
| Título | Registro de Auditoría en Módulos Sensibles |
| Categoría | Seguridad / Trazabilidad |
| Prioridad | Alta |
| Estado | Pendiente |
| RF asociados | RF-009, RF-030 |

---

**Descripción**: El sistema debe registrar de forma automática y no modificable las acciones sensibles de los módulos auditados (autenticación, usuarios y roles, guiones y fotografías), conservándolas para consulta del Administrador y el Director.

**Métrica**:

- 100% de las acciones definidas en RF-009 registradas
- Campos obligatorios por registro:

        Fecha y hora
        Usuario
        Acción y módulo
        Elemento afectado
        IP origen
        Dispositivo
        Resultado
- Registros no editables ni eliminables desde la aplicación
- Retención definida por el equipo (propuesta: 1 año)

**Aplica a**:
- RF-009 (Log de auditoría)
- RF-030 (Reporte de auditoría)

**Estándar/Norma**:
- ISO/IEC 27001

**Método de Verificación**:
- Ejecutar 50 acciones auditadas (inicios de sesión, subidas y descargas de guiones y fotos, cambios de rol)
- Verificar que existen los 50 registros con todos sus campos
- Verificar que no hay forma de editar o borrar un registro desde la aplicación
