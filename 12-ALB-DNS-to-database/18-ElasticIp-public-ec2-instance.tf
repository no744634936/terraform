# Create Elastic IP for Bastion Host(要塞host，指的是public ec2 instance)
# 给public ec2 instance 分配一个不会变的elastic ip，一般来说可以不分配elastic ip
# Resource - depends_on Meta-Argument
resource "aws_eip" "bastion_eip" {
  # 注意 要vpc 跟 public instance 建立好之后才能分配elastic ip
  # This elastic ip resource will explicitly wait for till the bastion EC2 instance module.ec2_public is created.
  # This elastic ip resource will wait till all the VPC resources are created primarily the Internet Gateway IGW.
  depends_on = [  module.vpc,module.ec2_public ]
  
  instance = module.ec2_public.id[0]
  vpc      = true
  tags = local.common_tags

}