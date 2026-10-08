# RF-012 — Búsqueda y Filtrado de Fotografías

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-012 |
| Título | Búsqueda y Filtrado de Fotografías |
| Módulo | Gestión de Fotografías de Continuidad |
| Prioridad | Crítica |
| Estado | Pendiente |
| RNF asociados | RNF-008, RNF-019 |

---

**Descripción**: El sistema debe permitir encontrar rápidamente fotografías de continuidad mediante una caja de búsqueda y la agrupación por escena en la galería del proyecto.

**Entradas**:

- Texto de búsqueda (coincide con escena, personaje, tipo de foto, descripción y notas de continuidad)

**Proceso**:

- La galería agrupa las fotografías por escena, ordenadas numéricamente.
- Al escribir en la caja de búsqueda, se filtran en pantalla las fotos cuyos campos contienen el texto.
- Si ninguna foto coincide, se muestra el mensaje "Ninguna foto coincide con la búsqueda".
- Los resultados se paginan.
- Solo se listan fotos no eliminadas (las de la papelera se ven en RF-015).

**Salidas**:

- Lista de fotografías coincidentes, agrupadas por escena

**Precondiciones**:

- Usuario autenticado con acceso al módulo Galería

**Postcondiciones**:

- Ninguna (consulta de solo lectura)

**Actores**: Todos los usuarios con acceso a la Galería

**Dependencias**:

- RF-011 (Carga de fotografías)
