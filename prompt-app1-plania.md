# Prompt para Claude Code — App 1: "PlanIA" (planificación académica y de tiempo)

## PROMPT (copiar desde aquí)

Actúa como arquitecto de software senior. **En este primer paso NO escribas código de la aplicación.** Tu única entrega es un plan técnico completo, discutido y aprobado conmigo antes de implementar.

### Contexto

Soy Jorge, estudiante de Ingeniería de Software en la UTP (Lima, Perú). Llevo clases en la universidad, un curso de inglés en el ICPNA y trabajo en proyectos académicos y personales, horarios laborales. Este proyecto tiene un doble objetivo: **resolver mi día a día real** y **servir como pieza de mi portafolio**.

Ya validé un MVP como prototipo, con planificación y detección automática de huecos libres. Ahora quiero la aplicación completa.

### Qué debe hacer la aplicación

- Vistas de día, semana y mes con time-blocking.
- Clases recurrentes (UTP e ICPNA) con horario fijo semanal y fecha de fin de ciclo.
- Exámenes, exposiciones, tareas y entregas con fecha límite, prioridad y horas estimadas.
- Detección automática de bloques de tiempo libre.
- Planificador que asigna sesiones de estudio y trabajo profundo a esos huecos, priorizando por urgencia e importancia, y que reprograma solo cuando incumplo algo.
- Proyectos personales y académicos desglosados en tareas diarias.
- Recordatorios y alertas.
- Reportes de productividad: cumplimiento de sesiones, entregas a tiempo, distribución de horas por área.

### Restricciones

- Debe funcionar bien en celular y computadora.
- Presupuesto cercano a cero: prioriza servicios con capa gratuita.
- Debe poder desplegarse públicamente con un enlace que yo pueda poner en mi CV.
- Idioma de la interfaz y documentación técnica: español. Código, commits: inglés.

### Lo que quiero que hagas

1. **Pregúntame primero.** Antes de planificar, hazme las preguntas que necesites para cerrar las decisiones importantes (autenticación, si habrá varios usuarios o solo yo, integración con Google Calendar, funcionamiento offline, cómo se entregan los recordatorios). Máximo 8 preguntas, agrupadas y concretas. Espera mis respuestas antes de continuar.

2. **Evalúa alternativas de arquitectura.** Presenta 2 o 3 opciones reales (por ejemplo: full-stack con backend propio vs. React + Backend-as-a-Service) con tabla comparativa de esfuerzo, costo, escalabilidad y valor para el portafolio. Da tu recomendación y defiéndela.

3. **Diseña el modelo de datos.** Entidades, relaciones, claves e índices, en diagrama y en DDL. Presta atención especial a: eventos recurrentes con excepciones, y la relación entre tareas, sesiones planificadas y sesiones cumplidas.

4. **Define el algoritmo del planificador automático** en pseudocódigo, con sus reglas de prioridad, límites (máximo de horas por día, descansos, horario de sueño) y comportamiento ante reprogramaciones. Este es el corazón del proyecto y lo que lo diferencia de un calendario cualquiera: trátalo con ese nivel de detalle.

5. **Especifica la capa de IA.** Qué funciones la usan realmente, con qué prompts, cómo se controlan costo y errores, y qué pasa cuando la IA no está disponible. Sé escéptico: descarta lo que se resuelva mejor con lógica determinista.

6. **Entrega un roadmap por fases**, con la Fase 1 acotada a algo desplegable y usable en 3 o 4 semanas a mi ritmo. Cada fase con criterios de aceptación verificables.

7. **Define la calidad**: estrategia de pruebas, manejo de errores, accesibilidad y protección de datos personales.

### Formato de entrega

Después de que responda tus preguntas, crea estos archivos en el repositorio:

- `docs/PLAN.md` — el plan completo.
- `docs/ARCHITECTURE.md` — arquitectura, stack elegido y diagramas.
- `docs/DATA-MODEL.md` — entidades, diagrama y DDL.
- `docs/ROADMAP.md` — fases, tareas y criterios de aceptación.
- `docs/decisions/` — un ADR corto por decisión importante (contexto, opciones, decisión, consecuencias).

Sé directo y crítico. Si algo de lo que pido es mala idea, sobredimensionado para un solo desarrollador, o no me conviene para el portafolio, dímelo y propón la alternativa. Prefiero un alcance más pequeño y terminado que uno ambicioso y abandonado.

Empieza por las preguntas.

## (fin del prompt)

---

### Para arrancar la implementación

Cuando el plan esté aprobado:

> Implementa la Fase 1 según `docs/ROADMAP.md`. Trabaja tarea por tarea: al terminar cada una, muéstrame el diff y espera mi visto bueno antes de seguir. Haz commit al cerrar cada tarea.
