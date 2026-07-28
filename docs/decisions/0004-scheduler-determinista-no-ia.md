# 0004 — El planificador es determinista, no usa IA

## Contexto

El planificador automático es la pieza diferencial del proyecto frente a un calendario cualquiera.
Existe la tentación de resolverlo con un LLM ("dale tus tareas y que la IA arme tu semana").

## Opciones consideradas

- **A. Algoritmo determinista** (greedy con scoring por urgencia/prioridad, descrito en `PLAN.md`).
- **B. Planificación vía LLM**: pasar tareas y disponibilidad a un modelo y pedirle el horario.

## Decisión

Se elige **A — determinista**.

## Consecuencias

- Reproducible: la misma entrada siempre produce la misma salida, algo indispensable para poder
  confiar en que el sistema no te deja plantado en un examen.
- Testeable con Vitest sin mocks de red ni de IA: casos de borde (deadline imposible, slack límite,
  sesión omitida) se verifican con precisión exacta, no con evaluación aproximada de texto.
- Gratis y rápido: sin llamadas a API externa en el camino crítico de cada carga de plan.
- Es, además, mejor señal técnica de portafolio: demuestra diseño de algoritmos propio, no una llamada
  a un modelo de terceros.
- La IA se reserva para donde sí aporta valor real: texto no estructurado (parseo de sílabo) y
  redacción de resúmenes sobre datos ya calculados. Ver
  [`0005-alcance-de-ia.md`](0005-alcance-de-ia.md).
