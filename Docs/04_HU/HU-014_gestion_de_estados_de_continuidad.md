# HU-014 — Gestión de Estados de Continuidad

## Identificación

| Campo | Valor |
|---|---|
| ID | HU-014 |
| Título | Gestión de Estados de Continuidad |
| Prioridad | Alta |
| Estado | Pendiente |
| RF asociado | RF-014 |

---

## Historia

*Como* Script (continuista),
*quiero* marcar cada fotografía como OK, Pendiente o Error a Corregir,
*para* avisar de inmediato al departamento responsable cuando algo no coincide entre tomas.

## Criterios de Aceptación

- Solo el Script puede cambiar el estado de una fotografía.
- Si se marca "Error a Corregir", el sistema exige una descripción y notifica de forma urgente al jefe del departamento correspondiente.
- Si el estado pasa de "Error" a "OK", se envía una notificación de confirmación al departamento.
- Cada cambio de estado queda registrado en el log de auditoría.
