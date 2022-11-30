# AWS EC2 Security Group Terraform Module
# Security Group for private Bastion 
# 使用module来建立Security Group

module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  name        = "private-sg"
  description = "Security Group with HTTP & SSH port open for entire VPC Block (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  
  ingress_rules = ["ssh-tcp", "http-80-tcp","http-8080-tcp"] //注意这里的8080端口一定要打开，后面的java app是跑在8080端口的
  ingress_cidr_blocks = ["0.0.0.0/0"] # Required for NLB
  
  egress_rules = ["all-all"]
  tags = local.common_tags 
}