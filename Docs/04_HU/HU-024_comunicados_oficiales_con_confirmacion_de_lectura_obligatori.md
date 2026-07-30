# HU-024 — Comunicados Oficiales con Confirmación de Lectura Obligatoria

## Identificación

| Campo | Valor |
|---|---|
| ID | HU-024 |
| Título | Comunicados Oficiales con Confirmación de Lectura Obligatoria |
| Prioridad | Media |
| Estado | Pendiente |
| RF asociado | RF-024 |

---

## Historia

*Como* Productor de Línea,
*quiero* enviar comunicados oficiales que exijan confirmación de lectura,
*para* asegurarme de que toda la producción se enteró de una decisión importante.

## Criterios de Aceptación

- Solo Primera AD, Director o Productor de Línea pueden publicar un comunicado oficial.
- El comunicado se fija en la parte superior del canal general hasta que cada destinatario confirme la lectura.
- El sistema genera un reporte con quién confirmó lectura y quién no, con su respectivo timestamp.
- El envío del comunicado genera una notificación push de prioridad crítica a todos los destinatarios.
