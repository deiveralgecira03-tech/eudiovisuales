# RF-032 — Página de Presentación y Formulario de Contacto

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-032 |
| Título | Página de Presentación y Formulario de Contacto |
| Módulo | Funcionalidades Adicionales |
| Prioridad | Baja |
| Estado | Completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe contar con una página web pública de presentación del producto y un formulario de contacto para que personas interesadas escriban al equipo de Raccord.

**Entradas**:

- Nombre, empresa, correo y mensaje del formulario de contacto

**Proceso**:

- La página pública presenta el producto y ofrece el formulario de contacto, sin requerir cuenta.
- Al enviar, el servidor valida los datos y envía un correo al equipo de Raccord; el texto del usuario se sanea antes de incluirse en el correo.

**Salidas**:

- Correo de contacto recibido por el equipo
- Confirmación al visitante

**Precondiciones**:

- Ninguna (acceso público)

**Postcondiciones**:

- El equipo recibe la solicitud de contacto

**Actores**: Visitante, Equipo de Raccord

**Dependencias**:

- RF-004 (Envío de correos)
