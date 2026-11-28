variable "project" {
  description = "Nombre del proyecto; prefijo de los nombres de recursos."
  type        = string
  default     = "tero"
}

variable "environment" {
  description = "Ambiente a desplegar (dev, test o prod)."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment debe ser dev, test o prod."
  }
}

variable "aws_region" {
  description = "Región de AWS donde se despliega."
  type        = string
  default     = "us-east-1"
}
