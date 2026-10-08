# CU013 — Segmentar Guion en Escenas

## Identificación

| Campo | Valor |
|---|---|
| ID | CU013 |
| Título | Segmentar Guion en Escenas |
| Módulo | Módulo 4: Gestión de Guiones |
| Actor primario | Administrador, Director |
| Frecuencia | Media |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Administrador, Director
- **Secundario:** Sistema de almacenamiento de archivos

#### Descripción

Permite proponer las escenas y los personajes de un guion a partir de su PDF mediante reglas de texto (expresiones regulares), sin inteligencia artificial. El usuario revisa y corrige el resultado.

#### Precondiciones

- Guion subido en PDF con texto seleccionable (no escaneado)
- Usuario con permiso de crear escenas

#### Postcondiciones

- Escenas y personajes creados y vinculados al guion

#### Flujo Principal

1. Usuario abre Guión y elige "Segmentar" sobre un guion
2. Sistema lee el texto del PDF y detecta los encabezados de escena (INT./EXT., lugar, momento del día)
3. Sistema propone cada escena con su número, modo, momento, ciudad, página y personajes
4. Usuario revisa y confirma
5. Sistema crea las escenas y personajes en el proyecto

#### Flujos Alternativos

**FA-001: Corregir resultado** : Usuario edita o elimina escenas y personajes propuestos

#### Flujos Excepcionales

**FE-001: PDF sin texto o formato irregular** : Sistema avisa que el resultado puede ser incompleto → Usuario captura manualmente

#### Frecuencia

Media
