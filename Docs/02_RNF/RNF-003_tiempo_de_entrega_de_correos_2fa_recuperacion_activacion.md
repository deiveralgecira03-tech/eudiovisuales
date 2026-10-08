# RNF-003 — Tiempo de Entrega de Correos (2FA, Recuperación, Activación)

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-003 |
| Título | Tiempo de Entrega de Correos (2FA, Recuperación, Activación) |
| Categoría | Rendimiento |
| Prioridad | Crítica |
| Estado | Pendiente |
| RF asociados | RF-003, RF-004, RF-007 |

---

**Descripción**: Los correos que envía el sistema (código de 2FA, recuperación de contraseña, activación o invitación de cuenta) deben salir del servidor y llegar al destinatario en menos de 60 segundos.

**Métrica**:
- Tiempo de entrega < 60 segundos (percentil 90)
- Si el envío falla, el sistema informa el error al usuario en lugar de dar la operación por exitosa

**Aplica a**:
- RF-003 (Login con 2FA)
- RF-004 (Notificaciones por correo)
- RF-007 (Recuperación de contraseña)

**Estándar/Norma**: SLA del proveedor de correo (SMTP)

**Método de Verificación**:
- Pruebas con 100 envíos de correo
- Medir el tiempo desde la solicitud hasta la recepción
- Verificar p90 < 60 segundos
