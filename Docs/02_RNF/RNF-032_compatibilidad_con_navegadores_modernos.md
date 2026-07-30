# RNF-032 — Compatibilidad con Navegadores Modernos

## Identificación

| Campo | Valor |
|---|---|
| ID | RNF-032 |
| Título | Compatibilidad con Navegadores Modernos |
| Categoría | Compatibilidad |
| Prioridad | Alta |
| Estado | Pendiente |
| RF asociados | General / Transversal |

---

**Descripción**: La aplicación web debe funcionar sin errores en navegadores modernos (Chrome, Firefox, Safari, Edge) versión actual y una versión anterior, sin necesidad de soportar Internet Explorer.

**Métrica**:

- Compatibilidad con:
- 
        Chrome/Edge (Chromium) ≥ 90
        Firefox ≥ 88
        Safari ≥ 14
- 100% de funcionalidad en cada navegador
- Sin errores de JavaScript en consola
- Renderizado visual correcto
- NO se soporta Internet Explorer


**Aplica a**: Aplicación web (React.js)

**Estándar/Norma**:

- W3C Web Standards
- ECMAScript 2020+

**Método de Verificación**:
- Pruebas manuales en cada navegador
- Pruebas automatizadas con Selenium o Playwright
- Verificar funcionalidades críticas en cada navegador:

        Login
        Subir fotografía
        Buscar fotografía
        Ver calendario
- Verificar consola sin errores
