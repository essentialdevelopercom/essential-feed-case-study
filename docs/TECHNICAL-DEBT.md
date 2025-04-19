# Informe de Deuda Técnica (Módulo Registro de Usuario)

## 1. UserRegistrationUseCase: Violación de SRP e ISP

**Problema:**
El use case está asumiendo múltiples responsabilidades:
- Validación de datos.
- Orquestación de la petición HTTP.
- Manejo de errores de red y dominio.
- Almacenamiento seguro en Keychain.
- Notificación y sugerencia de acciones de UX.

**Impacto:**
- Dificulta el mantenimiento y la extensibilidad.
- Hace más complejos los tests unitarios.
- Acopla lógica de dominio con detalles de presentación y UX.

**Recomendación:**
- Extraer boundaries/presenters para notificaciones y sugerencias.
- Segregar protocolos para cumplir ISP.
- Dejar el use case solo como orquestador.

---

## 2. Protocolos con múltiples responsabilidades

**Problema:**
Se tiende a agrupar métodos de notificación y sugerencia en un solo protocolo (`UserRegistrationNotifier`), lo que viola ISP.

**Impacto:**
- Los consumidores del protocolo deben implementar métodos que no necesitan.
- Menor flexibilidad y mayor acoplamiento.

**Recomendación:**
- Segregar en protocolos pequeños y específicos para cada tipo de notificación o sugerencia.
- Usar typealias solo para conveniencia, nunca para agrupar responsabilidades de forma forzada.

---

## 3. Tests con Spies multifunción

**Problema:**
Algunos spies implementan varios métodos de notificación/sugerencia, lo que puede ocultar violaciones de ISP y dificultar la trazabilidad de la intención de cada test.

**Recomendación:**
- Crear un spy por cada protocolo boundary.
- Mantener los tests enfocados y alineados a una única responsabilidad.

---

## 4. Posible acoplamiento entre dominio y detalles de infraestructura

**Problema:**
El use case conoce detalles de Keychain, HTTPClient y notifiers, lo que puede dificultar la migración o sustitución de implementaciones.

**Recomendación:**
- Usar protocolos y factories para inyectar dependencias.
- Revisar si alguna lógica de infraestructura puede moverse a servicios especializados.

---

## 5. Documentación y trazabilidad

**Problema:**
No siempre se refleja en el BDD o en la documentación técnica las decisiones arquitectónicas o las áreas de deuda.

**Recomendación:**
- Anotar cada decisión y deuda técnica en un archivo dedicado (`TECHNICAL-DEBT.md` o similar).
- Mantener el BDD solo para flujo funcional y de negocio.

---

## Resumen ejecutivo

- El módulo de registro de usuario necesita una **refactorización para cumplir estrictamente SRP e ISP**.
- Los boundaries/presenters deben estar segregados y el use case debe delegar toda la presentación/UX.
- Los tests y spies deben alinearse a esta arquitectura.
- Documentar y revisar periódicamente la deuda técnica.
