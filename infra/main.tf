# Identidad de la cuenta con la que corre Terraform (para el ID de cuenta en outputs y nombres)
data "aws_caller_identity" "current" {}

# Lo van a usar las tareas de ECS (IAC-3) y la Lambda (semana 5).
data "aws_iam_role" "lab" {
  name = "LabRole"
}

locals {
  # Prefijo común para nombrar recursos: tero-dev, tero-test, tero-prod
  name_prefix = "${var.project}-${var.environment}"
}

# Red del ambiente: VPC, subnets públicas y privadas, security groups (IAC-2)
module "network" {
  source = "./modules/network"

  name_prefix     = local.name_prefix
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# Próximos módulos:
# IAC-3: ECS Fargate, ECR y ALB (usan module.network.public_subnet_ids y los security groups)
# IAC-4: RDS PostgreSQL y Redis (usan module.network.private_subnet_ids)
