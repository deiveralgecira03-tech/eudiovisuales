# RNF-015 — Bloqueo de Capturas de Pantalla

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-015 |
| Título | Bloqueo de Capturas de Pantalla |
| Categoría | Seguridad |
| Prioridad | Crítica |
| Estado | Pendiente |
| RF asociados | RF-010, RF-015, RF-027 |

---

**Descripción**: El sistema debe deshabilitar capturas de pantalla a nivel de sistema operativo en aplicaciones móviles (iOS/Android) cuando se visualizan contenidos sensibles (fotografías, guiones), y deshabilitar funcionalidades equivalentes en aplicación web.

**Métrica**:
- 100% de pantallas sensibles protegidas en móviles:

        iOS: FLAG_SECURE equivalente
        Android: WindowManager.LayoutParams.FLAG_SECURE
        Pantalla negra si usuario intenta captura
- En web: click derecho deshabilitado, atajos de teclado bloqueados (Ctrl+S, Ctrl+P, PrtScr, Ctrl+Shift+S)


**Aplica a**:
- RF-010 (Visualización de fotografías)
- RF-015 (Marca de agua)
- RF-027 (Visualización de guiones)

**Estándar/Norma**: ISO/IEC 27001

**Método de Verificación**:
- Pruebas manuales en dispositivos iOS intentando captura de pantalla
- Pruebas manuales en dispositivos Android intentando captura
- Verificar pantalla se pone negra
- En web: intentar click derecho, Ctrl+S, PrtScr → deben estar bloqueados
