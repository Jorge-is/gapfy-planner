# 0005 — Alcance acotado de la capa de IA

## Contexto

El nombre del proyecto es "PlanIA" y existe la tentación de usar IA en todos lados (planificación,
priorización, chat). Hay que decidir dónde la IA realmente aporta frente a lógica determinista.

## Opciones consideradas

- **A. IA mínima**: solo donde el problema es de lenguaje natural no estructurado — parseo de
  sílabo/texto libre a tareas, y redacción de resúmenes sobre métricas ya calculadas por código.
- **B. IA como protagonista**: chat conversacional, sugerencias de replanificación, priorización vía
  modelo.

## Decisión

Se elige **A — IA mínima y acotada**.

## Consecuencias

- Dos funciones concretas con IA:
  1. Parsear sílabo/texto libre → tareas estructuradas (salida validada con Zod vía tool use/JSON
     schema, nunca texto libre sin validar).
  2. Resumen semanal en lenguaje natural: el LLM redacta sobre números que la aplicación ya calculó,
     nunca calcula las métricas él mismo.
- Todo lo demás (planificación, detección de huecos, priorización) queda fuera de la IA — ver
  [`0004-scheduler-determinista-no-ia.md`](0004-scheduler-determinista-no-ia.md).
- Costo controlado: pocas llamadas por usuario por semana, siempre server-side, con rate limit y
  timeout.
- Degradación explícita: si la IA falla o no está disponible, el parseo cae a un formulario manual y
  el resumen a una plantilla determinista con los mismos números. La app nunca depende de la IA para
  funcionar.
- El nombre "PlanIA" se mantiene honesto: la IA está presente y es útil, pero no es el corazón del
  producto — el corazón es el algoritmo de planificación.
