# ADR-002: Estado remoto de Terraform y uso de LabRole

- **Estado:** Aceptado
- **Fecha:** 2026-11-27
- **Tarjeta:** IAC-1

## Contexto

Toda la infraestructura se define con Terraform y la pueden aplicar dos integrantes y el pipeline de CI/CD. Hay tres ambientes (dev, test, prod) en una sola cuenta del AWS Learner Lab, que tiene dos limitaciones: las credenciales son temporales y no se pueden crear roles de IAM (`iam:CreateRole` está bloqueado).

## Decisión 1: estado remoto en S3, uno por ambiente

- Bucket `tero-tfstate`, creado con `infra/bootstrap/create-state-bucket.sh` (único recurso fuera de Terraform: Terraform necesita el bucket antes de poder guardar su propio estado).
- Un archivo de estado por ambiente (`tero/<env>/terraform.tfstate`), con backend de configuración parcial (`envs/<env>.backend.hcl`).
- Versionado, cifrado SSE-S3 (AES256) y acceso público bloqueado.
- Bloqueo con `use_lockfile` (Terraform >= 1.10).

**Alternativas descartadas**
- *Estado local:* no se puede compartir entre integrantes ni con el pipeline.
- *Terraform Cloud:* agrega otra cuenta y otras credenciales; S3 ya está en la cuenta del proyecto.
- *Un único estado con workspaces:* un error en dev puede afectar prod; con estados separados cada ambiente queda aislado.
- *Bloqueo con DynamoDB:* era el método anterior; `use_lockfile` evita crear y pagar una tabla más.
- *Cifrado con KMS:* SSE-S3 cumple el requisito de estado cifrado sin crear ni pagar una clave.

## Decisión 2: LabRole por data source

Las tareas de ECS y la Lambda usan el rol existente `LabRole`, leído con `data "aws_iam_role"`.

**Alternativa preferida en una cuenta real:** un rol por servicio con permisos mínimos (privilegio mínimo), creado por Terraform. No es posible en el Learner Lab.

## Consecuencias

- Cualquier integrante (o el pipeline) puede aplicar cambios con el mismo estado y sin pisarse.
- Un `destroy` en un ambiente no afecta a los otros.
- Si se cambia de cuenta, hay que correr el script de bootstrap y actualizar `bucket` en los `.backend.hcl`.
- **Riesgo aceptado:** LabRole tiene más permisos de los necesarios. Se mitiga con security groups restrictivos y queda como mejora para una cuenta productiva.
