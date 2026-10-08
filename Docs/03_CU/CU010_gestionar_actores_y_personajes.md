# CU010 — Gestionar Actores y Personajes

## Identificación

| Campo | Valor |
|---|---|
| ID | CU010 |
| Título | Gestionar Actores y Personajes |
| Módulo | Módulo 3: Planeación y Comunicación |
| Actor primario | Administrador, Director |
| Frecuencia | Media |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Administrador, Director
- **Secundario:** Demás roles (consulta), Sistema de almacenamiento de imágenes

#### Descripción

Permite registrar los personajes del proyecto y los actores que los interpretan, con su ficha técnica, contacto y estado de casting, y asignar personajes a cada escena (cast por escena).

#### Precondiciones

- Proyecto activo
- Usuario con permiso de creación de personajes para editar

#### Postcondiciones

- Personajes, actores y cast por escena guardados

#### Flujo Principal

1. Usuario abre Personajes y crea un personaje (nombre, edad, código)
2. Usuario abre Actores y registra la ficha del actor (medidas, características, contacto, casting) y lo asocia al personaje
3. Usuario sube la foto normal y la foto caracterizado del actor
4. Usuario abre una escena y agrega los personajes que aparecen (autocompletado)
5. Sistema guarda y muestra la información en Cast List, Personajes y Escenas

#### Flujos Alternativos

**FA-001: Carga masiva** : Usuario sube un CSV/JSON de personajes o actores (CU014)

**FA-002: Quitar personaje de una escena** : Usuario lo retira del cast de la escena

#### Flujos Excepcionales

**FE-001: Código de personaje duplicado** : Sistema rechaza el registro y pide otro código

**FE-002: Sin permiso** : Usuario sin permiso solo ve la información

#### Frecuencia

Media
