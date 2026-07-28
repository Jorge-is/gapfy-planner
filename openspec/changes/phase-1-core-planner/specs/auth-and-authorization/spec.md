# Auth And Authorization Specification

## Purpose

Autenticación de usuarios y aislamiento de datos entre cuentas. RLS es la frontera real de
autorización, no una conveniencia de UI.

## Requirements

### Requirement: Registro e inicio de sesión

El sistema MUST permitir registro e inicio de sesión por email/contraseña y por Google OAuth.

#### Scenario: Registro con email

- GIVEN un visitante sin cuenta
- WHEN se registra con email y contraseña válidos
- THEN se crea una fila en `auth.users` y una fila en `user_settings` con valores por defecto

#### Scenario: Login con Google

- GIVEN un usuario con cuenta Google
- WHEN inicia sesión vía OAuth de Google
- THEN queda autenticado y redirigido a la vista semana

#### Scenario: Credenciales inválidas

- GIVEN un intento de login con contraseña incorrecta
- WHEN se envía el formulario
- THEN el sistema MUST rechazar el acceso y mostrar un mensaje de error, sin exponer si el email existe

### Requirement: Aislamiento de datos por usuario (RLS)

El sistema MUST garantizar, a nivel de base de datos, que un usuario solo puede leer y escribir sus
propias filas en todas las tablas de dominio (`areas`, `projects`, `event_series`, `event_exceptions`,
`manual_events`, `tasks`, `plan_runs`, `planned_sessions`, `session_logs`, `user_settings`,
`push_subscriptions`).

#### Scenario: Usuario no puede leer datos de otro

- GIVEN dos usuarios autenticados A y B, cada uno con tareas propias
- WHEN B ejecuta una consulta sobre la tabla `tasks`
- THEN B MUST NOT recibir ninguna fila perteneciente a A

#### Scenario: Usuario no puede escribir sobre filas ajenas

- GIVEN un usuario B autenticado que conoce el `id` de una tarea de A
- WHEN B intenta actualizar esa tarea directamente contra la base de datos
- THEN la operación MUST fallar o afectar cero filas, nunca modificar la tarea de A

### Requirement: Sesión persistente

El sistema SHOULD mantener la sesión del usuario activa entre recargas de página sin requerir login
repetido, dentro de la ventana de expiración configurada por Supabase Auth.

#### Scenario: Recarga con sesión activa

- GIVEN un usuario autenticado
- WHEN recarga la página dentro de la ventana de expiración de la sesión
- THEN permanece autenticado sin ver la pantalla de login
