# RF-014 — Marca de Agua en Descargas

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-014 |
| Título | Marca de Agua en Descargas |
| Módulo | Gestión de Fotografías de Continuidad |
| Prioridad | Crítica |
| Estado | Pendiente |
| RNF asociados | RNF-017 |

---

**Descripción**: Todo archivo que una persona descarga de Raccord (guion en PDF, plan de rodaje, desglose y fotografías de continuidad) debe llevar una marca de agua diagonal, repetida y semitransparente con el nombre de quien descarga y la fecha y hora, para poder rastrear el origen de una filtración. El archivo original almacenado nunca se modifica.

**Entradas**:

- Archivo a descargar (PDF o imagen)
- Usuario autenticado (nombre y apellido; si faltan, su correo)
- Fecha y hora de la descarga

**Proceso**:

- Al descargar, el sistema compone el texto "Nombre Apellido - AAAA-MM-DD HH:MM".
- Se estampa ese texto en mosaico diagonal y semitransparente sobre cada página (PDF) o sobre la imagen.
- Las fotografías descargadas salen en formato PNG con la marca aplicada.
- La descarga solo está disponible para roles con permiso de descarga (Administrador, Director y Jefe de Departamento).
- Si la marca no se puede aplicar a una foto (por ejemplo, archivo que no es una imagen válida), se descarga la foto original.

**Salidas**:

- Archivo descargado con marca de agua visible
- Archivo original intacto en el almacenamiento

**Precondiciones**:

- Usuario autenticado con permiso de descarga
- El contenido existe en el sistema

**Postcondiciones**:

- Cada copia descargada identifica a quien la obtuvo

**Actores**: Administrador, Director, Jefe de Departamento

**Dependencias**:

- RF-005 (Roles y permisos)
- RF-009 (Auditoría de descargas)
