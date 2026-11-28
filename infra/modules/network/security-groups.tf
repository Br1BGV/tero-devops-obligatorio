# ---------------------------------------------------------------
# ALB: única entrada desde internet
# ---------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Permite HTTP desde internet hacia el balanceador"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida hacia las tareas de ECS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

# ---------------------------------------------------------------
# Tareas de ECS: solo reciben tráfico del ALB y de otras tareas
# ---------------------------------------------------------------
resource "aws_security_group" "ecs" {
  name        = "${var.name_prefix}-ecs-sg"
  description = "Permite el puerto de la app solo desde el ALB y entre servicios"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Puerto de la app desde el ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Puerto de la app entre microservicios"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Salida a internet (ECR, CloudWatch, Secrets Manager) y a RDS y Redis"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ecs-sg"
  }
}

# ---------------------------------------------------------------
# RDS: solo acepta conexiones desde las tareas de ECS
# ---------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Permite PostgreSQL solo desde las tareas de ECS"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "PostgreSQL desde ECS"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  # RDS no necesita iniciar conexiones salientes.
  egress = []

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
}

# ---------------------------------------------------------------
# Redis: solo acepta conexiones desde las tareas de ECS
# ---------------------------------------------------------------
resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Permite Redis solo desde las tareas de ECS"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Redis desde ECS"
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  # Redis no necesita iniciar conexiones salientes.
  egress = []

  tags = {
    Name = "${var.name_prefix}-redis-sg"
  }
}
