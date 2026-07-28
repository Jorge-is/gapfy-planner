# Skill Registry — Gapfy

Generado por `sdd-init`. Escanea skills de usuario y convenciones del proyecto para inyectar reglas
compactas en cada sub-agente delegado.

## User Skills relevantes

Ninguna skill de usuario coincide con el stack de este proyecto (Next.js/React/TypeScript/Supabase).
`go-testing` no aplica (proyecto es TypeScript, no Go). Sin skills de frontend instaladas — los
sub-agentes de `sdd-apply` deben seguir las convenciones documentadas en `docs/ARCHITECTURE.md` y
`docs/DATA-MODEL.md` directamente.

## Convenciones del proyecto (de `~/.claude/CLAUDE.md`, global)

### Compact Rules

- **Commits**: conventional commits, en inglés, sin atribución de coautoría de IA.
- **Idioma**: UI y documentación técnica en español; código y commits en inglés.
- **Build**: nunca ejecutar build tras cambios salvo pedido explícito.
- **Shell**: preferir `bat`/`rg`/`fd`/`sd`/`eza` sobre `cat`/`grep`/`find`/`sed`/`ls` cuando estén
  disponibles.
- **Verificación técnica**: no afirmar sin verificar; si hay incertidumbre, investigar antes de
  responder.

### Stack (planeado, ver `docs/ARCHITECTURE.md`)

Next.js 15 App Router + TypeScript + Tailwind + shadcn/ui (PWA) · Supabase (Postgres + Auth + RLS) ·
Claude API server-side · Vitest + Playwright.

## Trigger Table

| Contexto de código               | Regla a inyectar                                                             |
| -------------------------------- | ---------------------------------------------------------------------------- |
| `*.ts`, `*.tsx`                  | Código y comentarios en inglés; UI visible en español                        |
| `*.sql`, `openspec/*` (DDL, RLS) | Seguir DDL de `docs/DATA-MODEL.md`; toda tabla de usuario lleva política RLS |
| Cualquier commit                 | Conventional commits en inglés, sin coautoría de IA                          |
| `docs/*.md`, ADRs                | Español                                                                      |
