environment = "test"

vpc_cidr = "10.20.0.0/16"

public_subnets = {
  "us-east-1a" = "10.20.1.0/24"
  "us-east-1b" = "10.20.2.0/24"
}

private_subnets = {
  "us-east-1a" = "10.20.3.0/24"
  "us-east-1b" = "10.20.4.0/24"
}
