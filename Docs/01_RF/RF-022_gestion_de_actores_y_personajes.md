# RF-022 — Gestión de Actores y Personajes

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-022 |
| Título | Gestión de Actores y Personajes |
| Módulo | Gestión de Calendario y Planeación |
| Prioridad | Alta |
| Estado | Completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe permitir registrar los personajes del proyecto, los actores que los interpretan y su ficha técnica (medidas, características físicas, contacto y estado de casting), y vincular los personajes con las escenas en las que aparecen (cast por escena).

**Entradas**:

- Personaje: nombre, edad, código (por ejemplo P001)
- Actor: nombre, apellido, género, fecha de nacimiento, nacionalidad, medidas de vestuario (tallas, contornos), características (cabello, ojos, piel), alergias, habilidades, restricciones, indicador de doble de riesgo
- Contacto y casting: documento, dirección, teléfono, correo, estado de confirmación, llamados, fechas tentativas, guion enviado, ensayos, categoría de cast
- Fotos del actor: foto normal y foto caracterizado como el personaje
- Personaje asignado a cada escena

**Proceso**:

- Quien tenga permiso de crear personajes (Administrador o Director) registra, edita o elimina personajes y actores.
- Cada actor se asocia a un personaje; las fotos del actor se guardan en el almacenamiento de imágenes.
- Desde una escena se agrega o quita un personaje de su cast; el campo de personaje autocompleta con los personajes del proyecto.
- Las pantallas Personajes, Cast List y Escenas muestran estos datos según el acceso de cada rol.

**Salidas**:

- Catálogo de personajes y actores del proyecto
- Cast por escena

**Precondiciones**:

- Proyecto activo
- Usuario con permiso de creación de personajes para editar; el resto solo consulta

**Postcondiciones**:

- La información queda disponible para vestuario, maquillaje y continuidad de cada escena

**Actores**: Administrador, Director (edición); demás roles (consulta según acceso)

**Dependencias**:

- RF-016 (Creación de proyectos)
- RF-027 (Desglose editable, de donde se detectan los personajes)
- RF-031 (Carga masiva)
