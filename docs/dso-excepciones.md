# Excepciones DevSecOps (DSO)

## EXC-001 — Hallazgos de Gitleaks en historial inicial

### Contexto

El commit inicial (`56fd8cb`) incluyó credenciales de desarrollo que ya fueron removidas en
commits posteriores. Como esas cadenas siguen presentes en el historial git, Gitleaks puede
detectarlas al escanear todo el repositorio.

### Decisión

Se acepta una excepción acotada para esos hallazgos históricos y se documenta en
`.gitleaksignore`. La excepción aplica solo al material legado del commit inicial y no habilita
ignorar hallazgos nuevos.

### Justificación

- Reescribir historial no aporta valor funcional para la entrega actual.
- Los secretos vigentes no se almacenan en el repositorio.
- Los valores sensibles operativos se gestionan en AWS SSM Parameter Store.

### Controles compensatorios

- Gitleaks se mantiene activo en CI para bloquear nuevos secretos.
- Cualquier fingerprint nuevo debe tratarse como incidente y corregirse en código.
- Revisión manual en PR para cambios de `docker-compose`, `.env`, Terraform y workflows.

### Alcance IaC

Para cumplir con IaC por ambiente, el repositorio versiona `infra/envs/*.tfvars` solo con
parámetros no sensibles. Los secretos quedan fuera de esos archivos y se referencian desde SSM.
