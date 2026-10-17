# RF-011 — Carga de Fotografías

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-011 |
| Título | Carga de Fotografías |
| Módulo | Gestión de Fotografías de Continuidad |
| Prioridad | Crítica |
| Estado | Completado |
| RNF asociados | RNF-006, RNF-007, RNF-009, RNF-017, RNF-019, RNF-026 |

---

**Descripción**: El sistema debe permitir a los usuarios autorizados subir fotografías de continuidad asociadas a una escena, tomándolas con la cámara del dispositivo o eligiéndolas de la galería o los archivos, y completando los datos de la foto.

**Entradas**:

- Archivo de imagen (cámara, galería o selector de archivos)
- Escena a la que pertenece la foto
- Tipo de foto: Locación, Propuesta, Prueba o En Rodaje
- Personaje (código, por ejemplo P001; opcional)
- Descripción (texto libre, opcional)
- Notas de continuidad (texto libre, opcional)

**Proceso**:

- Validar que el usuario tenga permiso de subir fotografías (Administrador, Director, Jefe de Departamento u Onset).
- Validar que el archivo sea una imagen y que no supere el tamaño máximo permitido.
- Guardar la imagen en el almacenamiento de objetos (bucket de imágenes) y sus datos en la base de datos, con la fecha de subida.
- Mostrar la foto en la galería de la escena y en la galería del proyecto.
- Permitir editar descripción, notas, personaje y tipo después de subida, a quien tenga permiso.
- Registrar la subida en el log de auditoría (RF-009).

**Salidas**:

- Fotografía almacenada y visible en la galería
- Datos de la foto guardados
- Mensaje de confirmación

**Precondiciones**:

- Usuario autenticado con permiso de subir fotografías
- La escena existe en el proyecto activo

**Postcondiciones**:

- La foto queda disponible para búsqueda (RF-012) y visualización según el acceso de cada rol

**Actores**: Administrador, Director, Jefe de Departamento, Onset

**Dependencias**:

- RF-005 (Roles y permisos)
- RF-009 (Log de auditoría)
- RF-027 (Desglose editable, de donde provienen las escenas)
