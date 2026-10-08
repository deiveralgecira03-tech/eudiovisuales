# RNF-010 — Tiempo de Respuesta al Guardar un Día de Rodaje

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-010 |
| Título | Tiempo de Respuesta al Guardar un Día de Rodaje |
| Categoría | Rendimiento |
| Prioridad | Alta |
| Estado | Pendiente |
| RF asociados | RF-017, RF-018 |

---

**Descripción**: El sistema debe completar el guardado de un día de rodaje (creación o modificación) en el Plan de Rodaje en menos de 3 segundos desde que la persona hace clic en "Guardar".

**Métrica**:
- Tiempo total < 3 segundos (p95)
- Incluye: validación, guardado en base de datos y asignación de escenas
- No incluye la publicación de la notificación al equipo (RF-020), que se hace aparte

**Aplica a**:
- RF-017 (Creación de días de rodaje)
- RF-018 (Modificación del plan de rodaje)

**Estándar/Norma**: ISO/IEC 25010 - Eficiencia de desempeño

**Método de Verificación**:
- Crear 50 días de rodaje consecutivos con todos sus campos
- Medir el tiempo de respuesta de cada guardado
- Verificar que el p95 sea menor a 3 segundos
