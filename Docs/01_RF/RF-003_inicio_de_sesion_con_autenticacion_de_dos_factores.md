# RF-003 — Inicio de Sesión con Autenticación de Dos Factores

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-003 |
| Título | Inicio de Sesión con Autenticación de Dos Factores |
| Módulo | Autenticación y Gestión de Usuarios |
| Prioridad | Crítica |
| Estado | Completado |
| RNF asociados | RNF-001, RNF-002, RNF-003, RNF-004, RNF-016, RNF-018 |

---

**Descripción**: El sistema debe permitir a usuarios registrados iniciar sesión validando credenciales (email + contraseña) y requiriendo posteriormente autenticación de dos factores (2FA) mediante un código de un solo uso enviado al correo del usuario. El segundo factor está implementado, pero su activación global está suspendida temporalmente y debe reactivarse antes de producción (ver RNF-018).


**Entradas**:
- Email del usuario
- Contraseña
- Código 2FA de 6 dígitos
- Identificador del dispositivo

**Proceso**:
- Validar email y contraseña contra base de datos
- Si las credenciales son incorrectas: registrar intento fallido y mostrar error genérico ("Email o contraseña incorrectos")
- Si 3 intentos fallidos consecutivos: bloquear cuenta temporalmente (15 minutos)
- Enviar código al correo del usuario
- Validar código ingresado (válido por 5 minutos)
- Si código es incorrecto 3 veces: bloquear cuenta temporalmente (15 minutos)
- Registrar acceso exitoso en log de auditoría (timestamp, IP origen, dispositivo, resultado)

**Salidas**:
- Redirección a página principal según rol del usuario
- Registro en log de auditoría: timestamp, IP origen, dispositivo, resultado

**Precondiciones**:
- Usuario debe estar registrado en el sistema (RF-001, o RF-002)
- Usuario debe estar en estado "Activo"
- Usuario debe haber activado su cuenta (si fue registrado por RF-002)

**Postcondiciones**:

- Usuario puede acceder a módulos según su rol
- Registro de acceso exitoso en tabla LOG de auditoría

**Actores**: Todos los usuarios registrados del sistema

Dependencias:

RF-001 o RF-002 (Usuario debe estar registrado)
