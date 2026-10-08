# RNF-016 — Política de Sesiones

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-016 |
| Título | Política de Sesiones |
| Categoría | Seguridad |
| Prioridad | Alta |
| Estado | Pendiente |
| RF asociados | RF-003, RF-007 |

---

**Descripción**: El sistema debe gestionar las sesiones con tokens JWT de duración limitada, invalidar el token al cerrar sesión y cerrar automáticamente la sesión tras un periodo de inactividad.

**Métrica**:
- Token de acceso (JWT) con vigencia de 60 minutos (configurable)
- Cierre de sesión por inactividad a los 15 minutos, con aviso 60 segundos antes del cierre
- Al cerrar sesión, el token queda revocado y no puede reutilizarse
- Dispositivo verificado en 2FA recordado por 12 horas

**Aplica a**:
- RF-003 (Inicio de sesión)
- RF-007 (Recuperación de contraseña)

**Estándar/Norma**:

- ISO/IEC 27001
- OWASP Session Management Cheat Sheet

**Método de Verificación**:
- Iniciar sesión y verificar que el token expira a los 60 minutos
- Permanecer inactivo 14 minutos y verificar que aparece el aviso y que a los 15 se cierra la sesión
- Cerrar sesión e intentar reutilizar el token: debe ser rechazado
