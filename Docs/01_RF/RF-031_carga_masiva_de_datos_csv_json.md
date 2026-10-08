# RF-031 — Carga Masiva de Datos (CSV/JSON)

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-031 |
| Título | Carga Masiva de Datos (CSV/JSON) |
| Módulo | Funcionalidades Adicionales |
| Prioridad | Baja |
| Estado | Pendiente |
| RNF asociados | — |

---

**Descripción**: El sistema debe permitir cargar varios registros a la vez desde un archivo CSV o JSON para escenas, personajes, actores y roles/invitaciones del equipo, en lugar de capturarlos uno por uno.

**Entradas**:

- Archivo CSV o JSON con las columnas del módulo correspondiente
- Módulo destino: Escenas, Personajes, Actores o Roles del equipo

**Proceso**:

- En la pantalla del módulo, el usuario con permiso de edición usa "Carga masiva" y selecciona el archivo.
- El sistema lee el archivo en la aplicación, valida cada fila y muestra el resultado de la carga.
- Las filas válidas se crean; las inválidas se informan con el motivo.
- No se admiten archivos Excel (.xlsx): hay que exportar la hoja a CSV antes de subirla.

**Salidas**:

- Registros creados
- Resumen de filas rechazadas

**Precondiciones**:

- Usuario con permiso de edición en el módulo destino
- Archivo en formato CSV o JSON válido

**Postcondiciones**:

- Los registros quedan disponibles en el módulo como si se hubieran creado a mano

**Actores**: Administrador, Director (según el módulo)

**Dependencias**:

- RF-022 (Actores y personajes)
- RF-027 (Desglose editable)
