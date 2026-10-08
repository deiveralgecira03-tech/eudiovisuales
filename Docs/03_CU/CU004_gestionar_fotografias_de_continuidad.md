# CU004 — Gestionar Fotografías de Continuidad

## Identificación

| Campo | Valor |
|---|---|
| ID | CU004 |
| Título | Gestionar Fotografías de Continuidad |
| Módulo | Módulo 2: Continuidad Visual |
| Actor primario | Administrador, Director, Jefe de Departamento, Onset |
| Frecuencia | Alta |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Administrador, Director, Jefe de Departamento, Onset
- **Secundario:** Sistema de almacenamiento de imágenes

#### Descripción

Permite subir fotografías de continuidad a una escena (con la cámara o desde archivos), editar sus datos, enviarlas a la papelera y, a quienes tienen permiso, restaurarlas o eliminarlas definitivamente.

#### Precondiciones

- Usuario autenticado con permiso de subir fotografías
- La escena existe

#### Postcondiciones

- Foto almacenada con sus datos y visible en la galería
- Fotos eliminadas quedan en la papelera hasta su restauración o eliminación definitiva

#### Flujo Principal (Subir)

1. Usuario abre la escena o la Galería
2. Usuario toma una foto o selecciona un archivo
3. Usuario indica tipo de foto (Locación, Propuesta, Prueba, En Rodaje), personaje, descripción y notas
4. Sistema valida el archivo y lo guarda en el almacenamiento
5. Sistema muestra la foto en la galería

#### Flujos Alternativos

**FA-001: Enviar a la papelera** : Usuario con permiso (Director, Jefe de Departamento y Onset; el Administrador no) elimina la foto → Sistema la mueve a la papelera

**FA-002: Restaurar o eliminar definitivamente** : Director o Jefe de Departamento abren la Papelera → Restauran la foto o la eliminan para siempre (el Administrador solo puede verla)

**FA-003: Editar datos** : Usuario con permiso modifica descripción, notas, personaje o tipo

#### Flujos Excepcionales

**FE-001: Archivo no válido o demasiado grande** : Sistema rechaza el archivo

**FE-002: Sin permiso** : Sistema muestra acceso denegado

#### Frecuencia

Alta
