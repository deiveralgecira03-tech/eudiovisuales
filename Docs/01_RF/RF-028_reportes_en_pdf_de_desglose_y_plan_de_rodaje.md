# RF-028 — Reportes en PDF de Desglose y Plan de Rodaje

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-028 |
| Título | Reportes en PDF de Desglose y Plan de Rodaje |
| Módulo | Reportes y Analítica |
| Prioridad | Media |
| Estado | Pendiente |
| RNF asociados | — |

---

**Descripción**: El sistema debe generar en PDF el desglose de escenas y el plan de rodaje (incluido el parte del día de rodaje con sus escenas, horario, locación y reparto), listos para imprimir o compartir. Es la única salida de reportes: no se exporta a CSV ni Excel. Reemplaza a los antiguos reportes de preparación para rodaje y parte de rodaje diario.

**Entradas**:

- Proyecto
- Reporte: Desglose o Plan de Rodaje (todo el plan o un día)

**Proceso**:

- El usuario con acceso al módulo elige "Descargar PDF" en Desglose o en Plan de Rodaje.
- El sistema arma el documento con la información vigente del proyecto.
- El PDF incluye la marca de agua con nombre y fecha de quien lo descarga (RF-014).

**Salidas**:

- Archivo PDF del desglose o del plan de rodaje

**Precondiciones**:

- El proyecto tiene desglose o plan de rodaje cargado
- Usuario con permiso de descarga

**Postcondiciones**:

- La descarga queda identificada con la marca de agua

**Actores**: Administrador, Director, Jefe de Departamento

**Dependencias**:

- RF-014 (Marca de agua)
- RF-017 (Plan de rodaje)
- RF-019 (Desgloses de escenas)
