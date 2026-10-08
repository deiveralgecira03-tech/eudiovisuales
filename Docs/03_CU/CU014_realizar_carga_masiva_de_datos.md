# CU014 — Realizar Carga Masiva de Datos

## Identificación

| Campo | Valor |
|---|---|
| ID | CU014 |
| Título | Realizar Carga Masiva de Datos |
| Módulo | Módulo 5: Funcionalidades Adicionales |
| Actor primario | Administrador, Director |
| Frecuencia | Baja |
| Estado | Pendiente |

---

#### Actores

- **Primario:** Administrador, Director

#### Descripción

Permite cargar varios registros a la vez desde un archivo CSV o JSON para escenas, personajes, actores y roles/invitaciones, y ver el resultado por fila.

#### Precondiciones

- Usuario con permiso de edición en el módulo destino
- Archivo CSV o JSON con las columnas esperadas

#### Postcondiciones

- Registros válidos creados; filas inválidas informadas con su motivo

#### Flujo Principal

1. Usuario abre el módulo destino y elige "Carga masiva"
2. Usuario selecciona el archivo CSV o JSON
3. Sistema lee el archivo y valida cada fila
4. Sistema crea los registros válidos
5. Sistema muestra el resumen de creados y rechazados

#### Flujos Alternativos

**FA-001: Archivo Excel** : Usuario exporta su hoja a CSV y vuelve a intentar (no se admite .xlsx)

#### Flujos Excepcionales

**FE-001: Archivo con formato inválido** : Sistema rechaza el archivo e indica el problema

#### Frecuencia

Baja
