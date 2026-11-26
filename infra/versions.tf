terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Configuración parcial: los datos concretos llegan con -backend-config=envs/<env>.backend.hcl
  backend "s3" {}
}
