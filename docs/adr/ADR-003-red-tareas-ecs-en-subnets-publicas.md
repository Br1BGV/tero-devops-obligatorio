# ADR-003: Red por ambiente y tareas de ECS en subnets públicas

- **Estado:** Aceptado
- **Fecha:** 2026-11-27
- **Tarjeta:** IAC-2

## Contexto

Cada ambiente (dev, test, prod) necesita su propia red en AWS. Las tareas de ECS Fargate tienen que salir a internet para descargar su imagen de ECR, enviar logs a CloudWatch y leer secretos. La base de datos (RDS) y Redis no deben ser accesibles desde internet. El presupuesto del AWS Learner Lab es limitado.

## Decisión

- Una VPC por ambiente, con rangos que no se superponen: dev `10.10.0.0/16`, test `10.20.0.0/16`, prod `10.30.0.0/16`.
- Dos zonas de disponibilidad (`us-east-1a` y `us-east-1b`), porque el ALB y RDS exigen subnets en al menos dos zonas.
- Subnets públicas (`.1` y `.2`) con ruta al Internet Gateway: ahí van el ALB y las tareas de ECS, con IP pública.
- Subnets privadas (`.3` y `.4`) sin ruta a internet: ahí van RDS y Redis.
- Security groups encadenados: `alb-sg` acepta HTTP desde internet; `ecs-sg` acepta el puerto de la app solo desde `alb-sg` y entre tareas; `rds-sg` y `redis-sg` aceptan su puerto solo desde `ecs-sg` y no tienen reglas de salida.
- La red es un módulo reutilizable (`infra/modules/network`) que cada ambiente llama con los valores de su `.tfvars`.

Es el mismo patrón del laboratorio de ECS del curso (servicio Fargate en subnets públicas con "Auto Assign Public IP").

## Alternativas descartadas

- **Tareas en subnets privadas con NAT Gateway:** aísla más las tareas (sin IP pública), pero el NAT cobra por hora en cada ambiente aunque no se use. Se descarta por costo en el Learner Lab.
- **VPC endpoints para ECR, CloudWatch y Secrets Manager:** evitan el NAT, pero también cobran por hora y por zona, y agregan varios recursos.
- **Una sola VPC compartida por los tres ambientes:** más barata de administrar, pero un error en dev podría afectar a prod.

## Consecuencias

- La salida a internet de las tareas no tiene costo extra.
- La protección de las tareas depende de una sola barrera: el security group `ecs-sg`. Si se abriera a `0.0.0.0/0`, las tareas quedarían expuestas. Se mitiga porque las reglas viven en Terraform, pasan por PR y se van a revisar con un escáner de IaC (Checkov) en el pipeline.
- RDS y Redis quedan sin ruta a internet y solo aceptan tráfico de las tareas, lo que resuelve la observación del auditor sobre la base y Redis publicados en puertos de la máquina.
- En una cuenta productiva, con presupuesto, se moverían las tareas a subnets privadas con NAT Gateway o VPC endpoints.
