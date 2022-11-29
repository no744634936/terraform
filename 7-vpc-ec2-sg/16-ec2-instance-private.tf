# AWS EC2 Instance Terraform Module
# EC2 Instances that will be created in VPC Private Subnets
module "ec2_private" {
  # 注意这里有一个重要的知识点， depends_on = [ module.vpc ] 的意思是vpc建立好之后再建立ec2 instance
  # 这是因为private ec2 instance需要通过 vpc中的 NAT gateway 按nginx-install.sh文件去下载nginx
  # 而NAT gateway的建立是比较花时间，所以当ec2建立好并准备下载nginx的时候，但是NAT gateway还没建立好，就会报错。
  depends_on = [ module.vpc ] 

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.21.0"    //这里必须用"2.21.0"版本的否者用不了，subnet_ids 
  # insert the 10 required variables here
  name                   = "${var.environment}-vm" //分别自动建立两台名为stag-vm-1，stag-vm-2 的private ec2 instance
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  vpc_security_group_ids = [module.private_sg.security_group_id]

  # 2个ec2 instance分别建立在这两个subnet之中
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]  
# 建立2个ec2 instance
  instance_count         = var.private_instance_count 
  
  user_data = file("${path.module}/nginx-install.sh")
  tags = local.common_tags
}