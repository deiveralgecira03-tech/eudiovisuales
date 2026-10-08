# RF-005 — Sistema de Roles y Permisos Granulares (RBAC)

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-005 |
| Título | Sistema de Roles y Permisos Granulares (RBAC) |
| Módulo | Autenticación y Gestión de Usuarios |
| Prioridad | Crítica |
| Estado | Pendiente |
| RNF asociados | RNF-001 |

---

**Descripción**: El sistema debe controlar qué puede hacer cada persona dentro de un proyecto mediante cinco roles fijos (Administrador, Director, Jefe de Departamento, Onset y Usuario). Cada rol define una matriz de permisos aplicada en el servidor en cada endpoint; la interfaz oculta las acciones que el rol no puede ejecutar.

**Entradas**:

- Rol asignado a la persona en el proyecto (Administrador, Director, Jefe de Departamento, Onset, Usuario)
- Permiso requerido por la acción (por ejemplo: subir guiones, crear escenas, subir fotos, descargar archivos, comentar escenas, gestionar la papelera, publicar notificaciones)

**Proceso**:

- El rol se asigna al invitar a la persona al proyecto (RF-002) y solo lo cambian Administrador y Director.
- Cada petición al servidor valida el token y comprueba el permiso del rol antes de ejecutar la acción.
- Reglas principales:

        Administrador: control total; es el único que crea proyectos y elimina usuarios Administrador
        Director: mismo nivel que el Administrador, salvo crear proyectos y eliminar Administradores; además gestiona la papelera y publica notificaciones
        Jefe de Departamento: invita personal, sube y elimina fotos, descarga archivos, edita el desglose de su departamento, gestiona la papelera y publica notificaciones; no sube guiones ni crea escenas ni personajes
        Onset: ve el proyecto, sube fotos, las envía a la papelera y comenta escenas; no administra
        Usuario: solo lectura

- Si una persona intenta una acción sin permiso, el sistema responde con error de acceso denegado.
- El nivel de acceso por módulo de cada persona puede restringirse adicionalmente (RF-010).

**Salidas**:

- Acciones permitidas o rechazadas según el rol
- Interfaz adaptada al rol de la persona

**Precondiciones**:

- Usuario autenticado y asociado al proyecto con un rol

**Postcondiciones**:

- Ninguna acción se ejecuta sin el permiso correspondiente

**Actores**: Administrador, Director, Jefe de Departamento, Onset, Usuario

**Dependencias**:

- RF-002 (Registro de usuarios adicionales)
- RF-003 (Inicio de sesión)
