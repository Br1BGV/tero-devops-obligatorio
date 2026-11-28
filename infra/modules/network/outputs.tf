output "vpc_id" {
  description = "ID de la VPC del ambiente."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "Rango de direcciones de la VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas, ordenadas por zona (para el ALB y las tareas de ECS)."
  value       = [for az in sort(keys(aws_subnet.public)) : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas, ordenadas por zona (para RDS y Redis)."
  value       = [for az in sort(keys(aws_subnet.private)) : aws_subnet.private[az].id]
}

output "alb_security_group_id" {
  description = "Security group del balanceador."
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "Security group de las tareas de ECS."
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "Security group de la base de datos RDS."
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Security group de Redis."
  value       = aws_security_group.redis.id
}
