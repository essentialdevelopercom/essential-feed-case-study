# Carpeta de documentación y recursos

Esta carpeta contiene toda la documentación técnica del proyecto, así como recursos visuales y diagramas en `images/`.

- `architecture.png`: Diagrama de arquitectura.
- `feed_flowchart.png`: Diagrama de flujo de feed.

Puedes agregar aquí cualquier otro recurso visual o guía técnica relevante.

# Testing

### Ejecución consistente de tests de Keychain

Para asegurar que los tests de Keychain se ejecutan igual en Xcode y en la consola, utiliza el script:

```sh
./run_tests.sh
```

Este script limpia DerivedData, fuerza el uso del simulador correcto y ejecuta los tests con cobertura. Así se evitan inconsistencias y problemas de permisos típicos en tests de Keychain.

# Cobertura de tests y reporte profesional

### 1. Generar cobertura y bundle reproducible

Ejecuta el script profesional para limpiar, ejecutar tests y generar el bundle de cobertura:

```sh
./scripts/generate_coverage_report.sh
```

Esto:
- Elimina el bundle anterior si existe
- Ejecuta todos los tests con cobertura en macOS usando el esquema CI_macOS
- Genera el bundle en `./coverage-reports/ci_macOS.xcresult`
- Extrae el reporte de cobertura como `./coverage-reports/coverage-report.txt`
- Lanza el resumen Markdown/HTML/CSV automáticamente

### 2. Generar resumen de cobertura manualmente

Si solo quieres el resumen a partir del bundle y el reporte ya generados:

```sh
python3 scripts/generate_coverage_summary_md.py
```

Por defecto usa:
- Bundle: `./coverage-reports/ci_macOS.xcresult`
- Reporte: `./coverage-reports/coverage-report.txt`

### 3. Archivos generados
- `coverage-report.txt`: Resumen plano de cobertura por archivo/función
- `coverage-summary.md`, `coverage-summary.html`, `coverage-summary.csv`: Resúmenes listos para documentación, auditoría y CI

---

> **Limitación técnica en cobertura automatizada de Keychain**
>
> Por restricciones conocidas de Xcode y el entorno CLI, los tests que interactúan con el Keychain del sistema/simulador pueden fallar o no reflejar cobertura real al ejecutar por línea de comandos (xcodebuild, CI, scripts), aunque funcionen correctamente en Xcode GUI.  
> Por tanto, la cobertura de la clase `SystemKeychain.swift` y sus flujos críticos se valida y audita visualmente mediante el reporte de cobertura integrado de Xcode, que es la fuente de verdad para auditoría y compliance.  
> El resto de la cobertura (tests unitarios, helpers, lógica de negocio) se reporta y automatiza normalmente por CLI.
>
> _Esta decisión se documenta para máxima transparencia ante revisores y auditores, y se mantiene alineada con las mejores prácticas de seguridad y calidad en iOS._

---

## 📊 Estado de cobertura (actualizado 2025-04-23 01:09)

- **Cobertura global:** 92.03%
- **Módulos críticos de seguridad:** Keychain, SecureStorage, Registro y Login >85%
- **Tests:** unitarios e integración, cubriendo escenarios reales y edge cases principales.
- Consulta el [coverage-summary.md](docs/coverage-summary.md) para detalle por módulo.
- Reporte interactivo: [coverage_html_latest/index.html](coverage_html_latest/index.html)

> Mantén la cobertura >85% en módulos core y prioriza edge cases de helpers/factories para robustez máxima.
