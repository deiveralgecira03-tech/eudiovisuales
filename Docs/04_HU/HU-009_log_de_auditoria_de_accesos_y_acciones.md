# HU-009 — Log de Auditoría de Accesos y Acciones

## Identificación

| Campo | Valor |
|---|---|
| ID | HU-009 |
| Título | Log de Auditoría de Accesos y Acciones |
| Prioridad | Alta |
| Estado | Pendiente |
| RF asociado | RF-009 |

---

## Historia

*Como* Administrador,
*quiero* que el sistema registre las acciones sensibles de autenticación, usuarios y roles, guiones y fotografías,
*para* poder investigar accesos sospechosos o una posible filtración de material confidencial.

## Criterios de Aceptación

- Se registran inicios de sesión (exitosos y fallidos), cambios de rol y acceso, subida, visualización y descarga de guiones, y subida, descarga y eliminación de fotografías.
- Cada registro incluye fecha y hora, usuario, acción, elemento, IP, dispositivo y resultado.
- Los registros no se pueden editar ni eliminar desde la aplicación.
- Los demás módulos (escenas, desglose, plan de rodaje, crew list) no se auditan.
