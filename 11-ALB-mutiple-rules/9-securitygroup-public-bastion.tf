# AWS EC2 Security Group Terraform Module
# Security Group for Public Bastion 
# 使用module来建立Security Group

module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  name        = "public-bastion-sg"
  description = "Security group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  # Ingress Rules & CIDR Block ，inbound
  ingress_rules = ["ssh-tcp"]         //ssh 默认打开22端口
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open ，oubound
  egress_rules = ["all-all"]         //设置为["0.0.0.0/0"]
  tags = local.common_tags  
}