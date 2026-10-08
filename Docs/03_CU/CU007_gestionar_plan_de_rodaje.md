# CU007 — Gestionar Plan de Rodaje

## Identificación

| Campo | Valor |
|---|---|
| ID | CU007 |
| Título | Gestionar Plan de Rodaje |
| Módulo | Módulo 3: Planeación y Comunicación |
| Actor primario | Administrador, Director |
| Frecuencia | Alta |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Administrador, Director
- **Secundario:** Demás roles (consulta)

#### Descripción

Permite crear y modificar los días de rodaje del Plan de Rodaje (cronograma tipo stripboard): semana, día, horario, locación, notas y las escenas asignadas, con su orden dentro del día. Los cambios pueden notificarse al equipo mediante el módulo de Notificaciones. El plan se puede descargar en PDF con marca de agua.

#### Precondiciones

- Proyecto activo
- Usuario con permiso de edición del Plan de Rodaje para crear o modificar
- Escenas creadas en el proyecto

#### Postcondiciones

- Días de rodaje y escenas ordenadas guardados
- Cambios registrados para notificar al equipo

#### Flujo Principal

1. Usuario abre Plan de Rodaje
2. Usuario crea un día con versión, semana, día de rodaje, horario, locación y notas
3. Usuario asigna escenas al día
4. Usuario ordena las escenas arrastrando y soltando
5. Sistema guarda el día y muestra el plan actualizado
6. Usuario elige "Notificar estos cambios al equipo" y el sistema publica la notificación (CU009)

#### Flujos Alternativos

**FA-001: Modificar un día** : Usuario edita datos, mueve escenas entre días o reordena → Sistema guarda y acumula los cambios sin notificar

**FA-002: Cierre de sesión por inactividad con cambios sin notificar** : Sistema los envía automáticamente como notificación

**FA-003: Descargar PDF** : Usuario con permiso de descarga elige "Descargar plan de rodaje (PDF)" → Sistema genera el PDF con marca de agua

#### Flujos Excepcionales

**FE-001: Sin permiso de edición** : Usuario sin permiso intenta modificar → Sistema muestra acceso denegado

**FE-002: Error de conexión** : La petición falla → Sistema muestra el error y conserva los datos en pantalla

#### Frecuencia

Alta
