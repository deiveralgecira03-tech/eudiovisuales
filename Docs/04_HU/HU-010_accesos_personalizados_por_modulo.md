# HU-010 — Accesos Personalizados por Módulo

## Identificación

| Campo | Valor |
|---|---|
| ID | HU-010 |
| Título | Accesos Personalizados por Módulo |
| Prioridad | Media |
| Estado | Completado |
| RF asociado | RF-010 |

---

## Historia

*Como* Administrador o Director,
*quiero* restringir a una persona concreta el acceso a un módulo del proyecto,
*para* proteger información sensible sin crear un rol nuevo ni afectar al resto del equipo.

## Criterios de Aceptación

- Puedo elegir persona, módulo y nivel (Sin acceso, Ver, Comentar, Editar, Administrar).
- El sistema solo acepta niveles iguales o inferiores al que el rol de esa persona ya tiene.
- Con "Sin acceso", el módulo desaparece del menú de esa persona.
- Puedo eliminar la excepción para volver al nivel por defecto del rol.
