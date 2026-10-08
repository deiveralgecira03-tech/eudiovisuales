# RNF-011 — Disponibilidad Oportuna de Notificaciones del Proyecto

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-011 |
| Título | Disponibilidad Oportuna de Notificaciones del Proyecto |
| Categoría | Rendimiento / Funcionalidad |
| Prioridad | Alta |
| Estado | Pendiente |
| RF asociados | RF-018, RF-020 |

---

**Descripción**: Una notificación publicada en el tablón del proyecto debe estar disponible para sus destinatarios en pocos segundos, de modo que al abrir o actualizar la aplicación la vean con su contador de no leídas actualizado.

**Métrica**:
- Notificación visible para los destinatarios en menos de 5 segundos desde que se publica (p90)
- Para equipos de hasta 50 usuarios
- Contador de no leídas correcto tras cada actualización

**Aplica a**:
- RF-020 (Notificaciones del proyecto)
- RF-018 (Modificación del plan de rodaje, como origen de notificaciones automáticas)

**Estándar/Norma**: ISO/IEC 25010 - Eficiencia de desempeño

**Método de Verificación**:
- Publicar una notificación general con un usuario autorizado
- Actualizar la aplicación en 10 cuentas distintas y registrar el tiempo hasta que aparece
- Verificar que p90 < 5 segundos y que el contador de no leídas coincide
