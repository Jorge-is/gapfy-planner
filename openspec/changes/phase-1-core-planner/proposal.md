# Proposal: Fase 1 — Núcleo desplegable de PlanIA

## Intent

Jorge necesita cargar su ciclo académico real (UTP + ICPNA) y generar un plan semanal automático de
estudio, con un despliegue público apto para CV. Hoy no existe código, solo el diseño documentado en
`docs/`. Esta fase construye el núcleo mínimo usable: datos, scheduler determinista y vista semanal.

## Scope

### In Scope
- Scaffold Next.js 15 (App Router, TS, Tailwind, shadcn/ui) + Supabase, deploy continuo en Vercel.
- Auth (email + Google OAuth) y RLS aplicando el DDL de `docs/DATA-MODEL.md` vía migraciones versionadas.
- CRUD de áreas, proyectos, clases recurrentes (con excepciones) y tareas.
- Scheduler puro en TypeScript (`lib/scheduler/`), implementando `docs/PLAN.md §5`, testeado con Vitest.
- Integración: cargar datos reales, ejecutar scheduler, persistir `planned_sessions`.
- Vista semana con time-blocking: leer plan, marcar sesión cumplida/omitida.

### Out of Scope
- Vistas día/mes, PWA/push, reportes, export `.ics` (Fase 2).
- IA (parseo de sílabo, resumen), reprogramación automática (Fase 3).
- Import de Google Calendar, offline con escritura, colaboración (Fase 4).

## Capabilities

### New Capabilities
- `auth-and-authorization`: login (email + Google OAuth), sesión, RLS como frontera de aislamiento entre usuarios.
- `academic-planning-data`: áreas, proyectos, clases recurrentes con excepciones, eventos manuales, tareas.
- `deterministic-scheduler`: detección de huecos libres + asignación de sesiones por urgencia/prioridad, con reporte de conflictos.
- `weekly-time-blocking`: vista semana, generación de plan, marcar sesión cumplida/omitida.

### Modified Capabilities
- None (proyecto sin specs previas).

## Approach

Scheduler puro y aislado desde el inicio (sin dependencias de Supabase/React), testeado con fixtures
antes de integrarlo. Orden de construcción: scaffold → scheduler puro → Supabase/Auth/RLS (con CLI
local para poder testear RLS de forma reproducible) → CRUD → integración → vista semana → deploy
continuo desde el primer commit. Mutaciones vía Server Actions (idiomático en App Router 15, evita
duplicar capas con Route Handlers, que se reservan para la futura API de IA en Fase 3).

## Affected Areas

| Area | Impact | Description |
|------|--------|--------------|
| `supabase/migrations/` | New | DDL de `docs/DATA-MODEL.md` versionado |
| `lib/scheduler/` | New | Algoritmo puro, sin I/O |
| `lib/supabase/` | New | Clientes server/browser |
| `app/(auth)/`, `app/(app)/` | New | Rutas: login, semana, clases, tareas |
| `docs/DATA-MODEL.md` | Reference | Fuente de verdad del schema, no se modifica |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| RLS mal configurada expone datos entre usuarios | Med | Test cruzado obligatorio (usuario B lee datos de A) antes de cerrar la fase |
| Alcance sigue siendo ambicioso para 5-8 h/sem | Med | Tasks pequeñas y verificables en `sdd-tasks`; scheduler resuelto temprano |
| Sin Supabase local, tests de RLS no son reproducibles en CI | Low | Usar Supabase CLI (`supabase start`) para tests locales |

## Rollback Plan

Cada tarea es un commit atómico revertible (`git revert`). El deploy en Vercel usa preview
deployments por PR/branch antes de promover a producción — nada llega a la URL pública sin pasar por
ahí. Las migraciones de Supabase son versionadas y reversibles individualmente.

## Dependencies

- Cuenta Supabase (free tier) y proyecto creado.
- Cuenta Vercel (free tier) vinculada al repo.
- Docker disponible localmente para `supabase start` (tests de RLS).

## Success Criteria

- [ ] Clases reales de UTP e ICPNA cargadas y visibles en la vista semana.
- [ ] Scheduler genera plan válido con ≥5 tareas de deadlines distintos, respetando límites de `user_settings`.
- [ ] 5 sesiones marcadas cumplidas/omitidas persisten correctamente.
- [ ] Usuario B no puede leer ni escribir datos del usuario A (verificado, no asumido).
- [ ] URL de producción en Vercel funcional desde celular.
