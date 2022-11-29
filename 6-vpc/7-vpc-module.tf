module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.0"

  # VPC Basic Details
  name = "${local.name}-${var.vpc_name}" //建成后的vpc名字为 HR-dev-testvpc
  cidr = var.vpc_cidr_block
  azs             = var.vpc_availability_zones
  public_subnets  = var.vpc_public_subnets //public subnets 自动被命名为 HR-dev-testvpc-public-ap-southeast-1a 和 HR-dev-testvpc-public-ap-southeast-1c
  private_subnets = var.vpc_private_subnets //private subnets 自动被命名为 HR-dev-testvpc-private-ap-southeast-1a 和 和 HR-dev-testvpc-private-ap-southeast-1c

  # Database Subnets
  database_subnets = var.vpc_database_subnets //datebase subnets 自动被命名为 HR-dev-testvpc-db-ap-southeast-1a 和 和 HR-dev-testvpc-db-ap-southeast-1c
  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  # create_database_internet_gateway_route = true
  # create_database_nat_gateway_route = true
  
  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway 
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
  }
  private_subnet_tags = {
    Type = "Private Subnets"
  }  
  database_subnet_tags = {
    Type = "Private Database Subnets"
  }
}

