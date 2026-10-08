# CU012 — Visualizar Guion y Comentar Escenas

## Identificación

| Campo | Valor |
|---|---|
| ID | CU012 |
| Título | Visualizar Guion y Comentar Escenas |
| Módulo | Módulo 4: Gestión de Guiones |
| Actor primario | Todos los usuarios con acceso al módulo |
| Frecuencia | Alta |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Todos los usuarios con acceso al módulo Guión
- **Secundario:** Sistema de almacenamiento de archivos

#### Descripción

Permite ver el guion en un visor de PDF dentro de la aplicación, con navegación por páginas y zoom, y descargarlo con marca de agua si el rol tiene permiso. En la pantalla de cada escena, quienes tienen permiso registran comentarios.

#### Precondiciones

- Guion con archivo PDF subido
- Usuario con acceso al módulo Guión

#### Postcondiciones

- Guion visualizado
- Comentarios guardados en la escena
- Descarga identificada con la marca de agua

#### Flujo Principal

1. Usuario abre Guión y selecciona un guion
2. Sistema muestra el PDF en el visor
3. Usuario navega por las páginas y hace zoom
4. Usuario abre una escena y, si tiene permiso de comentar, escribe un comentario
5. Sistema guarda el comentario

#### Flujos Alternativos

**FA-001: Descargar guion** : Usuario con permiso de descarga elige "Descargar" → Sistema entrega el PDF con marca de agua

#### Flujos Excepcionales

**FE-001: No se puede abrir el PDF** : Sistema muestra un error y ofrece reintentar

**FE-002: Sin permiso de comentar** : El campo de comentarios queda en solo lectura

#### Frecuencia

Alta
