# HU-011 — Carga de Fotografías

## Identificación

| Campo | Valor |
|---|---|
| ID | HU-011 |
| Título | Carga de Fotografías |
| Prioridad | Crítica |
| Estado | Completado |
| RF asociado | RF-011 |

---

## Historia

*Como* Script (continuista),
*quiero* subir fotografías de continuidad desde mi celular o tablet completando los metadatos de escena, toma y personaje,
*para* dejar un registro visual confiable que evite errores de continuidad.

## Criterios de Aceptación

- El sistema exige completar proyecto, escena, toma, personaje, tipo de detalle y estado de continuidad antes de guardar.
- El sistema guarda la imagen en el almacenamiento junto con su tipo, personaje, descripción y notas.
- Si el archivo excede el tamaño permitido, se comprime automáticamente conservando calidad visual.
- Si no hay conexión, la fotografía se guarda localmente y se sincroniza automáticamente al reconectar.
- La subida queda registrada en el log de auditoría.
