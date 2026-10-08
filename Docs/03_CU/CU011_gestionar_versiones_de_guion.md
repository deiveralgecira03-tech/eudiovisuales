# CU011 — Gestionar Versiones de Guion

## Identificación

| Campo | Valor |
|---|---|
| ID | CU011 |
| Título | Gestionar Versiones de Guion |
| Módulo | Módulo 4: Gestión de Guiones |
| Actor primario | Administrador, Director |
| Frecuencia | Media |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Administrador, Director
- **Secundario:** Sistema de almacenamiento de archivos

#### Descripción

Permite subir el guion en PDF y llevar su control mediante número de versión, fecha de emisión y estado (Borrador, Revisión, Aprobado, En Rodaje, Archivado). Las versiones se conservan como registros separados.

#### Precondiciones

- Proyecto activo
- Usuario con permiso de subir guiones
- Archivo PDF válido

#### Postcondiciones

- Guion guardado y listado con versión, fecha y estado

#### Flujo Principal

1. Usuario abre Guión y elige crear un guion
2. Usuario completa nombre, descripción, número de versión, fecha de emisión y estado
3. Usuario selecciona el PDF
4. Sistema guarda los datos y sube el archivo al almacenamiento
5. Sistema lista el guion con su versión y estado

#### Flujos Alternativos

**FA-001: Cambiar estado** : Usuario edita el guion y actualiza su estado

**FA-002: Eliminar guion** : Usuario con permiso lo elimina

#### Flujos Excepcionales

**FE-001: Número de versión repetido** : Sistema rechaza y pide otro número

**FE-002: Archivo no válido** : Sistema rechaza el archivo

#### Frecuencia

Media
