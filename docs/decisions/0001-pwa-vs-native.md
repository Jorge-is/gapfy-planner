# 0001 — PWA en lugar de app nativa (React Native / Expo)

## Contexto

Se necesita una app usable en celular y computadora, con un enlace público apto para CV, presupuesto
cercano a cero, y un desarrollador con 5-8 h/semana disponibles.

## Opciones consideradas

- **A. PWA (Next.js)**: una sola base de código web, instalable desde el navegador.
- **B. React Native / Expo** (con o sin RN Web): app nativa real, con posible versión web secundaria.

## Decisión

Se elige **A — PWA**.

## Consecuencias

- El requisito "enlace para el CV" se cumple de forma directa: la URL de producción *es* la app.
- Un solo runtime que mantener con tiempo limitado, en vez de dos (nativo + web).
- Se pierde algo de calidad de push notifications en iOS frente a nativo (mitigado: iOS 16.4+ soporta
  Web Push en PWA instalada; documentado como limitación conocida).
- No hay publicación en App Store / Play Store ni sus costos ($99-125/año) ni su proceso de revisión.
- Si en el futuro se necesita una app store real, el frontend en Next.js no se descarta: se puede
  envolver con Capacitor sin reescribir la lógica de negocio.
