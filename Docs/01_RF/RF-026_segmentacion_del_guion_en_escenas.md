# RF-026 — Segmentación del Guion en Escenas

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-026 |
| Título | Segmentación del Guion en Escenas |
| Módulo | Gestión de Guiones |
| Prioridad | Media |
| Estado | completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe analizar el PDF del guion con reglas de texto (expresiones regulares), sin usar inteligencia artificial, para proponer la lista de escenas y los personajes que intervienen, y así evitar capturarlos a mano.

**Entradas**:

- Guion con archivo PDF de texto (no escaneado como imagen)

**Proceso**:

- El usuario con permiso elige "Segmentar" sobre un guion.
- El sistema lee el texto de cada página y busca encabezados de escena con el formato estándar (por ejemplo "ESC 4. EXT. LUGAR - DÍA", "INT. LUGAR - NOCHE").
- Por cada encabezado propone una escena con número, modo de vista (INT/EXT), momento del día, ciudad, página y descripción, y los personajes detectados en sus intervenciones.
- El usuario revisa el resultado y puede editar, corregir o eliminar escenas y personajes.
- Si el guion tiene un formato muy irregular o está escaneado, el sistema avisa que el resultado puede ser incompleto y las escenas se capturan manualmente.

**Salidas**:

- Escenas y personajes propuestos para el proyecto

**Precondiciones**:

- Guion subido en PDF con texto seleccionable
- Usuario con permiso de crear escenas

**Postcondiciones**:

- Las escenas quedan creadas y vinculadas al guion de origen

**Actores**: Administrador, Director

**Dependencias**:

- RF-023 (Subida de guion)
- RF-027 (Desglose editable)
