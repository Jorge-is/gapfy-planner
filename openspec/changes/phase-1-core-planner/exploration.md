## Exploration: phase-1-core-planner

### Current State

Repo recién inicializado, sin código. Existe documentación completa que actúa como fuente de verdad
de alcance y diseño: `docs/PLAN.md` (algoritmo del planificador §5), `docs/ARCHITECTURE.md` (stack:
Next.js 15 App Router + TS + Tailwind + shadcn/ui como PWA, Supabase con RLS), `docs/DATA-MODEL.md`
(DDL completo con políticas RLS ya escritas), `docs/ROADMAP.md` (criterios de aceptación de Fase 1),
y 5 ADRs justificando cada decisión estructural. No hay `package.json` ni scaffold — todo está por
construirse desde cero.

### Affected Areas (a crear, no existen aún)

- `docs/DATA-MODEL.md` — DDL a aplicar como migración inicial de Supabase (fuente de verdad del schema)
- `docs/PLAN.md §5` — pseudocódigo a traducir a TypeScript puro (el scheduler)
- (nuevo) `app/` — rutas de Next.js App Router
- (nuevo) `lib/scheduler/` — lógica pura del planificador, sin dependencias de UI ni DB
- (nuevo) `lib/supabase/` — clientes server/browser de Supabase
- (nuevo) `supabase/migrations/` — SQL versionado a partir del DDL de `DATA-MODEL.md`

### Approaches

1. **Scheduler como paquete puro aislado desde el día 1** — `lib/scheduler/` sin importar nada de
   Next.js, Supabase ni React. Recibe datos ya cargados (tareas, ocupación, settings) como argumentos
   planos, devuelve asignaciones y conflictos.
   - Pros: testeable con Vitest sin mocks de red; es la pieza que más vale mostrar en portafolio;
     desacopla el orden de construcción — se puede escribir y testear ANTES de tener Supabase
     configurado.
   - Cons: ninguno relevante — es exactamente lo que pide `docs/PLAN.md §5` y lo que justifica el
     ADR 0004.
   - Effort: Medium (el algoritmo tiene varias reglas: slack, límites duros, fragmentación).

2. **Scheduler acoplado a queries de Supabase desde el inicio** (leer directo de la DB dentro de la
   función de planificación).
   - Pros: menos código de "adaptación" en el corto plazo.
   - Cons: imposible testear sin una DB real o mocks pesados; viola el ADR 0004 en la práctica (deja
     de ser una función determinista pura, aunque el algoritmo en sí lo sea); acopla UI/infra con
     lógica de negocio, contrario al criterio de "función pura testeada" del propio `docs/PLAN.md`.
   - Effort: Low a corto plazo, pero paga deuda técnica cara apenas se necesite testear casos de borde
     (deadline imposible, slack límite, sesión omitida — los 4 casos que pide `docs/ROADMAP.md`).

### Orden de construcción recomendado dentro de la Fase 1

El `docs/ROADMAP.md` lista las tareas sin orden de dependencia explícito. Dependencias reales:

1. **Setup + scaffold** (Next.js, Tailwind, shadcn/ui, CI mínimo) — no depende de nada.
2. **Scheduler puro** (`lib/scheduler/`, con Vitest) — no depende de Supabase ni UI. Puede construirse
   en paralelo al setup, con datos de prueba fijos (fixtures). Es la pieza de mayor riesgo técnico —
   conviene resolverla temprano, no al final.
3. **Supabase + Auth + RLS** — aplicar el DDL de `docs/DATA-MODEL.md` como migración inicial, verificar
   políticas RLS con un test cruzado de dos usuarios (pedido explícito en criterios de aceptación).
4. **CRUD de áreas/proyectos/clases/tareas** — depende de (3).
5. **Integración**: cargar datos reales desde Supabase, pasarlos al scheduler puro de (2), persistir
   `planned_sessions`.
6. **Vista semana con time-blocking** — depende de (4) y (5).
7. **Deploy en Vercel** — se puede hacer temprano (deploy vacío) y mantener continuo, no como paso final.

### Ambigüedades a resolver en el proposal

1. **Estructura de carpetas concreta de Next.js**: `app/` (rutas) vs `lib/` (dominio) vs `components/`
   (UI) — no está definida en los docs actuales. El proposal debe fijarla.
2. **Server Actions vs Route Handlers**: `docs/ARCHITECTURE.md` menciona "Route Handlers" para la API
   de IA, pero no especifica qué mecanismo usan las mutaciones CRUD normales (clases, tareas). Server
   Actions es más idiomático en App Router 15 y evita duplicar capas — el proposal debe decidirlo
   explícitamente.
3. **Testing contra Supabase real vs mock en Fase 1**: para el test de RLS cruzado (criterio de
   aceptación #4 del roadmap) hace falta una instancia real o local (`supabase start` con Docker) —
   no se puede verificar RLS con mocks. El proposal debe decidir si se usa Supabase local para CI/tests
   o solo verificación manual contra el proyecto real.
4. **Convención de migraciones**: si se usa Supabase CLI (`supabase/migrations/*.sql`) versionado en
   el repo, o se aplica el DDL manualmente desde el dashboard. Para portafolio y reproducibilidad,
   migraciones versionadas son claramente superiores — pero debe quedar explícito en el proposal.

### Recommendation

Approach 1 (scheduler puro y aislado desde el día 1), construido en el orden de dependencias descrito
arriba, con Supabase CLI + migraciones versionadas para poder testear RLS de forma reproducible. Esto
respeta el ADR 0004 al pie de la letra y reduce el riesgo del proyecto: la pieza más difícil y más
valiosa para portafolio (el algoritmo) se resuelve y testea temprano, no al final cuando ya no queda
margen en las 5-6 semanas presupuestadas.

### Risks

- Si el scheduler se deja para el final, el margen de tiempo se agota justo en la parte más compleja.
- Sin Supabase local (Docker) para tests de RLS, la verificación de aislamiento entre usuarios queda
  manual y no repetible en CI — riesgo de regresión silenciosa.
- El alcance de Fase 1 sigue siendo ambicioso para 5-8 h/semana; el proposal debe fijar tasks pequeñas
  y verificables, no bloques grandes.

### Ready for Proposal

Sí. Las tres ambigüedades listadas arriba deben resolverse explícitamente como decisiones en el
proposal (estructura de carpetas, Server Actions, y Supabase local para tests de RLS), no dejarse
implícitas para `sdd-tasks`.
