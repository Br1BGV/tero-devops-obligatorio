# Backlog del proyecto

Listado completo de tareas para cargar en el tablero Kanban. Los épicos siguen las secciones
de la rúbrica de evaluación, de modo que el tablero sea trazable contra lo que se corrige.

**Columnas sugeridas del tablero:** `Backlog` → `To Do` → `In Progress` → `In Review` → `Done`

> Recordatorio: capturar el estado del tablero en tres momentos (inicio, mitad y cierre).
> La captura de inicio se saca apenas estas tareas estén cargadas, antes de mover nada.

---

## Restricciones de AWS Academy Learner Lab

Condicionan varias tareas, conviene tenerlas presentes antes de estimar:

| Restricción | Consecuencia para el proyecto |
|---|---|
| Credenciales temporales que rotan en cada sesión | Los secrets de AWS en GitHub Actions hay que refrescarlos al inicio de cada jornada de trabajo. No se puede usar OIDC. |
| No se pueden crear roles ni políticas de IAM | Terraform debe **consumir** `LabRole` con un `data source`, nunca crearlo. |
| El laboratorio se apaga al cerrar la sesión | Los despliegues deben ser rápidos de recrear. Esto juega a favor en la defensa. |
| Presupuesto acotado (~USD 100) | Evitar NAT Gateway y EKS. Fargate en subnets públicas. |
| Región restringida | Trabajar siempre en `us-east-1`. |

---

## Épico 0 — Puesta a punto del equipo

| ID | Tarea | Criterio de terminado |
|---|---|---|
| SETUP-1 | Inscribir el equipo en Gestión y en la planilla de alumnos | Los 2 integrantes figuran inscriptos |
| SETUP-2 | Instalar toolchain en las 2 máquinas: Docker Desktop, Go 1.24, Terraform, AWS CLI, GitHub CLI | `docker compose up` levanta Tero localmente en las 2 |
| SETUP-3 | Crear el tablero Kanban y cargar este backlog | Tablero con todas las tareas en `Backlog` |
| SETUP-4 | Captura del tablero: estado inicial | Imagen guardada en `docs/evidencias/tablero-inicio.png` |
| SETUP-5 | Verificar acceso de los 2 al Learner Lab y anotar cómo obtener credenciales | Procedimiento escrito en `docs/` |

## Épico 1 — Control de versiones y colaboración

| ID | Tarea | Criterio de terminado |
|---|---|---|
| GIT-1 | Documentar y justificar la estrategia de ramificación | `docs/estrategia-ramificacion.md` |
| GIT-2 | Configurar Branch Protection sobre `main` | Push directo bloqueado, 1 aprobación obligatoria |
| GIT-3 | Exigir checks de CI verdes antes del merge | Checks marcados como *required* |
| GIT-4 | Abrir y revisar el PR de gestión de secretos | PR mergeado con comentarios de revisión reales |
| GIT-5 | Abrir y revisar un segundo PR con revisión documentada | PR mergeado con comentarios de revisión reales |
| GIT-6 | Capturar los PRs revisados como evidencia | Imágenes en `docs/evidencias/` |

## Épico 2 — Gestión de secretos

| ID | Tarea | Criterio de terminado |
|---|---|---|
| SEC-1 | Sacar credenciales del `docker-compose.yml` hacia `.env` | Compose aborta si falta una variable |
| SEC-2 | Eliminar los defaults hardcodeados de `src/admin/src/app.ts` | El servicio falla al arrancar sin las variables |
| SEC-3 | Crear `.gitignore` y `.env.example` | `.env` fuera del control de versiones |
| SEC-4 | Cargar los secretos de AWS como GitHub Secrets | Pipeline autentica contra AWS |
| SEC-5 | Guardar los secretos de aplicación en SSM Parameter Store | Las tareas ECS los leen desde SSM, no del task definition |
| SEC-6 | Escribir el procedimiento de rotación de credenciales | Runbook en `docs/` — **lo piden en la defensa** |

## Épico 3 — Containerización

| ID | Tarea | Criterio de terminado |
|---|---|---|
| DOCK-1 | Dockerfile multi-stage para `catalog` (Go → distroless, no-root) | Imagen funcional y de tamaño reducido |
| DOCK-2 | Dockerfile multi-stage para `orders` (Go → distroless, no-root) | Imagen funcional y de tamaño reducido |
| DOCK-3 | Dockerfile multi-stage para `cart` (Python → slim, no-root) | Imagen funcional y de tamaño reducido |
| DOCK-4 | Dockerfile multi-stage para `checkout` (Node → alpine, no-root) | Imagen funcional y de tamaño reducido |
| DOCK-5 | Dockerfile multi-stage para `ui` (Node → alpine, no-root) | Imagen funcional y de tamaño reducido |
| DOCK-6 | Dockerfile multi-stage para `admin` (Node → alpine, no-root) | Imagen funcional y de tamaño reducido |
| DOCK-7 | Agregar `.dockerignore` a los seis servicios | El contexto de build no incluye `node_modules` ni `.git` |
| DOCK-8 | Generar lockfiles faltantes para builds reproducibles | `npm ci` funciona en `ui` y `admin` |
| DOCK-9 | Dejar de publicar los puertos de `db` y `redis` en el host | Solo accesibles desde la red interna del compose |
| DOCK-10 | Tabla comparativa de tamaños de imagen antes/después | Evidencia documentada del punto 3.1 |

## Épico 4 — Testing y calidad

| ID | Tarea | Criterio de terminado |
|---|---|---|
| TEST-1 | Colección de pruebas funcionales del flujo catálogo → carrito → checkout → orden | Corre con Newman contra el stack levantado |
| TEST-2 | Prueba de carga con k6 sobre el endpoint de catálogo | Script versionado y resultados documentados |
| TEST-3 | Integrar el análisis estático en CI (SonarCloud o Semgrep) | El job corre en cada PR |
| TEST-4 | Definir umbrales de calidad como quality gate | El pipeline falla si no se cumplen |
| TEST-5 | Redactar el informe de interpretación de resultados | Párrafo con hallazgos y recomendaciones |

## Épico 5 — DevSecOps

| ID | Tarea | Criterio de terminado |
|---|---|---|
| DSO-1 | Integrar Gitleaks como detector de secretos | El build falla si detecta credenciales |
| DSO-2 | Integrar Trivy en modo filesystem (SCA de dependencias) | Reporta CVEs de las dependencias |
| DSO-3 | Integrar Semgrep como SAST | Corre sobre Go, Python y TypeScript |
| DSO-4 | Escanear cada imagen con Trivy **antes** del push al registry | Imagen vulnerable no llega a ECR |
| DSO-5 | Configurar el gate que bloquea ante CRITICAL/HIGH sin parche | Documentado el criterio de excepción |
| DSO-6 | Documentar hallazgos, remediaciones y excepciones justificadas | Informe en `docs/` |

## Épico 6 — Infraestructura como código

| ID | Tarea | Criterio de terminado |
|---|---|---|
| IAC-1 | Crear bucket S3 para el estado remoto (único recurso fuera de Terraform) | Backend configurado y versionado |
| IAC-2 | Módulo de red: VPC, subnets públicas, security groups | Reutilizable entre ambientes |
| IAC-3 | Módulo de servicio ECS Fargate, parametrizado | Reutilizado por los seis microservicios |
| IAC-4 | Módulo de base de datos: RDS PostgreSQL | Credenciales desde SSM |
| IAC-5 | Redis: definir si ElastiCache o tarea Fargate según presupuesto | Decisión registrada como ADR |
| IAC-6 | Repositorios ECR para las seis imágenes | Creados por Terraform |
| IAC-7 | Application Load Balancer con routing hacia `ui` y `admin` | URL pública funcionando |
| IAC-8 | Archivos `.tfvars` diferenciados para Dev, Test y Prod | Tres ambientes parametrizados |
| IAC-9 | Consumir `LabRole` vía data source en lugar de crear roles IAM | `terraform apply` funciona en el Learner Lab |
| IAC-10 | Documentar los outputs con descripción | Todos los outputs tienen `description` |

## Épico 7 — Serverless

| ID | Tarea | Criterio de terminado |
|---|---|---|
| SRV-1 | Definir el propósito de la Lambda y registrarlo como ADR | Propósito ligado a seguridad u observabilidad |
| SRV-2 | Implementar la Lambda de notificación de hallazgos y alarmas | Código versionado |
| SRV-3 | Desplegar la Lambda con Terraform e integrarla con SNS y CloudWatch | Se dispara ante una alarma real |
| SRV-4 | Demostrar una notificación end-to-end | Captura de la notificación recibida |

## Épico 8 — Observabilidad

| ID | Tarea | Criterio de terminado |
|---|---|---|
| OBS-1 | Pasar los logs de los seis servicios a formato JSON estructurado | Logs parseables |
| OBS-2 | Centralizar los logs en CloudWatch Logs | Un log group por ambiente, con búsqueda y filtros |
| OBS-3 | Habilitar métricas de infraestructura (Container Insights) | CPU, memoria y red visibles |
| OBS-4 | Exponer y recolectar las métricas de aplicación que ya existen | Latencia, errores y throughput |
| OBS-5 | Construir el dashboard de operación | Al menos un dashboard con métricas relevantes |
| OBS-6 | Alerta de disponibilidad, con trigger y procedimiento de respuesta | Documentada y probada |
| OBS-7 | Alerta de rendimiento o uso de recursos, con trigger y respuesta | Documentada y probada |

## Épico 9 — CI/CD

| ID | Tarea | Criterio de terminado |
|---|---|---|
| CI-1 | Workflow base de CI: build y tests en cada PR | Corre en los seis servicios |
| CI-2 | Agregar las etapas de calidad y seguridad al workflow | Las seis etapas que pide la letra |
| CI-3 | Build y push de imágenes a ECR con tag inmutable | La versión en ejecución es identificable |
| CI-4 | Pipeline de despliegue a Dev | Despliegue automático |
| CI-5 | Pipeline de despliegue a Test con quality gate | No promueve si falla el gate |
| CI-6 | Pipeline de despliegue a Prod con aprobación manual | GitHub Environment con required reviewers |
| CI-7 | Promoción del artefacto por digest, sin reconstruir | La imagen de Prod es la misma validada en Test |
| CI-8 | Procedimiento de rollback a la versión anterior | Runbook probado — **lo piden en la defensa** |

## Épico 10 — Documentación y entrega

| ID | Tarea | Criterio de terminado |
|---|---|---|
| DOC-1 | README completo con despliegue, variables y prerrequisitos | Alguien externo puede levantar el proyecto |
| DOC-2 | Diagrama de arquitectura general | Incluido en la documentación |
| DOC-3 | Diagrama del pipeline CI/CD con las etapas de seguridad | Incluido en la documentación |
| DOC-4 | Diagrama del branching model | Incluido en la documentación |
| DOC-5 | ADRs de las decisiones de diseño relevantes | Mínimo las decisiones de nube, orquestador y ramificación |
| DOC-6 | Lecciones aprendidas | Sección en la documentación |
| DOC-7 | Declaración de uso de IA generativa | Herramientas y contexto de uso, según exige la letra |
| DOC-8 | Captura del tablero: estado intermedio | `docs/evidencias/tablero-mitad.png` |
| DOC-9 | Captura del tablero: estado de cierre | `docs/evidencias/tablero-cierre.png` |
| DOC-10 | Armar el ZIP de entrega de menos de 40 MB | Subido a Gestión antes del 07/12 a las 21:00 |
| DOC-11 | Ensayar la defensa: rollback, rotación de credencial y diagnóstico de pipeline | Los 2 integrantes pueden ejecutar cualquiera de las tres |
