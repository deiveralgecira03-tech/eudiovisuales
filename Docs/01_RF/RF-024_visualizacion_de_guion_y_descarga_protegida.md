# RF-024 — Visualización de Guion y Descarga Protegida

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-024 |
| Título | Visualización de Guion y Descarga Protegida |
| Módulo | Gestión de Guiones |
| Prioridad | Crítica |
| Estado | Completado |
| RNF asociados | RNF-017 |

---

**Descripción**: El sistema debe permitir ver el guion dentro de la aplicación mediante un visor de PDF embebido, y descargarlo únicamente con marca de agua y solo si el rol tiene permiso.

**Entradas**:

- Guion a visualizar
- Usuario autenticado con acceso al módulo Guión

**Proceso**:

- El visor embebido muestra el PDF con navegación por páginas y zoom, sin salir de Raccord.
- El botón "Descargar" aparece solo para roles con permiso de descarga (Administrador, Director y Jefe de Departamento).
- La descarga aplica la marca de agua con nombre de usuario y fecha (RF-014).
- El visor puede ocultar el contenido a las personas sin acceso al módulo Guión (RF-010).

**Salidas**:

- Guion visualizado en pantalla
- PDF descargado con marca de agua, cuando corresponde

**Precondiciones**:

- Guion subido con archivo PDF
- Usuario con acceso al módulo Guión

**Postcondiciones**:

- La descarga queda identificada con el nombre de quien la realizó

**Actores**: Todos los usuarios con acceso al módulo (ver); Administrador, Director y Jefe de Departamento (descargar)

**Dependencias**:

- RF-014 (Marca de agua)
- RF-023 (Subida de guion)
