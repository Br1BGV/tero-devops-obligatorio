variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos."
  type        = string
}

variable "vpc_cidr" {
  description = "Rango de direcciones de la VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr debe ser un rango CIDR válido, por ejemplo 10.10.0.0/16."
  }
}

variable "public_subnets" {
  description = "Subnets públicas (ALB y tareas de ECS): zona de disponibilidad => CIDR."
  type        = map(string)

  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "Se necesitan al menos 2 subnets públicas en zonas distintas (lo exige el ALB)."
  }
}

variable "private_subnets" {
  description = "Subnets privadas (RDS y Redis): zona de disponibilidad => CIDR."
  type        = map(string)

  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "Se necesitan al menos 2 subnets privadas en zonas distintas (lo exige RDS)."
  }
}

variable "app_port" {
  description = "Puerto en el que escuchan los microservicios dentro del contenedor."
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Puerto de PostgreSQL."
  type        = number
  default     = 5432
}

variable "redis_port" {
  description = "Puerto de Redis."
  type        = number
  default     = 6379
}
