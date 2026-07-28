# PlanIA — Plan técnico

## 1. Contexto y objetivo

Jorge cursa Ingeniería de Software en la UTP (Lima, Perú), lleva un curso de inglés en el ICPNA, trabaja
y desarrolla proyectos académicos y personales. PlanIA tiene doble objetivo: resolver su organización
real del tiempo y servir como pieza de portafolio técnico.

Ya existe un prototipo validado con planificación y detección automática de huecos libres. Este documento
es el plan de la aplicación completa.

## 2. Restricciones

- Debe funcionar bien en celular y computadora.
- Presupuesto cercano a cero: capa gratuita de cada servicio.
- Debe desplegarse con un enlace público apto para CV.
- UI y documentación técnica en español. Código y commits en inglés.

## 3. Decisiones cerradas

| Decisión | Elegido | Detalle |
|---|---|---|
| Usuarios | Multiusuario con auth | Cuentas propias, aislamiento vía RLS |
| Google Calendar | Fuera de Fase 1 | Export `.ics` de solo lectura; import en Fase 4 |
| Recordatorios | Web Push + in-app | PWA instalable, sin costo |
| Offline | Solo lectura | Cache de PWA para ver el horario sin señal |
| IA | Mínima y acotada | Parseo de texto libre + resumen semanal, nada más |
| Ritmo de trabajo | 5-8 h/semana | Fase 1 recalibrada a 5-6 semanas |
| Artefactos SDD | `openspec` | Versionados en el repo |

## 4. Alcance funcional

- Vistas de día, semana y mes con time-blocking.
- Clases recurrentes (UTP, ICPNA) con horario fijo semanal, excepciones y fecha de fin de ciclo.
- Exámenes, exposiciones, tareas y entregas con fecha límite, prioridad y horas estimadas.
- Detección automática de bloques de tiempo libre.
- Planificador automático de sesiones de estudio/trabajo profundo, con reprogramación controlada.
- Proyectos personales y académicos desglosados en tareas diarias.
- Recordatorios y alertas (push + in-app).
- Reportes de productividad (desde Fase 2, cuando hay historial suficiente).

Ver arquitectura elegida y alternativas descartadas en [`ARCHITECTURE.md`](ARCHITECTURE.md), y el
modelo de datos completo en [`DATA-MODEL.md`](DATA-MODEL.md).

## 5. Algoritmo del planificador (especificación completa)

Determinista, sin IA (ver justificación en
[`decisions/0004-scheduler-determinista-no-ia.md`](decisions/0004-scheduler-determinista-no-ia.md)).

### 5.1 Entradas

- Ventana de planificación `[from, to]` (por defecto: hoy → fin de semana visible).
- `busy`: ocupación expandida de `event_series` + `event_exceptions` + eventos manuales +
  `planned_sessions` con `locked = true`.
- `user_settings`: horario de sueño, máximo de minutos por día (global y por área), duración mínima
  de bloque, descanso mínimo entre bloques, buffers de traslado.
- `tasks` pendientes con `deadline`, `priority` (alta/media/baja), `estimated_minutes`,
  `logged_minutes` acumulados (vía `session_logs`).

### 5.2 Pseudocódigo

```
function plan(user, window):
    busy  = expand(event_series, event_exceptions, window)
            ∪ manual_events(window)
            ∪ locked_sessions(window)
    free  = subtract(window, busy, sleep_window(user), travel_buffers(user))
    slots = fragment(free, granularity = 30min, min_gap = user.min_break)

    queue = []
    for task in pending_tasks(user):
        remaining = task.estimated_minutes - logged_minutes(task)
        if remaining <= 0: continue

        hours_left = business_hours_until(task.deadline, window)
        slack      = hours_left / (remaining / 60)
        urgency    = 1 / max(slack, EPSILON)     # slack < 1 → tarea EN RIESGO

        score = W_URGENCY * urgency
              + W_PRIORITY * priority_weight(task.priority)
              - W_FRAGMENT * fragmentation_penalty(remaining)

        queue.push({ task, remaining, score })

    queue.sort_by(score, descending)

    assignments = []
    day_minutes = {}   # por día y por área, para respetar límites

    for item in queue:
        chunks = split_into_chunks(item.remaining, min_block = user.min_block_minutes)
        for chunk in chunks:
            slot = find_earliest_slot(slots, chunk.minutes,
                                       respecting = day_minutes,
                                       max_per_day = user.max_minutes_per_day,
                                       max_per_area = user.max_minutes_per_area[item.task.area])
            if slot is None:
                conflicts.push({ task: item.task, unassigned_minutes: chunk.minutes })
                continue

            assignments.push(session(item.task, slot, origin = AUTO))
            slots = consume(slots, slot, chunk.minutes)
            day_minutes[slot.day][item.task.area] += chunk.minutes

    return { assignments, conflicts }
```

### 5.3 Reglas de prioridad

1. **Urgencia por slack** domina: una tarea con menos margen que trabajo pendiente sube al tope,
   sin importar su prioridad declarada.
2. **Prioridad declarada** (alta/media/baja) desempata entre tareas con slack similar.
3. **Penalización por fragmentación**: preferir bloques continuos de tamaño razonable sobre trocear
   una tarea en fragmentos mínimos dispersos por la semana.

### 5.4 Límites duros (nunca se violan)

- Horario de sueño: nunca se planifica dentro de la ventana configurada por el usuario.
- `max_minutes_per_day`: tope global de trabajo planificado por día.
- `max_minutes_per_area`: tope por área (evita que todo el tiempo libre lo absorba un solo curso).
- `min_break` entre bloques consecutivos.

### 5.5 Conflictos — nunca fallar en silencio

Si al terminar quedan tareas con `unassigned_minutes > 0`, el planificador **reporta explícitamente**:
qué tarea, cuántos minutos sin espacio, y antes de qué deadline. No se inventa espacio violando límites
duros. La UI muestra el conflicto y sugiere acciones (bajar prioridad de otra tarea, mover deadline,
reducir alcance).

### 5.6 Reprogramación

Se dispara solo ante un evento concreto, nunca en cada carga de pantalla:

- Una `planned_session` se marca `SKIPPED`.
- Se crea una tarea nueva o cambia el `deadline` de una existente.
- El usuario lo pide explícitamente.

Reglas:

- **El pasado y el día en curso están congelados** — nunca se reescribe lo ya sucedido.
- Solo se replanifica **hacia adelante**, dentro de la ventana afectada.
- Toda `planned_session` con `locked = true` (confirmada por el usuario) se respeta como `busy` fijo,
  no se mueve.
- Cada corrida de planificación queda registrada con `plan_run_id`, para poder auditar qué cambió y
  por qué.

## 6. Capa de IA

Ver tabla de alcance y justificación completa en
[`decisions/0005-alcance-de-ia.md`](decisions/0005-alcance-de-ia.md). Resumen: dos funciones
(parseo de sílabo/texto libre → tareas estructuradas, y resumen semanal en lenguaje natural sobre
métricas ya calculadas). Todo lo demás es lógica determinista. Server-side únicamente, con
degradación explícita si la IA no responde (fallback a formulario manual / plantilla de texto).

## 7. Roadmap

Ver [`ROADMAP.md`](ROADMAP.md) para fases, tareas y criterios de aceptación verificables.

## 8. Calidad

- **Pruebas**: Vitest sobre el scheduler (lógica pura, sin DB) — casos de slack límite, deadline
  imposible, sesión omitida, respeto de `locked`, feriado como excepción. Playwright para 3 flujos
  críticos end-to-end (registro, carga de clases, generación de plan).
- **Manejo de errores**: toda operación contra Supabase o la API de IA tiene manejo explícito de
  fallo, sin pantallas rotas ni estados colgados.
- **Accesibilidad**: navegación por teclado completa, contraste AA, verificación con `axe` en CI.
- **Datos personales**: RLS como frontera real de aislamiento entre usuarios (verificado con pruebas
  cruzadas), recolección mínima de datos, export y borrado de cuenta.
