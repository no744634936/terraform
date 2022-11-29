module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.0"

  # VPC Basic Details
  name = "vpc-dev"
  cidr = "10.0.0.0/16"

  azs                 = ["ap-southeast-1a", "ap-southeast-1c"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24"]

  # Database Subnets 
  create_database_subnet_group = true
  database_subnets    = ["10.0.151.0/24", "10.0.152.0/24"]
  create_database_subnet_route_table= true #什么意思，看readme文件
  #create_database_nat_gateway_route = true
  #create_database_internet_gateway_route = true

  # NAT Gateways - Outbound Communication，
  # 打开 nat gateway，所有private subnets 共用一个nat gateway
  # internet gateway 在public subnets 建立的时候就自动建好了，所以不用额外参数来建立
  # single_nat_gateway = true 的含义是多个private subnets可以共用一个nat gateway
  enable_nat_gateway = true
  single_nat_gateway = true

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support = true  //Should be true to enable DNS support in the VPC



  # 这些tag名暂时不用管
  public_subnet_tags = {
    Type = "public-subnets"
  }

  private_subnet_tags = {
    Type = "private-subnets"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  tags = {
    Owner = "zhanghaifeng"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-dev"
  }
}

