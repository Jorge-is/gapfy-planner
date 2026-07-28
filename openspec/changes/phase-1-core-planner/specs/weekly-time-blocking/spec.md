# Weekly Time Blocking Specification

## Purpose

Vista semanal donde el usuario ve su ocupación (clases + sesiones planificadas), dispara la
generación del plan, y registra el cumplimiento real de cada sesión.

## Requirements

### Requirement: Vista semana con time-blocking

El sistema MUST mostrar, para la semana seleccionada, las clases recurrentes expandidas (incluyendo
excepciones), los eventos manuales y las sesiones planificadas, en una grilla de tiempo.

#### Scenario: Semana con clases y sesiones

- GIVEN un usuario con clases recurrentes y sesiones planificadas dentro de la semana visible
- WHEN abre la vista semana
- THEN ve todos los bloques posicionados en su día y horario correcto

#### Scenario: Excepción reflejada en la vista

- GIVEN una clase con una ocurrencia cancelada por feriado
- WHEN el usuario ve la semana de esa fecha
- THEN el bloque de esa clase MUST NOT aparecer ese día específico

### Requirement: Generar plan semanal

El sistema MUST permitir disparar la generación del plan para la semana visible, ejecutando el
scheduler determinista sobre los datos reales del usuario y persistiendo el resultado como
`planned_sessions` asociadas a un `plan_run`.

#### Scenario: Generar plan con tareas pendientes

- GIVEN un usuario con al menos una tarea pendiente y huecos libres en la semana
- WHEN dispara "generar plan"
- THEN se crean sesiones planificadas visibles en la grilla, vinculadas al `plan_run` correspondiente

#### Scenario: Generar plan con conflictos

- GIVEN una tarea cuyo deadline no permite asignar todos sus minutos
- WHEN se genera el plan
- THEN el usuario MUST ver un aviso explícito del conflicto, no un plan silenciosamente incompleto

### Requirement: Marcar sesión cumplida u omitida

El sistema MUST permitir marcar una sesión planificada como cumplida (`DONE`), parcial (`PARTIAL`) u
omitida (`SKIPPED`), registrando un `session_log` asociado.

#### Scenario: Marcar sesión cumplida

- GIVEN una sesión planificada para hoy
- WHEN el usuario la marca como cumplida
- THEN se registra un `session_log` con `outcome = DONE` y la sesión refleja el estado en la vista

#### Scenario: Registrar trabajo no planificado

- GIVEN una tarea pendiente sin sesión planificada asociada
- WHEN el usuario registra tiempo trabajado directamente sobre la tarea
- THEN el sistema MUST crear un `session_log` con `planned_session_id` nulo, sin requerir una sesión previa
