# Identidad de la cuenta con la que corre Terraform (para el ID de cuenta en outputs y nombres)
data "aws_caller_identity" "current" {}

# El Learner Lab no permite crear roles de IAM: usamos el rol que ya existe.
# Lo van a usar las tareas de ECS (IAC-3) y la Lambda (semana 5).
data "aws_iam_role" "lab" {
  name = "LabRole"
}

locals {
  # Prefijo común para nombrar recursos: tero-dev, tero-test, tero-prod
  name_prefix = "${var.project}-${var.environment}"
}

# Módulos a agregar:
# IAC-2: module "network"  (VPC, subnets, security groups)
# IAC-3: module "ecs_service" por microservicio, ECR y ALB
# IAC-4: RDS PostgreSQL y ElastiCache Redis
