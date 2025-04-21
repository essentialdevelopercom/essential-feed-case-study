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

# Script para Generar resumen de cobertura
python3 scripts/generate_coverage_summary_md.py 

Este script genera un resumen de cobertura de código en Markdown, HTML y CSV a partir de `[coverage-summary.md](docs/coverage-summary.md)

---

## 📊 Estado de cobertura (actualizado 2025-04-21)
- **Cobertura global:** 88.3%
- **Módulos críticos de seguridad:** Keychain, SecureStorage, Registro y Login >85%
- **Tests:** unitarios e integración, cubriendo escenarios reales y edge cases principales.
- Consulta el [coverage-summary.md](docs/coverage-summary.md) para detalle por módulo.
- Reporte interactivo: [coverage_html_latest/index.html](coverage_html_latest/index.html)

> Mantén la cobertura >85% en módulos core y prioriza edge cases de helpers/factories para robustez máxima.
