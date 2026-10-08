# CU006 — Visualizar Fotografías

## Identificación

| Campo | Valor |
|---|---|
| ID | CU006 |
| Título | Visualizar Fotografías |
| Módulo | Módulo 2: Continuidad Visual |
| Actor primario | Todos los usuarios autorizados según rol |
| Frecuencia | Alta |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Todos los usuarios autorizados según rol
- **Secundario:** Sistema de almacenamiento de imágenes

#### Descripción

Permite a los usuarios con acceso a la Galería ver una fotografía de continuidad en grande, con navegación secuencial (anterior/siguiente) dentro de la galería actual y sus datos al lado: escena, tipo de foto, personaje, descripción y notas de continuidad. Quienes tienen permiso pueden editar esos datos, descargar la foto con marca de agua o enviarla a la papelera.

#### Precondiciones

- Usuario autenticado con acceso al módulo Galería
- La fotografía existe y no está en la papelera
- Almacenamiento accesible

#### Postcondiciones

- La foto se muestra con sus datos
- Si el usuario con permiso edita los datos, quedan guardados
- Si descarga, el archivo lleva marca de agua con su nombre y fecha

#### Flujo Principal

1. Usuario hace clic en una fotografía de la galería
2. Sistema carga la imagen desde el almacenamiento
3. Sistema muestra la imagen en el visor con sus datos (escena, tipo, personaje, descripción, notas)
4. Usuario navega con las flechas anterior/siguiente por las fotos de la galería actual
5. Usuario con permiso edita los datos o descarga la foto (con marca de agua) o la envía a la papelera

#### Flujos Alternativos

**FA-001: Descarga masiva** : Usuario con permiso de descarga selecciona varias fotos en la galería (hasta el máximo permitido) → Clic "Descargar" → Sistema entrega cada foto con marca de agua

**FA-002: Edición de datos** : Usuario con permiso de subir fotos modifica personaje, descripción o notas → Sistema guarda los cambios

#### Flujos Excepcionales

**FE-001: Imagen no disponible** : Sistema intenta cargar la foto → Almacenamiento no responde → Muestra "No se pudo cargar la imagen"

**FE-002: Marca de agua no aplicable** : El archivo no es una imagen válida → Sistema descarga el original sin marca

#### Frecuencia

Alta
