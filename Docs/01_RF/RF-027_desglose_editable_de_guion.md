# RF-027 — Desglose Editable de Guion

## Identificación

| Campo | Valor |
|---|---|
| ID | RF-027 |
| Título | Desglose Editable de Guion |
| Módulo | Gestión de Guiones |
| Prioridad | Media |
| Estado | Completado |
| RNF asociados | — |

---

**Descripción**: El sistema debe proveer herramienta para que Script y Primera AD realicen desgloses de guion directamente en la plataforma, sugiriendo elementos por categoría mediante reconocimiento de patrones de texto (encabezados y palabras clave, sin inteligencia artificial) y permitiendo captura y edición 100% manual.


**Entradas**:

- Guion cargado (RF-023)
- Escena específica seleccionada
- Identificación manual de elementos (siempre disponible; el sistema solo sugiere)

**Proceso**:

- Script o Primera AD abre herramienta "Desglosar Escena"
- Sistema sugiere elementos del guion mediante reconocimiento de patrones de texto y palabras clave (expresiones regulares, sin IA):

        Locaciones: detectar encabezados "INT.", "EXT." con nombre de locación
        Vehículos y efectos especiales: detectar palabras clave predefinidas (auto, moto, explosión, lluvia, humo)
        Personajes, vestuario y utilería: el usuario los añade manualmente (el texto libre del guion es demasiado ambiguo para un reconocimiento confiable por patrones)
- Mostrar elementos sugeridos y manuales organizados por categoría:

        Personajes
        Locaciones
        Utilería/Props
        Vestuario
        Vehículos
        Efectos Especiales
        Armas/Elementos Regulados
- Permitir a Script/Primera AD:

        Confirmar las sugerencias del sistema
        Añadir elementos no sugeridos manualmente
        Descartar sugerencias incorrectas
        Editar descripciones
- Una vez confirmado, crear desglose estructurado (vincula con RF-019)
- Si versión de guion cambia (RF-023): notificar que desglose puede requerir actualización
- Permitir exportar desglose en formato estándar (PDF, Excel)

**Salidas**:

- Desglose estructurado de escena por categorías
- Elementos sugeridos por patrones o ingresados manualmente
- Exportación en PDF/Excel
- Vinculación con RF-019 (Gestión de Desgloses de Escenas)

** Precondiciones**:
- Usuario debe ser Script o Primera AD
- Guion debe estar cargado en sistema

**Postcondiciones**:

- Desglose disponible para coordinación de departamentos
- Información se refleja en el Plan de Rodaje (RF-017) si la escena se programa

**Actores**:

- Script (Continuista)
- Primera Ayudante de Dirección

**Dependencias**:
- RF-023 (Guion debe existir)
- RF-019 (Vinculación con desgloses de escenas)
- Librería de expresiones regulares estándar de Python (`re`) — sin dependencias de IA/NLP
