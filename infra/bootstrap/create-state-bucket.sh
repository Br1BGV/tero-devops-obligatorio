#!/usr/bin/env bash
# Crea el bucket S3 del estado remoto de Terraform.
# Es el único recurso fuera de Terraform (Terraform necesita el bucket antes de existir).
# Idempotente: si el bucket ya existe, solo reaplica la configuración.
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET="tero-tfstate-${ACCOUNT_ID}"

if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "El bucket $BUCKET ya existe, reaplico configuración."
else
  echo "Creando bucket $BUCKET en $REGION..."
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
fi

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Listo: $BUCKET (versionado, cifrado AES256, sin acceso público)"
