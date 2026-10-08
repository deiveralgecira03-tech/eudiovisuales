# RF-025 — Comentarios por Escena

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-025 |
| Título | Comentarios por Escena |
| Módulo | Gestión de Guiones |
| Prioridad | Alta |
| Estado | Pendiente |
| RNF asociados | — |

---

**Descripción**: El sistema debe permitir que el equipo con permiso registre comentarios en cada escena para dejar anotaciones de continuidad y producción.

**Entradas**:

- Escena
- Texto del comentario

**Proceso**:

- Desde la pantalla de edición de la escena, quien tenga permiso de comentar (Administrador, Director y Onset) escribe el comentario.
- El comentario se guarda en la escena y es visible para quienes pueden ver la escena.
- Los demás roles solo leen los comentarios.

**Salidas**:

- Comentario guardado en la escena

**Precondiciones**:

- La escena existe
- Usuario con permiso de comentar escenas

**Postcondiciones**:

- Las anotaciones quedan disponibles para el equipo junto a la escena

**Actores**: Administrador, Director, Onset (escriben); demás roles (leen)

**Dependencias**:

- RF-027 (Desglose editable)
