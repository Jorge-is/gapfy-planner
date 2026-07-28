# Deterministic Scheduler Specification

## Purpose

Algoritmo puro y determinista (sin IA) que detecta huecos libres y asigna sesiones de estudio a
tareas pendientes por urgencia y prioridad, respetando límites duros del usuario. Ver `docs/PLAN.md §5`.

## Requirements

### Requirement: Detección de huecos libres

El sistema MUST calcular los bloques de tiempo libres dentro de una ventana, restando ocupación
(clases expandidas, eventos manuales, sesiones `locked`), horario de sueño y buffers de traslado.

#### Scenario: Ventana sin ocupación

- GIVEN una ventana de un día sin clases ni eventos registrados
- WHEN se calculan los huecos libres
- THEN el resultado excluye únicamente la ventana de sueño configurada

#### Scenario: Ventana completamente ocupada

- GIVEN un día con clases que cubren todo el horario fuera del sueño
- WHEN se calculan los huecos libres
- THEN el resultado es una lista vacía de slots

### Requirement: Asignación por urgencia y prioridad

El sistema MUST calcular, para cada tarea pendiente, un score en función del slack (horas disponibles
hasta el deadline dividido por horas restantes de trabajo) y la prioridad declarada, y asignar
primero las tareas de mayor score al slot disponible más temprano que las contenga.

#### Scenario: Tarea con slack menor a 1 tiene prioridad máxima

- GIVEN dos tareas pendientes, una con slack 0.8 y otra con slack 3, ambas con la misma prioridad
- WHEN se ejecuta la asignación
- THEN la tarea con slack 0.8 MUST recibir slots antes que la de slack 3

#### Scenario: Empate de slack se resuelve por prioridad declarada

- GIVEN dos tareas con slack equivalente, una de prioridad alta y otra de prioridad baja
- WHEN se ejecuta la asignación
- THEN la tarea de prioridad alta MUST recibir el slot disponible primero

### Requirement: Límites duros nunca se violan

El sistema MUST NOT asignar sesiones que excedan `max_minutes_per_day` (global o por área) ni que
caigan dentro del horario de sueño, y MUST respetar `min_break_minutes` entre bloques consecutivos.

#### Scenario: Tope diario alcanzado

- GIVEN que ya se asignaron `max_minutes_per_day` minutos en un día
- WHEN quedan tareas pendientes por asignar ese mismo día
- THEN el sistema MUST buscar slots en días posteriores dentro de la ventana, no exceder el tope

### Requirement: Reporte explícito de conflictos

El sistema MUST reportar, sin fallar en silencio, toda tarea que no pudo recibir todos sus minutos
estimados antes de su deadline dentro de la ventana planificada.

#### Scenario: Trabajo sin espacio disponible

- GIVEN una tarea cuyo deadline no deja huecos suficientes para sus minutos estimados
- WHEN se ejecuta la planificación
- THEN el resultado MUST incluir un conflicto identificando la tarea y los minutos sin asignar

### Requirement: Reproducibilidad

El sistema MUST producir el mismo resultado de asignación ante la misma entrada exacta (mismas
tareas, ocupación y configuración), sin aleatoriedad ni dependencia de servicios externos.

#### Scenario: Misma entrada, misma salida

- GIVEN un conjunto fijo de tareas, ocupación y configuración
- WHEN se ejecuta la función de planificación dos veces con esa misma entrada
- THEN ambas ejecuciones MUST producir asignaciones idénticas
