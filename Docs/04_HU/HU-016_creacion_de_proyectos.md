# HU-016 — Creación de Proyectos

## Identificación

| Campo | Valor |
|---|---|
| ID | HU-016 |
| Título | Creación de Proyectos |
| Prioridad | Crítica |
| Estado | Completado |
| RF asociado | RF-016 |

---

## Historia

*Como* Administrador Total,
*quiero* crear un nuevo proyecto con su información básica,
*para* tener un contenedor donde organizar todas las fotografías, guiones y el plan de rodaje de esa producción.

## Criterios de Aceptación

- Solo un Administrador Total puede crear proyectos, y el sistema valida que el nombre no esté duplicado.
- El proyecto queda creado en estado "Activo" con un ID único y su plan de rodaje listo para usar.
- El creador queda asignado automáticamente como Administrador Total del proyecto.
- La creación queda registrada en el log de auditoría.
