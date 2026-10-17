# RNF-018 — Autenticación de Dos Factores por Correo

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-018 |
| Título | Autenticación de Dos Factores por Correo |
| Categoría | Seguridad |
| Prioridad | Crítica |
| Estado | Completado |
| RF asociados | RF-003, RF-004 |

---

**Descripción**: El sistema debe poder exigir un segundo factor al iniciar sesión desde un dispositivo no verificado, mediante un código de un solo uso enviado al correo del usuario. La funcionalidad está implementada, pero su activación global está suspendida temporalmente mediante un interruptor y debe reactivarse antes de producción.

**Métrica**:
- Código de un solo uso enviado por correo, con vigencia de 10 minutos
- Dispositivo verificado recordado por 12 horas (no se vuelve a pedir el código en ese periodo)
- Cada paso del flujo (consultar, enviar, verificar) revalida el correo y la contraseña
- Código inválido o expirado rechazado con mensaje claro
- Mientras el interruptor global esté apagado, el sistema no solicita el segundo factor

**Aplica a**:

- RF-003 (Inicio de sesión con 2FA)
- RF-004 (Notificaciones por correo)

**Estándar/Norma**:
- NIST SP 800-63B (autenticación)
- ISO/IEC 27001

**Método de Verificación**:
- Con el interruptor encendido, iniciar sesión desde un dispositivo nuevo y verificar que se pide el código
- Probar código incorrecto y código vencido: ambos deben rechazarse
- Verificar que en el mismo dispositivo no se vuelve a pedir durante 12 horas
