output "account_id" {
  description = "ID de la cuenta de AWS donde se desplegó la infraestructura."
  value       = data.aws_caller_identity.current.account_id
}

output "environment" {
  description = "Ambiente desplegado (dev, test o prod)."
  value       = var.environment
}

output "name_prefix" {
  description = "Prefijo usado en los nombres de los recursos de este ambiente."
  value       = local.name_prefix
}

output "lab_role_arn" {
  description = "ARN del LabRole que usan ECS y Lambda (el Learner Lab no permite crear roles)."
  value       = data.aws_iam_role.lab.arn
}
