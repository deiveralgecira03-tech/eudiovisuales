# RF-010 — Accesos Personalizados por Módulo

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-010 |
| Título | Accesos Personalizados por Módulo |
| Módulo | Autenticación y Gestión de Usuarios |
| Prioridad | Media |
| Estado | Completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe permitir al Administrador y al Director restringir, para una persona concreta y en un proyecto, el nivel de acceso a un módulo específico, sin crear un rol nuevo. La excepción solo puede reducir lo que el rol ya permite, nunca ampliarlo.

**Entradas**:

- Persona del proyecto
- Módulo: Guión, Escenas, Desglose, Plan de Rodaje, Personajes, Cast List, Galería, Crew List, Roles
- Nivel: Sin acceso, Ver, Comentar, Editar, Administrar

**Proceso**:

- El Administrador o Director abre "Personalizar accesos" sobre una persona del equipo.
- Elige el módulo y el nivel deseado; el sistema solo acepta niveles iguales o inferiores al que el rol de esa persona ya tiene en ese módulo.
- El servidor aplica la restricción en el listado y en las operaciones del módulo; con "Sin acceso", el módulo desaparece del menú de esa persona.
- Se puede eliminar la excepción para volver al nivel por defecto del rol.

**Salidas**:

- Excepciones de acceso guardadas por persona, proyecto y módulo
- Menú y pantallas adaptados al acceso efectivo

**Precondiciones**:

- Quien configura debe ser Administrador o Director
- La persona debe pertenecer al proyecto

**Postcondiciones**:

- El acceso efectivo = el menor entre el nivel del rol y la excepción

**Actores**: Administrador, Director

**Dependencias**:

- RF-005 (Roles y permisos)
