# 0002 — Supabase en lugar de backend propio

## Contexto

La app es multiusuario y necesita autenticación, aislamiento de datos por usuario, y persistencia
relacional (clases recurrentes, tareas, sesiones). El desarrollador trabaja solo, con 5-8 h/semana,
presupuesto cercano a cero.

## Opciones consideradas

- **A. Supabase**: Postgres gestionado + Auth + Row Level Security + capa gratuita.
- **B. Backend propio** (Nest.js o Fastify) sobre una base de datos gestionada aparte, con
  autenticación y autorización implementadas a mano.

## Decisión

Se elige **A — Supabase**.

## Consecuencias

- La autorización por usuario se resuelve con Row Level Security en la base de datos, verificable con
  una prueba directa (usuario B no puede leer filas de A), en vez de lógica de autorización dispersa
  en controladores que hay que auditar manualmente.
- Se ahorra la implementación completa de auth (registro, login, OAuth, recuperación de contraseña),
  tiempo que se reinvierte en el planificador, que es la pieza diferencial del proyecto.
- Dependencia de un proveedor externo: el free tier de Supabase pausa el proyecto tras 7 días de
  inactividad. Riesgo aceptado y documentado — el uso personal activo lo evita en la práctica.
- Sigue siendo Postgres real: el modelo de datos y las consultas son portables si en el futuro se
  necesita migrar a un backend propio.
