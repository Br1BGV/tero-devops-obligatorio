provider "aws" {
  region = var.aws_region

  # Se aplican automáticamente a todos los recursos que soportan etiquetas
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
