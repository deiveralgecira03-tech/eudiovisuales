# RNF-012 — Confirmación de Lectura de Notificaciones

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-012 |
| Título | Confirmación de Lectura de Notificaciones |
| Categoría | Funcionalidad |
| Prioridad | Media |
| Estado | Pendiente |
| RF asociados | RF-020 |

---

**Descripción**: El sistema debe registrar, por usuario, la fecha y hora en que abrió cada notificación, para calcular el contador de no leídas y saber qué leyó cada persona.

**Métrica**:
- 100% de notificaciones con registro de lectura por usuario
- Fecha y hora de lectura con precisión de segundos
- El contador de no leídas se actualiza al abrir la notificación

**Aplica a**:
- RF-020 (Notificaciones del proyecto)

**Estándar/Norma**: Funcionalidad estándar de sistemas de mensajería

**Método de Verificación**:
- Publicar 10 notificaciones a un equipo de 5 usuarios
- Abrir algunas con cada usuario
- Verificar que el registro de lectura y el contador reflejan exactamente lo abierto
