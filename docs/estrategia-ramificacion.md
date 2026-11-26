# Estrategia de ramificación

## Modelo adoptado: GitHub Flow

Una única rama de larga vida, `main`, que siempre debe estar en estado desplegable. Todo
cambio nace en una rama corta que sale de `main`, se integra mediante Pull Request con
revisión de otro integrante, y se elimina al mergear.

```
main ──●──────●──────────●──────────●───▶
        \    /          /          /
         ●──●          /          /        feature/gestion-de-secretos
              \       /          /
               ●─────●          /          feature/dockerfiles-multistage
                      \        /
                       ●──────●            feature/pipeline-ci
```

### Convención de nombres de rama

| Prefijo     | Uso                                     | Ejemplo                          |
|-------------|-----------------------------------------|----------------------------------|
| `feature/`  | Funcionalidad o mejora                  | `feature/pipeline-ci`            |
| `fix/`      | Corrección de defecto                   | `fix/healthcheck-postgres`       |
| `docs/`     | Cambios únicamente de documentación     | `docs/diagramas-arquitectura`    |

## Justificación de la elección

La letra sugiere tres opciones. Descartamos las otras dos por razones concretas de este
proyecto:

**Git Flow** separa `develop`, `release/*` y `hotfix/*` además de `main`. Ese modelo resuelve
el problema de mantener varias versiones en producción simultáneamente y coordinar releases
con fecha. Tero no tiene ese problema: hay un solo producto, una sola versión viva y un
equipo de dos personas trabajando en paralelo durante dos semanas. El costo de mantener
ramas de release y los merges cruzados entre `develop` y `main` sería ceremonia pura, y
aumentaría el riesgo de conflictos sin aportar control real.

**Trunk-Based Development con feature flags** es el modelo con mejor latencia de integración,
pero exige infraestructura de feature flags y una disciplina de tests muy madura para que
commits incompletos convivan en `main` sin romperlo. Tero parte de cero pruebas
automatizadas, así que el prerequisito no se cumple.

**GitHub Flow** encaja porque el equipo es chico y co-ubicado, las unidades de trabajo son
cortas (un Dockerfile, un módulo de Terraform, un workflow), y cada cambio puede validarse de
forma independiente antes de integrarse. Además es el modelo que mejor se acopla a las
protecciones de rama y a los GitHub Environments que usamos como quality gates: un PR dispara
el pipeline de CI completo, y la promoción entre ambientes ocurre después del merge sobre un
artefacto ya validado.

## Reglas de protección sobre `main`

Configuradas en GitHub (Settings → Branches → Branch protection rules):

- Prohibido el push directo a `main`; todo entra por Pull Request.
- Mínimo una aprobación de un revisor **distinto del autor**.
- Los checks de CI (tests, análisis de calidad, SCA, SAST, detección de secretos) deben pasar
  antes de habilitar el merge.
- Se descartan las aprobaciones si se pushean commits nuevos al PR.

## Relación con el pipeline

| Evento                     | Qué se ejecuta                                      | Ambiente destino |
|----------------------------|-----------------------------------------------------|------------------|
| Push a rama `feature/*`    | Build, tests, calidad, SCA, SAST, secretos          | ninguno          |
| Pull Request hacia `main`  | Lo anterior + build y escaneo de la imagen          | Dev              |
| Merge a `main`             | Publicación de imagen etiquetada y despliegue       | Test             |
| Aprobación manual          | Promoción del mismo artefacto, sin reconstruir      | Prod             |

La imagen se construye una sola vez y se promueve entre ambientes por su digest. Esto es lo
que permite responder con certeza qué versión está corriendo, que es una de las
observaciones del auditor.
