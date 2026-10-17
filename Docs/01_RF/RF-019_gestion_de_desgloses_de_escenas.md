# RF-019 — Gestión de Desgloses de Escenas

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-019 |
| Título | Gestión de Desgloses de Escenas |
| Módulo | Gestión de Calendario y Planeación |
| Prioridad | Alta |
| Estado | Completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe permitir a Primera AD y Script crear y modificar desgloses detallados por escena individual con información técnica y de producción que se muestra junto a la escena en el Plan de Rodaje.

**Entradas**:

- Número de escena (número entero, único por proyecto)
- Descripción narrativa breve (texto, máx 500 caracteres)
- Interior / Exterior (selección única)
- Día / Noche (selección única)
- Personajes con diálogo (selección múltiple)
- Personajes secundarios / Extras (texto libre, máx 300 caracteres)
- Vestuario requerido por personaje con estado (tabla):

        Personaje
        Descripción de vestuario
        Estado requerido: Limpio / Sucio / Roto / Mojado / Otro
- Maquillaje especial requerido (texto libre, máx 300 caracteres)
- Utilería hero (objetos clave en acción) (texto libre, máx 300 caracteres)
- Vehículos (texto libre, máx 200 caracteres, opcional)
- Efectos especiales (texto libre, máx 300 caracteres, opcional)
- Armas / Elementos regulados (texto libre, máx 200 caracteres, opcional)
-Notas de producción (texto libre, máx 500 caracteres)

**Proceso**:
- Validar que usuario sea Primera AD o Script
- Validar que número de escena no esté duplicado en el proyecto
- Crear registro de desglose en base de datos vinculado al proyecto
- Si la escena ya está asignada a un día del Plan de Rodaje (RF-017): el desglose se muestra con la escena en el plan
- Permitir edición posterior del desglose (solo Primera AD y Script)
- Vincular automáticamente con fotografías de continuidad (RF-011) de la misma escena mediante número de escena
- Mostrar el desglose de la escena al consultarla en el Plan de Rodaje
- Registrar creación/modificación en log de auditoría

**Salidas**:
- Desglose de escena creado en base de datos
- Información visible junto a la escena en el Plan de Rodaje
- Vinculación bidireccional con fotografías de continuidad
- Registro en log de auditoría

**Precondiciones**:
- Usuario debe ser Primera AD o Script
- Proyecto debe estar activo

**Postcondiciones**:
- Desglose disponible para consulta por todos los departamentos
- Información se refleja en el Plan de Rodaje

**Actores**:
- Primera Ayudante de Dirección
- Script (Continuista)

**Dependencias**:
- RF-016 (Proyecto debe existir)
- RF-017 (Plan de Rodaje)
- RF-011 (Puede vincularse con fotografías de continuidad)
