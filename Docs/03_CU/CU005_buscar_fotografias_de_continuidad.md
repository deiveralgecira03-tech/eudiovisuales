# CU005 — Buscar Fotografías de Continuidad

## Identificación

| Campo | Valor |
|---|---|
| ID | CU005 |
| Título | Buscar Fotografías de Continuidad |
| Módulo | Módulo 2: Continuidad Visual |
| Actor primario | Todos los usuarios autorizados |
| Frecuencia | Alta |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Todos los usuarios con acceso a la Galería

#### Descripción

Permite encontrar fotografías mediante una caja de búsqueda que filtra por escena, personaje, tipo de foto, descripción y notas, sobre una galería agrupada por escena y paginada.

#### Precondiciones

- Usuario autenticado con acceso al módulo Galería
- Existen fotografías en el proyecto

#### Postcondiciones

- Se muestran las fotos coincidentes agrupadas por escena

#### Flujo Principal

1. Usuario abre la Galería
2. Sistema muestra las fotos agrupadas por escena en orden numérico
3. Usuario escribe un texto en la caja de búsqueda
4. Sistema filtra las fotos cuyos campos contienen el texto
5. Usuario abre una foto (CU006)

#### Flujos Alternativos

**FA-001: Ver las fotos de una sola escena** : Usuario entra a la galería de esa escena

#### Flujos Excepcionales

**FE-001: Sin resultados** : Sistema muestra "Ninguna foto coincide con la búsqueda"

#### Frecuencia

Alta
