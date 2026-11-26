# Infraestructura (Terraform)

Infraestructura de Tero en AWS definida con Terraform. Todo se crea desde este código, salvo el bucket del estado remoto.

## Estructura
infra/
├── bootstrap/create-state-bucket.sh # Crea el bucket S3 del estado (único recurso fuera de Terraform)
├── envs/
│ ├── {dev,test,prod}.backend.hcl # Backend por ambiente (un estado por ambiente)
│ └── {dev,test,prod}.tfvars # Valores por ambiente (sin secretos)
├── versions.tf # Versiones de Terraform y del provider; backend S3 parcial
├── providers.tf # Provider AWS y etiquetas por defecto
├── variables.tf # Variables con descripción y validación
├── main.tf # Data sources (cuenta, LabRole) y módulos
└── outputs.tf # Outputs documentados
## Prerrequisitos

- Terraform >= 1.10 (se usa `use_lockfile` para el bloqueo del estado)
- AWS CLI v2
- Credenciales vigentes del AWS Learner Lab (ver `docs/runbooks/credenciales-learner-lab.md`)

## Primer uso (una sola vez por cuenta)

```bash
./infra/bootstrap/create-state-bucket.sh
```

Crea `tero-tfstate-<ACCOUNT_ID>` con versionado, cifrado AES256 y acceso público bloqueado. Es idempotente. Si cambia la cuenta, actualizar `bucket` en `envs/*.backend.hcl`.

## Desplegar un ambiente

```bash
cd infra
ENV=dev   # dev | test | prod
terraform init -reconfigure -backend-config=envs/$ENV.backend.hcl
terraform plan  -var-file=envs/$ENV.tfvars
terraform apply -var-file=envs/$ENV.tfvars
```

`-reconfigure` es necesario al cambiar de ambiente para que Terraform apunte al estado correcto.

## Variables

| Variable | Descripción | Default |
|---|---|---|
| `project` | Prefijo de nombres de recursos | `tero` |
| `environment` | `dev`, `test` o `prod` (validado) | — (obligatoria) |
| `aws_region` | Región de AWS | `us-east-1` |

## Decisiones

- **Estado remoto en S3, uno por ambiente:** aísla los ambientes; un `destroy` en dev no puede afectar prod.
- **Bloqueo con `use_lockfile`:** evita applies simultáneos sin necesitar DynamoDB.
- **Estado cifrado (SSE-S3) y bucket privado:** el estado puede contener datos sensibles.
- **`LabRole` por data source:** el Learner Lab no permite crear roles de IAM.
- **Sin secretos en `.tfvars`:** por eso se versionan. Las credenciales nunca van al repo.

## Destruir un ambiente

```bash
terraform destroy -var-file=envs/$ENV.tfvars
```

El bucket del estado no se destruye con Terraform; se borra a mano al cerrar el proyecto.
