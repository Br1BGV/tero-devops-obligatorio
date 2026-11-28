environment = "prod"

vpc_cidr = "10.30.0.0/16"

public_subnets = {
  "us-east-1a" = "10.30.1.0/24"
  "us-east-1b" = "10.30.2.0/24"
}

private_subnets = {
  "us-east-1a" = "10.30.3.0/24"
  "us-east-1b" = "10.30.4.0/24"
}
