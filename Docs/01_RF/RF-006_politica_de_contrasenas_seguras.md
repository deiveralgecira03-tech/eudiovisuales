# RF-006 — Política de Contraseñas Seguras

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-006 |
| Título | Política de Contraseñas Seguras |
| Módulo | Autenticación y Gestión de Usuarios |
| Prioridad | Alta |
| Estado | Pendiente |
| RNF asociados | RNF-005 |

---

**Descripción**: El sistema debe exigir contraseñas con una longitud mínima y almacenarlas siempre cifradas con hash, sin guardar nunca el texto original.

**Entradas**:

- Contraseña nueva (en registro, cambio de contraseña o recuperación)

**Proceso**:

- Validar que la contraseña tenga entre 8 y 72 caracteres.
- Rechazar la operación con un mensaje claro si no cumple.
- Guardar únicamente el hash bcrypt de la contraseña.
- Al cambiar la contraseña desde el perfil, exigir la contraseña actual.

**Salidas**:

- Contraseña aceptada y almacenada con hash, o mensaje de error de validación

**Precondiciones**:

- Estar registrando una cuenta, cambiando o recuperando la contraseña

**Postcondiciones**:

- La contraseña nunca se almacena ni se devuelve en texto plano

**Actores**: Todos los usuarios

**Dependencias**:

- RF-001 (Auto-registro)
- RF-002 (Registro de usuarios adicionales)
- RF-007 (Recuperación de contraseña)
- RF-008 (Perfil de usuario)
