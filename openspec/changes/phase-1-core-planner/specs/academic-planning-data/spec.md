# Academic Planning Data Specification

## Purpose

Modelo de dominio: áreas, proyectos, clases recurrentes con excepciones, eventos manuales y tareas.
Es la fuente de datos que consume el scheduler y que se muestra en la vista semana.

## Requirements

### Requirement: Gestión de áreas y proyectos

El sistema MUST permitir crear, editar y archivar áreas (ej. UTP, ICPNA, trabajo, personal) y
proyectos asociados a un área.

#### Scenario: Crear área

- GIVEN un usuario autenticado
- WHEN crea un área con nombre y color
- THEN el área queda disponible para clasificar clases y tareas

#### Scenario: Archivar proyecto

- GIVEN un proyecto activo con tareas pendientes
- WHEN el usuario lo marca como archivado
- THEN el proyecto deja de ofrecerse como opción al crear nuevas tareas, pero las existentes no se eliminan

### Requirement: Clases recurrentes con excepciones

El sistema MUST permitir definir una clase recurrente (`event_series`) con días de la semana, horario
fijo y rango de validez, y registrar excepciones puntuales (`event_exceptions`) que cancelan o mueven
una ocurrencia específica sin alterar la serie completa.

#### Scenario: Crear clase recurrente

- GIVEN un usuario autenticado
- WHEN crea "Cálculo I" para lunes y miércoles 18:00-20:00 hasta el fin de ciclo
- THEN cada semana dentro del rango aparece la ocurrencia correspondiente en la vista semana

#### Scenario: Cancelar una ocurrencia por feriado

- GIVEN una clase recurrente activa
- WHEN el usuario marca como `CANCELLED` la ocurrencia de una fecha específica
- THEN esa fecha no aparece como ocupada, y las demás ocurrencias de la serie no se ven afectadas

#### Scenario: Mover una ocurrencia puntual

- GIVEN una clase recurrente activa
- WHEN el usuario registra una excepción `MOVED` con horario alternativo para una fecha
- THEN esa fecha se muestra con el horario alternativo, y el resto de la serie mantiene el horario original

### Requirement: Tareas con deadline y estimación

El sistema MUST permitir crear tareas con título, fecha límite, prioridad (alta/media/baja) y minutos
estimados, opcionalmente asociadas a un proyecto y un área.

#### Scenario: Crear tarea válida

- GIVEN un usuario autenticado
- WHEN crea una tarea con deadline futuro y minutos estimados positivos
- THEN la tarea queda en estado `pending`, disponible para el scheduler

#### Scenario: Rechazar estimación inválida

- GIVEN el formulario de creación de tarea
- WHEN el usuario intenta guardar minutos estimados menores o iguales a cero
- THEN el sistema MUST rechazar la operación y mostrar un error de validación
