# Roadmap

Estimado a un ritmo real de **5-8 horas por semana**. Cada fase entrega algo desplegado y usable —
nada de "casi funciona".

## Fase 1 — Núcleo desplegable (~5-6 semanas, 35-45 h)

**Objetivo:** cargar mi ciclo académico real, generar un plan semanal y usarlo.

Tareas:

- Setup del proyecto (Next.js, Tailwind, shadcn/ui, Supabase, CI básico).
- Auth (email + Google OAuth) y `user_settings` inicial.
- CRUD de áreas y proyectos.
- Clases recurrentes: alta, edición, excepciones (cancelar/mover ocurrencia).
- Tareas: alta con deadline, prioridad, horas estimadas.
- Motor de detección de huecos libres (función pura, testeada).
- Planificador v1 (algoritmo greedy descrito en `PLAN.md`), sin reprogramación automática todavía.
- Vista semana con time-blocking (lectura + marcar sesión cumplida/omitida).
- Deploy en Vercel con dominio público.

**Criterios de aceptación:**

1. Cargo mis clases reales de UTP e ICPNA del ciclo actual y aparecen correctamente en la vista semana.
2. El planificador genera un plan semanal a partir de al menos 5 tareas con deadlines distintos, y
   respeta los límites de `user_settings`.
3. Marco 5 sesiones como cumplidas u omitidas y el estado persiste.
4. Con dos usuarios de prueba, el usuario B no puede leer ni escribir datos del usuario A (prueba
   directa contra RLS, no solo por UI).
5. La URL de producción carga y funciona desde el celular.

## Fase 2 — Uso diario real (~3-4 semanas)

**Objetivo:** que la app avise sola y empiece a mostrar si estoy cumpliendo.

Tareas:

- Vistas día y mes.
- PWA instalable (manifest, service worker, cache de solo lectura).
- Web Push: suscripción y envío de recordatorios antes de cada sesión planificada.
- Reportes de productividad: % de sesiones cumplidas, entregas a tiempo, distribución de horas por área.
- Export `.ics` de solo lectura.
- Export y borrado de datos del usuario.

**Criterios de aceptación:**

1. Instalo la PWA en el celular y recibo un push 15 minutos antes de una sesión, con la app cerrada.
2. El reporte semanal muestra cifras reales calculadas de mis propias sesiones registradas.
3. Puedo exportar un `.ics` y abrirlo en Google Calendar / Apple Calendar sin errores.

## Fase 3 — IA + reprogramación (~3 semanas)

**Objetivo:** que el sistema se ajuste solo cuando algo cambia, y que cargar tareas sea rápido.

Tareas:

- Parseo con IA de sílabo/texto libre → tareas estructuradas (server-side, validado con Zod), con
  fallback a formulario manual si la IA falla.
- Resumen semanal en lenguaje natural sobre las métricas ya calculadas.
- Reprogramación automática: se dispara ante sesión omitida, tarea nueva o cambio de deadline;
  congela pasado y sesiones `locked`, replanifica solo hacia adelante.
- Manejo de conflictos: la UI muestra tareas sin espacio disponible y sugiere qué recortar.

**Criterios de aceptación:**

1. Pego el texto de un sílabo real y obtengo una lista de tareas con fechas correctas, editable antes
   de guardar.
2. Omito 2 sesiones seguidas y el plan se reacomoda automáticamente sin mover ninguna sesión `locked`.
3. Si desconecto la API de IA (simulado), el parseo cae al formulario manual sin romper la app.

## Fase 4 — Opcional / futuro

- Import de Google Calendar (unidireccional).
- Offline con escritura y sincronización.
- Colaboración (compartir horario con otra persona, grupos de estudio).

Estas quedan explícitamente fuera de alcance salvo que sobre tiempo tras la Fase 3 — no se planifican
en detalle hasta entonces.
