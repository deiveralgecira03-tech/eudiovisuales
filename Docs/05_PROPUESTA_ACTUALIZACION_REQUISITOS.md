# Propuesta de actualización de RF / RNF / HU / CU frente al código real

Fuente: rama `yaya` del repositorio (último commit 2026-10-06), carpeta `Raccord_Codigo` (backend FastAPI + frontend Flutter). Solo se leyó; no se modificó nada del código ni de los requisitos. Esto es una **propuesta para aprobar** antes de editar.

Leyenda: **OK** = existe en el código · **Parcial** = existe distinto o incompleto · **No existe** = sin rastro en el código.

## 0. Hallazgos del código que condicionan todo

- No hay IA en el código. El parser de guiones (`script_parser.py`) usa expresiones regulares y lo dice explícitamente.
- El plan de rodaje (stripboard por días) cumple el papel de "calendario": no hay calendario de eventos aparte.
- "Notificaciones" es un tablón interno del proyecto (general o por departamentos, con foto opcional y contador de no leídas). No hay push, ni Firebase, ni canales, ni confirmación obligatoria de lectura.
- Modo offline: solo existe un **banner de "sin conexión"**. No hay cola local ni sincronización posterior.
- 2FA por correo está programado pero **apagado temporalmente** con un interruptor global.
- Bloqueo de capturas (`screen_protector`) está **pausado** (no compila en Android). Solo existe marca de agua en las descargas.
- No existe tabla ni endpoint de **auditoría/log** ni de **inventario**.
- El frontend Flutter también se despliega como **web** (nginx en Docker). Esto choca con lo escrito en RNF-032/REST-005 (web solo como página de ingreso).

## 1. Requisitos funcionales (38 actuales)

| RF | Estado en código | Propuesta |
|---|---|---|
| 001 Auto-registro primer admin | OK | Mantener |
| 002 Registro de usuarios por admin | OK (invitaciones) | Mantener |
| 003 Login con 2FA | Parcial (2FA apagado) | Mantener y marcar 2FA como pendiente de reactivar |
| 004 Notificaciones por email | OK (2FA, recuperación, bienvenida, contacto) | Mantener; acotar el texto a esos correos |
| 005 RBAC | OK (5 roles: Admin, Director, Jefe Depto, Onset, Usuario) | **Actualizar**: el doc habla de 7 niveles; el código usa 5 roles + accesos por módulo |
| 006 Contraseñas seguras | Parcial (solo largo mínimo 8) | Actualizar a lo que realmente se valida |
| 007 Recuperación de contraseña | OK | Mantener |
| 008 Perfil de usuario | OK (foto, datos, cambio de contraseña) | Mantener |
| 009 Log de auditoría | No existe | **Eliminar** (o confirmar que se hará) |
| 010 Carga de fotografías | OK (cámara/galería, tipo, personaje, notas) | Mantener |
| 011 Nomenclatura y versionado de fotos | No existe | **Eliminar** (o reducir a "tipo de foto") |
| 012 Búsqueda avanzada por filtros | Parcial (búsqueda de texto y agrupación por escena) | Actualizar al alcance real |
| **013 Comparación lado a lado** | No existe | **Eliminar** (pedido tuyo) |
| 014 Estados de continuidad | Parcial (estado de escena: Pendiente/En proceso/Finalizada) | Actualizar |
| 015 Marca de agua dinámica | Parcial (solo en descargas de PDF y fotos) | Actualizar: quitar "no removible" y "en pantalla" |
| 016 Papelera de fotos | OK (restaurar y borrado definitivo por rol) | Mantener |
| 017 Creación de proyectos | OK | Mantener |
| 018 Crear eventos de calendario | Parcial (días de rodaje en Plan de Rodaje) | Actualizar: renombrar a Plan de Rodaje |
| 019 Modificar eventos | Parcial (ídem, con reordenamiento y aviso al equipo) | Actualizar igual |
| 020 Desgloses de escena | OK | Mantener |
| 021 Notas personales privadas | No existe (hay comentarios de escena compartidos) | **Eliminar** |
| 022 Notificaciones push | Parcial (tablón interno; sin push ni Firebase) | **Actualizar**: reescribir como "Notificaciones del proyecto" |
| 023 Canales segmentados | Parcial (notificaciones por departamento) | Fusionar con 022 y eliminar como RF aparte |
| 024 Comunicados con lectura obligatoria | Parcial (hay "leída", no obligatoria) | Fusionar con 022 y eliminar como RF aparte |
| 025 Crew List | OK | Mantener |
| 026 Subida y versiones de guion | Parcial (sube PDF y guarda número de versión) | Actualizar |
| 027 Visualizar guion con protección | Parcial (visor PDF, descarga con marca y por permiso) | Actualizar: quitar protección avanzada |
| 028 Anotaciones colaborativas | Parcial (campo de comentarios por escena) | Actualizar |
| **029 Comparar versiones de guion** | No existe | **Eliminar** (pedido tuyo) |
| 030 Vinculación guion-continuidad | Parcial (el guion se segmenta en escenas y personajes por regex) | Reescribir como "Segmentación del guion en escenas" o eliminar |
| 031 Desglose editable | OK | Mantener (ya sin IA) |
| 032 Reporte preparación rodaje | Parcial (PDF de desglose y plan) | Fusionar con 034 o eliminar |
| 033 Informe de continuidad por escena | No existe | **Eliminar** |
| 034 Parte de rodaje diario | Parcial (PDF del plan de rodaje) | Actualizar; quitar "semi-automático" |
| 035 Listado de vestuario por personaje | No existe como reporte | **Eliminar** |
| 036 Checklist grabadas vs pendientes | OK (gráfica "Escenas por estado" en el dashboard) | Actualizar |
| 037 Reporte de auditoría | No existe | **Eliminar** (depende de 009) |
| 038 Inventario | No existe | **Eliminar** |

Resultado propuesto si apruebas todo: se eliminan 11 RF (009, 011, 013, 021, 023, 024, 029, 033, 035, 037, 038), 4 se reescriben/fusionan (022, 030, 032, 034) y el resto se actualiza o se mantiene.

## 2. Requisitos no funcionales (33 actuales)

| RNF | Propuesta |
|---|---|
| 004 Rate limiting login | OK en código. Mantener |
| 005 Complejidad de contraseña | Actualizar (solo se valida largo) |
| 011 Push en 30 s, 012 Confirmación de lectura | Reescribir para el tablón de notificaciones |
| 015 Bloqueo de capturas | **Eliminar** o dejar como futuro (hoy está pausado) |
| 016 Registro de auditoría | **Eliminar** (junto con RF-009) |
| 017 Política de sesiones | Actualizar: el código cierra por inactividad a los 15 min y el token dura 60 min |
| 018 Marca de agua irreemplazable | Actualizar igual que RF-015 |
| 019 2FA obligatoria | Actualizar: hoy está apagada |
| 021 Modo oscuro | OK (existe `theme_controller`). Mantener |
| 027 Offline con sincronización | **Actualizar**: solo hay aviso de sin conexión, o eliminar |
| 032 Compatibilidad web de ingreso | Actualizar: la app también corre como web |
| 033 Sincronización entre dispositivos | **Eliminar** (los datos viven en el servidor; no hay sincronización propia) |
| 001-003, 006-010, 013, 014, 020, 022-026, 028-031 | No verificables solo con el código (son métricas de rendimiento, backups, etc.). Mantener hasta tener pruebas |

## 3. Casos de uso (16 actuales)

| CU | Propuesta |
|---|---|
| 006 Visualizar y Comparar Fotografías | Renombrar a "Visualizar Fotografías" y quitar la comparación |
| 008 Notificar cambios de calendario | Reescribir sin push/FCM, con el tablón de notificaciones |
| 010 Comunicación por canales, 011 Comunicados | Fusionar en un solo CU "Gestionar Notificaciones del Proyecto" |
| 012 Notas personales en calendario | **Eliminar** |
| 015 Comparar versiones de guion | **Eliminar** |
| 016 Vincular guion con continuidad | Eliminar o reescribir como segmentación del guion |
| Resto (001-005, 007, 009, 013, 014) | Mantener y ajustar al código |

## 4. Historias de usuario

- Las HU de los RF eliminados se borran: HU-009, 011, 013, 021, 023, 037, 038, 033, 035 (HU-024, 029, 030 ya no existen en la carpeta).
- Estados que el código respalda y hoy figuran "Pendiente" (**por confirmar con el equipo**): HU-016 (papelera), HU-015 (marca de agua en descargas), HU-018 (plan de rodaje), HU-022 (notificaciones, parcial).
- HU "Completadas" cuyo RF se elimina o cambia: revisar HU-013.

## 5. Funcionalidades que existen en el código y no tienen RF (necesito tu OK antes de agregar cualquiera)

1. **Actores y Personajes** (fichas, fotos, cast por escena).
2. **Accesos por módulo** por usuario (anulan el rol base).
3. **Carga masiva** por CSV/JSON (escenas, personajes, actores, roles).
4. **Cierre de sesión por inactividad** (puede ir dentro de RNF-017).
5. **Landing page y formulario de contacto**.

## 6. Decisiones que necesito de ti

1. ¿Dejo los números actuales (con huecos) o renumero RF/HU/CU/RNF después de eliminar?
2. ¿Eliminas RF-009/037 (auditoría) y RF-038 (inventario), o los dejas como futuros?
3. ¿Fusiono 022/023/024 en un solo RF de Notificaciones?
4. ¿Agrego alguno de los 5 puntos de la sección 5?
