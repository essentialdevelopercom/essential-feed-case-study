# Scripts de automatización y generación de reportes de cobertura

Este directorio contiene scripts para ejecutar tests, generar reportes de cobertura y crear resúmenes visuales automáticos para el proyecto.

## Scripts disponibles

- **generate_coverage_report.sh**  
  Ejecuta los tests en el simulador preferido, genera los reportes de cobertura (`txt`, `json`) y crea resúmenes visuales (Markdown, HTML, CSV, README).
  
  Uso:
  ```sh
  bash scripts/generate_coverage_report.sh
  ```
  o, si tiene permisos de ejecución:
  ```sh
  ./scripts/generate_coverage_report.sh
  ```

- **generate_coverage_summary_md.py**  
  Script auxiliar para generar los resúmenes visuales a partir del reporte de cobertura (`coverage-report.txt`).

---

## Notas

- Todos los reportes generados se guardan en la carpeta `/coverage-reports` para mantener la raíz del proyecto limpia.
- Los scripts deben ejecutarse desde la raíz del proyecto para que las rutas relativas funcionen correctamente.
- Puedes modificar los scripts para adaptarlos a nuevas rutas o necesidades.
