# RF-034 — Modo Sincrónico: Captura sin Conexión y Sincronización en Celular y Tablet

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-034 |
| Título | Modo Sincrónico: Captura sin Conexión y Sincronización en Celular y Tablet |
| Módulo | Gestión de Fotografías de Continuidad |
| Prioridad | Alta |
| Estado | En Proceso |
| RNF asociados | — |

---

**Descripción**: El sistema debe permitir que, en la aplicación móvil (celular y tablet), el personal en set capture fotografías de continuidad sin conexión a internet y que estas se almacenen en el dispositivo y se sincronicen automáticamente con el servidor al recuperar la conexión, sin pérdida ni duplicación de datos.

**Entradas**:

- Fotografía capturada con la cámara o seleccionada desde la galería del dispositivo
- Metadatos de la fotografía (escena, personaje, etiquetas) según RF-011
- Estado de conexión del dispositivo (con conexión / sin conexión)
- Acción manual "Sincronizar ahora" (opcional)

**Proceso**:

- Detectar el estado de conexión del dispositivo
- Sin conexión: guardar la fotografía y sus metadatos en una cola local del dispositivo, con estado "Pendiente de sincronizar"
- Mostrar al usuario un indicador del modo sin conexión y la cantidad de elementos pendientes
- Al recuperar la conexión, subir automáticamente los elementos pendientes en el orden en que fueron capturados
- Validar en el servidor cada elemento (permisos, formato y tamaño) con las mismas reglas de RF-011
- Marcar cada elemento como "Sincronizado" o "Error de sincronización"
- Reintentar automáticamente los elementos con error y permitir el reintento manual
- Evitar duplicados si la subida se interrumpe y se reintenta
- Conservar el elemento en el dispositivo hasta que el servidor confirme la recepción

**Salidas**:

- Fotografías disponibles en el proyecto una vez sincronizadas
- Indicador de estado de sincronización por elemento (Pendiente / Sincronizado / Error)
- Contador de elementos pendientes
- Mensaje de resultado de la sincronización

**Precondiciones**:

- Usuario autenticado con permiso de carga de fotografías (RF-011)
- Sesión iniciada previamente en el dispositivo y proyecto seleccionado
- Aplicación utilizada en celular o tablet

**Postcondiciones**:

- Las fotografías capturadas sin conexión quedan registradas en el proyecto
- No se pierde ni se duplica ninguna captura

**Actores**:

- Personal en set con permiso de carga de fotografías
- Sistema

**Dependencias**:

- RF-011 (Carga de Fotografías)
- RF-005 (Roles y Permisos)
