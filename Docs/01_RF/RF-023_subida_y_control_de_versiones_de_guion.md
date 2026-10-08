# RF-023 — Subida y Control de Versiones de Guion

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-023 |
| Título | Subida y Control de Versiones de Guion |
| Módulo | Gestión de Guiones |
| Prioridad | Alta |
| Estado | Pendiente |
| RNF asociados | — |

---

**Descripción**: El sistema debe permitir subir el guion del proyecto en PDF y llevar el control de sus versiones mediante un número de versión, una fecha de emisión y un estado del guion.

**Entradas**:

- Archivo PDF del guion
- Nombre y descripción
- Número de versión (único)
- Fecha de emisión
- Estado: Borrador, Revisión, Aprobado, En Rodaje, Archivado

**Proceso**:

- Quien tenga permiso de subir guiones (Administrador o Director) crea el registro del guion y sube el PDF.
- El archivo se guarda en el almacenamiento de objetos (no en la base de datos); la base de datos conserva solo sus datos y la ruta.
- La pantalla Guión lista los guiones del proyecto con su versión, fecha y estado.
- El guion se puede editar (cambiar estado, descripción) o reemplazar su archivo; las versiones anteriores permanecen como registros separados.

**Salidas**:

- Guion almacenado y listado con su versión y estado

**Precondiciones**:

- Proyecto activo
- Archivo PDF válido

**Postcondiciones**:

- El guion queda disponible para visualización (RF-024) y segmentación (RF-026)

**Actores**: Administrador, Director

**Dependencias**:

- RF-016 (Creación de proyectos)
