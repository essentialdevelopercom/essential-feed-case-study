# BDD - Security & User Management Features

## Estado de Implementación
- ✅ Completado
- 🔜 Siguiente a implementar
- 🔄 Pendiente

---

## Resumen Actualizado de Estado de Implementación
| Caso de Uso                                   | Estado                  |
|-----------------------------------------------|-------------------------|
| 1. Almacenamiento Seguro                     | 🔜 Siguiente a implementar |
| 2. Registro de Usuario                       | 🔄 Pendiente             |
| 3. Autenticación de Usuario                  | 🔄 Pendiente             |
| 4. Gestión de Token Expirado                 | 🔄 Pendiente             |
| 5. Recuperación de Contraseña                | 🔄 Pendiente             |
| 6. Gestión de Sesiones                       | 🔄 Pendiente             |
| 7. Cambio de Contraseña                      | 🔄 Pendiente             |
| 8. Verificación de Cuenta                    | 🔄 Pendiente             |
| 9. Autenticación con Proveedores Externos    | 🔄 Pendiente             |
| 10. Métricas de Seguridad                    | 🔄 Pendiente             |

---

## 1. Almacenamiento Seguro (SecureStorage)

### Caso de Uso: Almacenamiento Seguro
**Datos:**
- ✅ Información sensible a proteger
- ✅ Nivel de protección requerido

**Curso Principal (happy path):**
- ✅ Sistema determina el nivel de protección necesario.
- ✅ Sistema encripta la información si es necesario. _(cubierto por tests)_
- 🔄 Sistema almacena en el Keychain con configuración adecuada. _(pendiente de integración real con Keychain)_
- 🔄 Sistema verifica el almacenamiento correcto. _(falta integración real)_

**Curso de error - error de Keychain (sad path):**
- 🔄 Sistema intenta estrategia alternativa de almacenamiento.
- 🔄 Sistema notifica error si persiste.
- 🔄 Sistema registra error para diagnóstico.

**Curso de error - datos corruptos (sad path):**
- 🔄 Sistema detecta inconsistencia en datos.
- 🔄 Sistema limpia los datos corruptos.
- 🔄 Sistema solicita nueva autenticación si es necesario.

**Implementación:**
- ✅ Protocolo SecureStorage que define operaciones de guardado, recuperación y eliminación
- ✅ Implementación del método protectionLevel para determinar nivel de seguridad
- 🔄 Implementación KeychainSecureStorage usando el Keychain de iOS
- ✅ Pruebas unitarias completas que validan todos los escenarios del dominio SecureStorage

---

## 2. Registro de Usuario
**Historia:** Usuario nuevo solicita registrarse en la aplicación

### Narrativa
Como nuevo usuario
Quiero poder registrarme en la aplicación
Para crear una cuenta y acceder a las funcionalidades

### Escenarios (Criterios de aceptación)
- 🔄 Registro exitoso
- 🔄 Error de datos inválidos
- 🔄 Error de correo ya registrado
- 🔄 Error de conexión

### Implementación
- 🔄 Comando "Registrar Usuario" y validaciones
- 🔄 Almacenamiento seguro de credenciales

---

## 3. Autenticación de Usuario
**Historia:** Usuario solicita autenticarse en la aplicación

### Escenarios (Criterios de aceptación)
- 🔄 Inicio de sesión exitoso
- 🔄 Error de credenciales incorrectas
- 🔄 Error de conexión
- 🔄 Cierre de sesión exitoso
- 🔄 Restauración de sesión al inicio de aplicación
- 🔄 Detección de token expirado durante uso
- 🔄 Múltiples intentos fallidos de autenticación

---

## 4. Gestión de Token Expirado
Historia: Sistema maneja tokens expirados y actualización automática

**Narrativa**
Como sistema de autenticación
Quiero manejar correctamente los tokens expirados
Para ofrecer una experiencia fluida al usuario manteniendo la seguridad

**Escenarios (Criterios de aceptación)**
- Escenario 1: Renovación automática del token
  - Dado que el token de acceso del usuario ha expirado
  - Cuando la aplicación intenta realizar una operación autenticada
  - Entonces el sistema debe detectar la expiración
  - Y utilizar el refresh token para obtener un nuevo token de acceso
  - Y continuar la operación sin intervención del usuario
- Escenario 2: Error en renovación de token
  - Dado que el token de acceso ha expirado
  - Cuando el refresh token también ha expirado o es inválido
  - Entonces el sistema debe solicitar al usuario iniciar sesión nuevamente
  - Y preservar el estado de la operación interrumpida
  - Y restaurar la operación tras la nueva autenticación
- Escenario 3: Revocación preventiva de tokens
  - Dado que se detecta una actividad sospechosa
  - Cuando el sistema lo identifica como un riesgo de seguridad
  - Entonces el sistema debe revocar todos los tokens activos
  - Y solicitar una nueva autenticación
  - Y notificar al usuario sobre la acción realizada

**Caso de Uso Técnico: Gestión de Token Expirado**
- Datos: Token de acceso expirado, Refresh token
- Curso Principal (happy path):
  - Sistema detecta token de acceso expirado.
  - Sistema ejecuta comando "Renovar Token" con el refresh token.
  - Sistema recibe nuevo token de acceso.
  - Sistema actualiza el token almacenado.
  - Sistema continúa la operación original sin interrupción para el usuario.
- Curso de error - refresh token expirado (sad path):
  - Sistema notifica necesidad de nueva autenticación.
  - Sistema preserva el estado de la operación en curso.
  - Sistema dirige al usuario al flujo de inicio de sesión.
  - Sistema restaura operación después de autenticación exitosa.
- Curso de error - error de servidor (sad path):
  - Sistema intenta reintento con backoff exponencial.
  - Si persiste, notifica al usuario del problema.
  - Sistema ofrece opción de reintento manual.

---

## 5. Recuperación de Contraseña
Historia: Usuario solicita recuperar su contraseña

**Narrativa**
Como usuario que ha olvidado su contraseña
Quiero poder restablecerla de manera segura
Para recuperar el acceso a mi cuenta

**Escenarios (Criterios de aceptación)**
- Escenario 1: Solicitud de recuperación exitosa
  - Dado que el usuario introduce un correo electrónico registrado
  - Cuando solicita restablecer su contraseña
  - Entonces la aplicación debe enviar un enlace de restablecimiento al correo
  - Y mostrar un mensaje de confirmación
  - Y registrar la solicitud en los logs de seguridad
- Escenario 2: Error de correo no registrado
  - Dado que el usuario introduce un correo electrónico no registrado
  - Cuando intenta solicitar un restablecimiento de contraseña
  - Entonces la aplicación debe mostrar un mensaje indicando que se han enviado instrucciones si el correo existe
  - Sin revelar si el correo existe o no por razones de seguridad
  - Y aplicar el mismo tiempo de respuesta que una solicitud exitosa
- Escenario 3: Restablecimiento de contraseña exitoso
  - Dado que el usuario ha recibido un enlace de restablecimiento válido
  - Cuando introduce una nueva contraseña que cumple con los requisitos
  - Entonces la aplicación debe actualizar la contraseña
  - Y redirigir al usuario a la pantalla de inicio de sesión con un mensaje de éxito
  - Y notificar al usuario por correo sobre el cambio de contraseña
- Escenario 4: Error de enlace expirado o inválido
  - Dado que el usuario intenta usar un enlace expirado o inválido
  - Cuando accede al enlace de restablecimiento
  - Entonces la aplicación debe mostrar un mensaje de error
  - Y permitir solicitar un nuevo enlace
  - Y registrar el intento fallido para detección de ataques

**Caso de Uso Técnico: Recuperación de Contraseña**
- Datos: Correo electrónico
- Curso Principal (happy path):
  - Ejecutar comando "Solicitar Recuperación" con el correo proporcionado.
  - Sistema valida el formato del correo.
  - Sistema envía solicitud al servidor.
  - Sistema registra la solicitud en logs de seguridad.
  - Sistema notifica envío exitoso de instrucciones.
- Curso de error - correo inválido (sad path):
  - Sistema notifica error de formato de correo.
- Curso de error - sin conectividad (sad path):
  - Sistema almacena la solicitud para reintentar.
  - Sistema notifica error de conectividad.
  - Sistema ofrece opción de reintentar más tarde.

---

## 6. Gestión de Sesiones
Historia: Usuario quiere gestionar sus sesiones activas

**Narrativa**
Como usuario preocupado por la seguridad
Quiero poder ver y gestionar mis sesiones activas
Para detectar y cerrar accesos no autorizados

**Escenarios (Criterios de aceptación)**
- Escenario 1: Visualización de sesiones activas
  - Dado que el usuario está autenticado
  - Cuando accede a la sección "Mis sesiones"
  - Entonces la aplicación debe mostrar una lista de todas las sesiones activas
  - Con información de dispositivo, ubicación y fecha de último acceso
  - Y destacar la sesión actual del usuario
- Escenario 2: Cierre de sesión remota
  - Dado que el usuario visualiza sus sesiones activas
  - Cuando selecciona "Cerrar sesión" para una sesión específica
  - Entonces la aplicación debe invalidar esa sesión
  - Y mostrar la lista actualizada de sesiones
  - Y enviar una notificación al dispositivo afectado
- Escenario 3: Cierre de todas las sesiones
  - Dado que el usuario visualiza sus sesiones activas
  - Cuando selecciona "Cerrar todas las sesiones"
  - Entonces la aplicación debe invalidar todas las sesiones excepto la actual
  - Y mostrar confirmación de la acción
  - Y actualizar la lista de sesiones
- Escenario 4: Detección de acceso sospechoso
  - Dado que se detecta un inicio de sesión desde una ubicación inusual
  - Cuando el sistema lo identifica como potencialmente sospechoso
  - Entonces la aplicación debe notificar al usuario
  - Y ofrecer la opción de verificar o cerrar esa sesión
  - Y sugerir cambiar la contraseña por seguridad

**Caso de Uso Técnico: Gestión de Sesiones**
- Datos: ID de sesión (opcional para cierre específico)
- Curso Principal (happy path):
  - Ejecutar comando "Listar Sesiones".
  - Sistema obtiene lista de sesiones del servidor.
  - Sistema procesa y formatea la información.
  - Sistema entrega lista de sesiones activas.
- Curso alternativo - cerrar sesión específica:
  - Ejecutar comando "Cerrar Sesión" con ID específico.
  - Sistema envía solicitud de invalidación al servidor.
  - Sistema notifica al dispositivo afectado si es posible.
  - Sistema notifica cierre exitoso.
- Curso alternativo - cerrar todas las sesiones:
  - Ejecutar comando "Cerrar Todas las Sesiones".
  - Sistema envía solicitud de invalidación masiva al servidor.
  - Sistema excluye la sesión actual.
  - Sistema notifica cierre exitoso.
- Curso de error - sin conectividad (sad path):
  - Sistema almacena la solicitud para reintentar.
  - Sistema notifica error de conectividad.
  - Sistema ofrece reintentar cuando la conexión se restablezca.

---

## 7. Cambio de Contraseña
Historia: Usuario autenticado desea cambiar su contraseña

**Narrativa**
Como usuario autenticado
Quiero poder cambiar mi contraseña
Para mantener la seguridad de mi cuenta

**Escenarios (Criterios de aceptación)**
- Escenario 1: Cambio de contraseña exitoso
  - Dado que el usuario está autenticado
  - Cuando introduce correctamente su contraseña actual y una nueva contraseña válida
  - Entonces la aplicación debe actualizar la contraseña
  - Y mostrar un mensaje de confirmación
  - Y actualizar el token de autenticación
  - Y notificar al usuario por correo sobre el cambio realizado
- Escenario 2: Error de contraseña actual incorrecta
  - Dado que el usuario introduce una contraseña actual incorrecta
  - Cuando intenta cambiar su contraseña
  - Entonces la aplicación debe mostrar un mensaje de error
  - Y permitir al usuario intentarlo nuevamente
  - Y registrar el intento fallido para métricas de seguridad
- Escenario 3: Error de nueva contraseña débil
  - Dado que el usuario introduce una nueva contraseña que no cumple con los requisitos de seguridad
  - Cuando intenta cambiar su contraseña
  - Entonces la aplicación debe mostrar los requisitos no cumplidos
  - Y no permitir el cambio hasta que se cumpla con todos los requisitos
  - Y ofrecer sugerencias para crear una contraseña segura

**Caso de Uso Técnico: Cambio de Contraseña**
- Datos: Contraseña actual, Nueva contraseña
- Curso Principal (happy path):
  - Ejecutar comando "Cambiar Contraseña" con los datos proporcionados.
  - Sistema valida el formato de las contraseñas.
  - Sistema envía solicitud al servidor.
  - Sistema actualiza las credenciales almacenadas.
  - Sistema actualiza token de sesión si es necesario.
  - Sistema notifica cambio exitoso.
- Curso de error - contraseña actual incorrecta (sad path):
  - Sistema registra el intento fallido.
  - Sistema notifica error de autenticación.
  - Sistema verifica si se debe aplicar restricción temporal.
- Curso de error - nueva contraseña inválida (sad path):
  - Sistema notifica requisitos de contraseña no cumplidos.
  - Sistema ofrece recomendaciones para contraseña segura.
- Curso de error - sin conectividad (sad path):
  - Sistema almacena la solicitud para reintentar.
  - Sistema notifica error de conectividad.
  - Sistema ofrece opción de reintentar más tarde.

---

## 8. Verificación de Cuenta
Historia: Usuario nuevo debe verificar su cuenta

**Narrativa**
Como usuario recién registrado
Quiero verificar mi correo electrónico
Para confirmar mi identidad y activar completamente mi cuenta

**Escenarios (Criterios de aceptación)**
- Escenario 1: Verificación de correo exitosa
  - Dado que el usuario ha recibido un correo con un enlace de verificación
  - Cuando hace clic en el enlace
  - Entonces la aplicación debe marcar la cuenta como verificada
  - Y mostrar un mensaje de éxito
  - Y permitir el inicio de sesión completo
  - Y actualizar el estado de verificación en todos los dispositivos
- Escenario 2: Reenvío de correo de verificación
  - Dado que el usuario no ha recibido o ha perdido el correo de verificación
  - Cuando solicita reenviar el correo de verificación
  - Entonces la aplicación debe enviar un nuevo correo
  - Y mostrar un mensaje de confirmación
  - Y invalidar los enlaces anteriores
- Escenario 3: Error de verificación
  - Dado que el usuario intenta verificar su cuenta
  - Cuando el enlace de verificación ha expirado o es inválido
  - Entonces la aplicación debe mostrar un mensaje de error
  - Y permitir solicitar un nuevo enlace de verificación
  - Y registrar el intento fallido
- Escenario 4: Intento de acceso a funciones restringidas sin verificación
  - Dado que el usuario ha iniciado sesión pero no ha verificado su cuenta
  - Cuando intenta acceder a funciones que requieren verificación
  - Entonces la aplicación debe mostrar un recordatorio para verificar la cuenta
  - Y ofrecer la opción de reenviar el correo de verificación
  - Y permitir continuar con funcionalidades básicas

**Caso de Uso Técnico: Verificación de Cuenta**
- Datos: Token de verificación
- Curso Principal (happy path):
  - Ejecutar comando "Verificar Cuenta" con el token proporcionado.
  - Sistema valida el token con el servidor.
  - Sistema actualiza estado de cuenta a verificada.
  - Sistema actualiza estado en el SessionManager.
  - Sistema notifica verificación exitosa.
- Curso de error - token inválido o expirado (sad path):
  - Sistema registra el intento fallido.
  - Sistema notifica error específico del token.
  - Sistema ofrece solicitar nuevo token.
- Curso de error - sin conectividad (sad path):
  - Sistema almacena la verificación para reintentar.
  - Sistema notifica error de conectividad.
  - Sistema reintenta automáticamente cuando la conexión se restablezca.

---

## 9. Autenticación con Proveedores Externos
Historia: Usuario desea autenticarse mediante proveedores externos

**Narrativa**
Como usuario
Quiero poder iniciar sesión con mi cuenta de Google, Facebook o Apple
Para acceder rápidamente sin recordar credenciales adicionales

**Escenarios (Criterios de aceptación)**
- Escenario 1: Inicio de sesión con Google exitoso
  - Dado que el usuario selecciona "Iniciar sesión con Google"
  - Cuando completa la autenticación con Google correctamente
  - Entonces la aplicación debe autenticar al usuario
  - Y crear una cuenta vinculada si es la primera vez
  - Y almacenar el token de autenticación de forma segura
  - Y mostrar la pantalla principal
- Escenario 2: Inicio de sesión con Facebook exitoso
  - Dado que el usuario selecciona "Iniciar sesión con Facebook"
  - Cuando completa la autenticación con Facebook correctamente
  - Entonces la aplicación debe autenticar al usuario
  - Y crear una cuenta vinculada si es la primera vez
  - Y almacenar el token de autenticación de forma segura
  - Y mostrar la pantalla principal
- Escenario 3: Inicio de sesión con Apple exitoso
  - Dado que el usuario selecciona "Iniciar sesión con Apple"
  - Cuando completa la autenticación con Apple correctamente
  - Entonces la aplicación debe autenticar al usuario
  - Y crear una cuenta vinculada si es la primera vez
  - Y almacenar el token de autenticación de forma segura
  - Y mostrar la pantalla principal
- Escenario 4: Error de autenticación con proveedor externo
  - Dado que el usuario intenta iniciar sesión con un proveedor externo
  - Cuando ocurre un error durante el proceso
  - Entonces la aplicación debe mostrar un mensaje de error específico
  - Y permitir intentar con otro método de autenticación
  - Y registrar el error para diagnóstico
- Escenario 5: Vinculación de cuenta existente con proveedor
  - Dado que el usuario ya tiene una cuenta tradicional
  - Cuando vincula su cuenta con un proveedor externo
  - Entonces la aplicación debe asociar ambas identidades
  - Y permitir iniciar sesión con cualquiera de los métodos
  - Y mostrar un mensaje de confirmación

**Caso de Uso Técnico: Autenticación con Proveedor Externo**
- Datos: Proveedor seleccionado (Google, Facebook, Apple), Tokens o credenciales del proveedor
- Curso Principal (happy path):
  - Ejecutar comando "Autenticar con Proveedor" con el proveedor seleccionado.
  - Sistema inicia flujo de autenticación del proveedor.
  - Sistema recibe tokens de autorización.
  - Sistema valida tokens con el servidor.
  - Sistema almacena token de autenticación propio en el Keychain.
  - Sistema registra la sesión en el SessionManager.
  - Sistema notifica éxito de autenticación.
- Curso de error - autenticación cancelada (sad path):
  - Sistema notifica que el proceso fue cancelado.
  - Sistema limpia cualquier token parcial.
- Curso de error - autenticación fallida (sad path):
  - Sistema registra el error específico.
  - Sistema notifica error específico de autenticación.
  - Sistema sugiere método alternativo.
- Curso de error - sin conectividad (sad path):
  - Sistema notifica error de conectividad.
  - Sistema ofrece reintentar cuando la conexión se restablezca.

---

## 10. Métricas de Seguridad
_(Ver detalles en el documento fuente)_

---

# Notas
- Los escenarios marcados como ✅ están cubiertos por código y tests.
- Los escenarios 🔄 requieren implementación o integración real.
- Los escenarios 🔜 son los siguientes a abordar.

# Cómo usar este documento
- Utiliza este documento como guía para priorizar el desarrollo y los tests.
- Marca los escenarios como completados a medida que avances.
- Amplía los escenarios con ejemplos Gherkin si lo deseas (puedo ayudarte a generarlos).


8.- Para la implementación, como usamos TDD (Red-Green-Refactor). crearas la estructura de carpetas dentro del proyecto que tenemos, y arrancaremos con un fichero XCTestCase, en el cual se irán generando, tanto las pruebas como el código de producción que dichas pruebas nos generará, así podemos hacer un seguimiento correcto tanto de las pruebas como del código de producción que estás generan. Una vez terminado el punto del curso, probadas las pruebas, pasaremos ese código de producción a su fichero correspondiente fuera de los test.
9.- Lleva siempre un control de versionado con git.
10.- Aunque está especificado en las "rules" actualiza siempre los ficheros de configuración del proyecto(xcodeproj/xcconfig/xcworkspace, o el que corresponda, para que al ejecutarlos en Xcode aparezcan reflejados y dentro de sus correspondientes targets
