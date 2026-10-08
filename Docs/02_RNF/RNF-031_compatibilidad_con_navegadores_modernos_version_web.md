# RNF-031 — Compatibilidad con Navegadores Modernos (Versión Web)

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-031 |
| Título | Compatibilidad con Navegadores Modernos (Versión Web) |
| Categoría | Compatibilidad |
| Prioridad | Media |
| Estado | Pendiente |
| RF asociados | General / Transversal |

---

**Descripción**: La versión web de Raccord (página de presentación y la aplicación Flutter compilada para web) debe funcionar sin errores en navegadores modernos (Chrome, Firefox, Safari, Edge) en su versión actual y una anterior, sin soportar Internet Explorer. Las aplicaciones nativas (iOS, Android, Windows, macOS) no dependen de un navegador.

**Métrica**:

- Compatibilidad con:

        Chrome/Edge (Chromium) ≥ 90
        Firefox ≥ 88
        Safari ≥ 14
- Funcionalidad completa de inicio de sesión y consulta en cada navegador
- Sin errores de JavaScript en consola
- NO se soporta Internet Explorer

**Aplica a**: Versión web (página de presentación y aplicación Flutter web)

**Estándar/Norma**:

- W3C Web Standards

**Método de Verificación**:
- Pruebas manuales en cada navegador
- Verificar en cada uno: inicio de sesión, ver galería y ver plan de rodaje
- Verificar consola sin errores
