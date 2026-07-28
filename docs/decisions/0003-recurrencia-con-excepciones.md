# 0003 — Recurrencia con excepciones, no materialización de ocurrencias

## Contexto

Las clases (UTP, ICPNA) se repiten semanalmente durante todo un ciclo, con posibles feriados o
reprogramaciones puntuales. Hay que representar esto en el modelo de datos.

## Opciones consideradas

- **A. Materializar cada ocurrencia** como una fila (una clase de lunes a miércoles durante 16 semanas
  = 32 filas por curso).
- **B. Una fila por serie recurrente** (`event_series`, con `byweekday`, horario y rango de validez) +
  tabla de excepciones (`event_exceptions`) para los casos que rompen el patrón, expandiendo las
  ocurrencias reales en tiempo de consulta.

## Decisión

Se elige **B**.

## Consecuencias

- El volumen de datos se mantiene bajo: una serie por curso, no decenas de filas repetidas.
- Editar el horario de una clase para lo que resta del ciclo es una sola actualización, no un update
  masivo.
- Los casos reales (feriado, clase reprogramada) quedan explícitos por fecha en `event_exceptions`,
  sin ambigüedad sobre qué ocurrencia puntual cambió.
- Costo: la expansión de ocurrencias es lógica de aplicación (o función SQL), no una simple lectura de
  tabla. Se resuelve con una función pura y testeada, reutilizada tanto por las vistas de calendario
  como por el planificador.
