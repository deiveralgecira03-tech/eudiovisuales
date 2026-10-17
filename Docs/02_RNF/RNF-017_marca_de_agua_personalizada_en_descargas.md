# RNF-017 — Marca de Agua Personalizada en Descargas

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-017 |
| Título | Marca de Agua Personalizada en Descargas |
| Categoría | Seguridad / Funcionalidad |
| Prioridad | Crítica |
| Estado | Completado |
| RF asociados | RF-011, RF-014, RF-024 |

---

**Descripción**: Toda descarga de guiones, fotografías y reportes debe incluir una marca de agua semitransparente con el nombre de quien descarga y la fecha y hora, sin modificar el archivo original almacenado.

**Métrica**:
- 100% de descargas con marca de agua
- La marca incluye nombre y apellido del usuario (o su correo si faltan) y fecha y hora de la descarga
- Se repite en diagonal sobre toda la página o imagen, con transparencia
- El archivo original permanece intacto en el almacenamiento

**Aplica a**:

- RF-014 (Marca de agua en descargas)
- RF-024 (Visualización y descarga de guion)
- RF-028 (Reportes en PDF)

**Estándar/Norma**: ISO/IEC 27001

**Método de Verificación**:
- Descargar un guion, una foto, el desglose y el plan de rodaje con usuarios distintos
- Verificar que cada archivo muestra el nombre y la fecha del usuario correcto
- Comparar el original del almacenamiento: debe estar sin marca
