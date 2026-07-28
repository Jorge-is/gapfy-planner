# Tasks: Fase 1 — Núcleo desplegable de PlanIA

## Phase 1: Foundation

- [x] 1.1 Scaffold Next.js (App Router, TS, Tailwind, shadcn/ui) con `pnpm`. Desviación: se instaló Next.js 16.2 (última estable disponible), no 15 — sin impacto en el diseño, que depende del patrón App Router, no de una versión específica.
- [x] 1.2 Configurar ESLint + Prettier + `tsc --noEmit` en CI (GitHub Actions).
- [x] 1.3 Crear proyecto Supabase, instalar CLI, `supabase init`. Credenciales en `.env.local` (gitignored); `.env.example` versionado como referencia.
- [ ] 1.4 Escribir `supabase/migrations/0001_init.sql` con el DDL completo de `docs/DATA-MODEL.md` (tablas + índices + RLS).
- [ ] 1.5 Deploy inicial vacío en Vercel, conectar repo, confirmar URL pública.
- [ ] 1.6 `lib/scheduler/types.ts` — tipos `TimeBlock`, `TimeSlot`, `SchedulerInput`, `SchedulerResult`.

## Phase 2: Scheduler puro (bloque de mayor riesgo — resolver temprano)

- [ ] 2.1 `lib/scheduler/expand.ts` — expandir `event_series` + `event_exceptions` a `TimeBlock[]` en una ventana.
- [ ] 2.2 `lib/scheduler/free-slots.ts` — calcular huecos libres restando ocupación, sueño y buffers.
- [ ] 2.3 `lib/scheduler/plan.ts` — `planWeek()`: cálculo de slack/urgencia, scoring, asignación greedy.
- [ ] 2.4 `lib/scheduler/plan.ts` — respetar `max_minutes_per_day`, `max_minutes_per_area`, `min_break_minutes`.
- [ ] 2.5 `lib/scheduler/plan.ts` — reporte explícito de conflictos cuando no hay espacio suficiente.
- [ ] 2.6 `lib/scheduler/expand.test.ts` — escenarios de excepción `CANCELLED`/`MOVED` (spec `academic-planning-data`).
- [ ] 2.7 `lib/scheduler/plan.test.ts` — escenarios de slack, empate de prioridad, tope diario, conflicto, reproducibilidad (spec `deterministic-scheduler`).

## Phase 3: Auth y datos

- [ ] 3.1 `lib/supabase/server.ts`, `client.ts` — clientes tipados server/browser.
- [ ] 3.2 `middleware.ts` — proteger rutas `(app)` sin sesión activa.
- [ ] 3.3 `app/(auth)/login/page.tsx` — login email + Google OAuth.
- [ ] 3.4 `lib/data/areas.ts`, `projects.ts` — Server Actions CRUD.
- [ ] 3.5 `lib/data/events.ts` — Server Actions para `event_series`, `event_exceptions`, `manual_events`.
- [ ] 3.6 `lib/data/tasks.ts` — Server Actions CRUD de tareas, con validación de `estimated_minutes > 0`.
- [ ] 3.7 Test de RLS en Supabase local: usuario B no lee/escribe filas de A en ninguna tabla de dominio (spec `auth-and-authorization`).

## Phase 4: Integración y vista semana

- [ ] 4.1 `lib/data/plan.ts` — Server Action `generatePlan()`: carga datos reales, llama `planWeek()`, persiste `plan_runs` + `planned_sessions`.
- [ ] 4.2 `lib/data/sessions.ts` — Server Action para marcar sesión `DONE`/`PARTIAL`/`SKIPPED`, con `session_logs`.
- [ ] 4.3 `lib/data/sessions.ts` — permitir registrar `session_log` sin `planned_session_id` (trabajo no planificado).
- [ ] 4.4 `app/(app)/classes/`, `app/(app)/tasks/` — UI CRUD de clases y tareas.
- [ ] 4.5 `app/(app)/week/page.tsx` — grilla semanal: clases expandidas + sesiones planificadas.
- [ ] 4.6 `app/(app)/week/page.tsx` — botón "generar plan" y aviso de conflictos.
- [ ] 4.7 `app/(app)/week/page.tsx` — marcar sesión cumplida/omitida desde la grilla.

## Phase 5: Verificación end-to-end

- [ ] 5.1 Playwright: registro → crear clase recurrente → crear tarea → generar plan (spec `weekly-time-blocking`).
- [ ] 5.2 Prueba manual con datos reales: cargar ciclo UTP + ICPNA completo, generar plan de la semana.
- [ ] 5.3 Marcar 5 sesiones reales como cumplidas/omitidas y verificar persistencia.
- [ ] 5.4 Confirmar URL de producción funcional desde celular (criterio de aceptación de `docs/ROADMAP.md`).
