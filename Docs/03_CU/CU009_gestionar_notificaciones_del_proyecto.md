# CU009 — Gestionar Notificaciones del Proyecto

## Identificación

| Campo | Valor |
|---|---|
| ID | CU009 |
| Título | Gestionar Notificaciones del Proyecto |
| Módulo | Módulo 3: Planeación y Comunicación |
| Actor primario | Director, Jefe de Departamento (publican); todos (leen) |
| Frecuencia | Alta |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Director, Jefe de Departamento (publican)
- **Secundario:** Todos los usuarios del proyecto (leen), Sistema de almacenamiento de imágenes

#### Descripción

Permite publicar avisos para todo el equipo o para uno o más departamentos, con una foto opcional, y que cada persona consulte sus notificaciones con un contador de no leídas. También se generan notificaciones automáticas cuando se comunican cambios del Plan de Rodaje. Reemplaza a los antiguos casos de uso de notificar cambios de calendario, comunicación por canales y comunicados generales.

#### Precondiciones

- Proyecto activo
- Para publicar: rol Director o Jefe de Departamento

#### Postcondiciones

- Notificación visible para el alcance elegido
- Lectura registrada por usuario al abrirla

#### Flujo Principal

1. Usuario con permiso abre Notificaciones y escribe el texto
2. Usuario elige el alcance: general o específica (uno o varios departamentos) y adjunta una foto si desea
3. Sistema publica la notificación
4. Los destinatarios ven el contador de no leídas en la campana al abrir o actualizar la app
5. Destinatario abre la notificación y el sistema registra la lectura

#### Flujos Alternativos

**FA-001: Notificación automática del plan de rodaje** : Usuario elige "Notificar estos cambios al equipo" en el Plan de Rodaje → Sistema publica un resumen de cambios (CU007)

**FA-002: Consultar notificaciones anteriores** : Usuario abre la lista paginada de notificaciones del proyecto

#### Flujos Excepcionales

**FE-001: Sin permiso para publicar** : Rol Administrador, Onset o Usuario intenta publicar → Sistema rechaza la acción

**FE-002: Departamento no seleccionado** : Alcance específico sin departamentos → Sistema pide elegir al menos uno

#### Frecuencia

Alta
