# HU-026 — Segmentación del Guion en Escenas

## Identificación

| Campo | Valor |
|---|---|
| ID | HU-026 |
| Título | Segmentación del Guion en Escenas |
| Prioridad | Media |
| Estado | Completado |
| RF asociado | RF-026 |

---

## Historia

*Como* Primera Ayudante de Dirección,
*quiero* que el sistema proponga las escenas y personajes a partir del PDF del guion,
*para* no tener que capturarlos uno por uno.

## Criterios de Aceptación

- El sistema detecta encabezados de escena (INT./EXT., lugar, momento del día) con reglas de texto, sin inteligencia artificial.
- Propone número, modo, momento, ciudad, página y personajes de cada escena.
- Puedo revisar, editar o eliminar lo propuesto antes de confirmarlo.
- Si el PDF no tiene texto o su formato es irregular, el sistema avisa que el resultado puede ser incompleto.
