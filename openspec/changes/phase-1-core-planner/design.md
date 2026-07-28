# Design: Fase 1 — Núcleo desplegable de Gapfy

## Technical Approach

Repo sin código todavía. Construcción en orden de dependencia real: scaffold → scheduler puro (sin
Supabase) → schema/RLS vía migraciones → CRUD → integración scheduler+persistencia → vista semana →
deploy continuo. El scheduler puro se resuelve temprano porque es la mayor fuente de riesgo técnico y
el requisito más estricto de las specs (`deterministic-scheduler`).

## Architecture Decisions

### Decision: Estructura de carpetas

**Choice**: `app/` (rutas App Router, agrupadas en `(auth)/` y `(app)/`), `lib/scheduler/` (dominio
puro), `lib/supabase/` (clientes), `lib/data/` (queries/mutations tipadas), `components/` (UI),
`supabase/migrations/` (SQL versionado).
**Alternatives considered**: todo bajo `app/` sin separar dominio de UI.
**Rationale**: `lib/scheduler/` debe poder importarse y testearse sin arrancar Next.js ni tocar
Supabase — mezclarlo con `app/` rompe esa garantía.

### Decision: Mutaciones vía Server Actions

**Choice**: Server Actions de Next.js para todo el CRUD (áreas, clases, tareas, marcar sesión).
**Alternatives considered**: Route Handlers para todo; API REST separada.
**Rationale**: idiomático en App Router 15, evita una capa HTTP redundante para mutaciones internas.
Route Handlers se reservan para la futura API de IA (Fase 3), que sí necesita ser invocada
server-side de forma aislada con su propio rate limit.

### Decision: Supabase local para tests de RLS

**Choice**: Supabase CLI (`supabase start`, Docker) para correr migraciones y tests de aislamiento
entre usuarios en CI.
**Alternatives considered**: verificación manual contra el proyecto real en cada release.
**Rationale**: el escenario "usuario B no lee datos de A" (spec `auth-and-authorization`) debe ser
reproducible y automatizado, no un chequeo manual que se olvida.

### Decision: Scheduler como función pura sin clases

**Choice**: `planWeek(input: SchedulerInput): SchedulerResult` — función pura, sin I/O, sin clases,
recibe datos ya cargados.
**Alternatives considered**: clase `Scheduler` con estado interno y métodos de carga de datos propios.
**Rationale**: la spec `deterministic-scheduler` exige reproducibilidad estricta (misma entrada, misma
salida) — una función pura lo garantiza por construcción; una clase con estado abre la puerta a
efectos ocultos entre llamadas.

## Data Flow

```
event_series + event_exceptions + manual_events + user_settings
                        │
                        ▼
              expandOccurrences() ──► busy: TimeBlock[]
                        │
                        ▼
              findFreeSlots(busy, window) ──► slots: TimeSlot[]
                        │
    tasks (pending) ────┼──► scoreAndAssign(tasks, slots) ──► { assignments, conflicts }
                        │
                        ▼
       persistPlan(assignments) ──► plan_runs + planned_sessions (Supabase, Server Action)
                        │
                        ▼
              vista semana (lee planned_sessions + busy, renderiza grilla)
```

## File Changes

| File                                  | Action | Description                                                         |
| ------------------------------------- | ------ | ------------------------------------------------------------------- |
| `supabase/migrations/0001_init.sql`   | Create | DDL completo de `docs/DATA-MODEL.md` + políticas RLS                |
| `lib/scheduler/types.ts`              | Create | Tipos: `TimeBlock`, `TimeSlot`, `SchedulerInput`, `SchedulerResult` |
| `lib/scheduler/expand.ts`             | Create | Expansión de `event_series` + excepciones → `TimeBlock[]`           |
| `lib/scheduler/free-slots.ts`         | Create | Cálculo de huecos libres a partir de ocupación + sueño              |
| `lib/scheduler/plan.ts`               | Create | `planWeek()`: scoring, asignación greedy, conflictos                |
| `lib/scheduler/*.test.ts`             | Create | Vitest: casos de slack, tope diario, conflicto, reproducibilidad    |
| `lib/supabase/server.ts`, `client.ts` | Create | Clientes Supabase server/browser                                    |
| `lib/data/*.ts`                       | Create | Queries/mutations tipadas por dominio (areas, tasks, events)        |
| `app/(auth)/login/page.tsx`           | Create | Login email + Google OAuth                                          |
| `app/(app)/week/page.tsx`             | Create | Vista semana, generar plan, marcar sesión                           |
| `app/(app)/classes/`, `tasks/`        | Create | CRUD de clases y tareas                                             |
| `middleware.ts`                       | Create | Protección de rutas `(app)` sin sesión                              |

## Interfaces / Contracts

```typescript
type SchedulerInput = {
  window: { from: string; to: string }; // ISO dates
  busy: TimeBlock[];
  tasks: Array<{
    id: string;
    deadline: string;
    priority: "alta" | "media" | "baja";
    remainingMinutes: number;
    areaId: string | null;
  }>;
  settings: {
    sleepStart: string;
    sleepEnd: string;
    maxMinutesPerDay: number;
    minBlockMinutes: number;
    minBreakMinutes: number;
  };
};

type SchedulerResult = {
  assignments: Array<{ taskId: string; startsAt: string; endsAt: string }>;
  conflicts: Array<{ taskId: string; unassignedMinutes: number }>;
};
```

## Testing Strategy

| Layer       | What to Test                                                           | Approach                                                  |
| ----------- | ---------------------------------------------------------------------- | --------------------------------------------------------- |
| Unit        | `lib/scheduler/*` — slack, límites duros, conflictos, reproducibilidad | Vitest, fixtures fijas, sin mocks de red                  |
| Integration | RLS — aislamiento entre usuarios en todas las tablas de dominio        | Supabase local (`supabase start`), dos usuarios de prueba |
| E2E         | Login → cargar clase → cargar tarea → generar plan → marcar sesión     | Playwright contra entorno de preview                      |

## Migration / Rollout

Una sola migración inicial (`0001_init.sql`) aplica el schema completo con RLS desde el primer commit
funcional. Deploy continuo a Vercel con preview deployments por PR — nada llega a producción sin
pasar por un preview verificado.

## Open Questions

- [ ] Ninguna que bloquee el inicio de `sdd-tasks`. El nombre exacto de la migración y la granularidad
      de los tests de Playwright se ajustan durante la implementación.
