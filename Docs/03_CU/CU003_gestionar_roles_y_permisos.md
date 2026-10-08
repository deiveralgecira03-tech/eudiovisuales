# CU003 — Gestionar Roles y Permisos

## Identificación

| Campo | Valor |
|---|---|
| ID | CU003 |
| Título | Gestionar Roles y Permisos |
| Módulo | Módulo 1: Gestión de Usuarios y Seguridad |
| Actor primario | Administrador, Director |
| Frecuencia | Media |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Administrador, Director
- **Secundario:** Sistema de correo

#### Descripción

Permite asignar y modificar el rol de cada persona del proyecto entre los cinco roles fijos (Administrador, Director, Jefe de Departamento, Onset y Usuario) y, adicionalmente, restringir el acceso de una persona a un módulo concreto (Sin acceso, Ver, Comentar, Editar, Administrar) mediante "Personalizar accesos". La restricción solo puede reducir lo que el rol ya permite.

#### Precondiciones

- Usuario autenticado con rol Administrador o Director
- La persona pertenece al proyecto

#### Postcondiciones

- Rol o acceso por módulo actualizado
- El menú y las pantallas de la persona reflejan su acceso efectivo

#### Flujo Principal

1. Usuario abre Roles del equipo
2. Usuario selecciona a la persona y su nuevo rol
3. Sistema valida que el cambio esté permitido (por ejemplo, un Director no puede eliminar Administradores)
4. Sistema guarda el cambio

#### Flujos Alternativos

**FA-001: Personalizar accesos** : Usuario elige un módulo y un nivel menor al del rol → Sistema guarda la excepción → El módulo se oculta o queda limitado para esa persona

**FA-002: Quitar la excepción** : Usuario elimina la restricción → La persona vuelve al nivel por defecto de su rol

#### Flujos Excepcionales

**FE-001: Nivel superior al del rol** : Sistema rechaza la excepción

**FE-002: Sin permiso** : Usuario con otro rol → Sistema muestra acceso denegado

#### Frecuencia

Media
