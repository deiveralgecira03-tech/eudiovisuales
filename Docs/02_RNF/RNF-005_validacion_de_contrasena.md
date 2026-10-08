# RNF-005 — Validación de Contraseña

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-005 |
| Título | Validación de Contraseña |
| Categoría | Seguridad / Usabilidad |
| Prioridad | Media |
| Estado | Pendiente |
| RF asociados | RF-001, RF-002, RF-006, RF-007 |

---

**Descripción**: El sistema debe validar la contraseña al registrarla, cambiarla o recuperarla, rechazándola de inmediato con un mensaje claro cuando no cumple la política de RF-006.

**Métrica**:
- Longitud mínima de 8 caracteres y máxima de 72
- Rechazo con mensaje de error claro, sin crear ni modificar la cuenta
- La contraseña nunca se devuelve en las respuestas del servidor

**Aplica a**:

- RF-001 (Auto-registro)
- RF-002 (Registro de usuarios adicionales)
- RF-006 (Política de contraseñas)
- RF-007 (Recuperación de contraseña)

**Estándar/Norma**:
- OWASP Password Storage Cheat Sheet
- ISO/IEC 27001

**Método de Verificación**:
- Intentar registrar y cambiar contraseñas de 7 y 8 caracteres: la de 7 debe rechazarse
- Verificar que ninguna respuesta de la API incluye la contraseña ni su hash
