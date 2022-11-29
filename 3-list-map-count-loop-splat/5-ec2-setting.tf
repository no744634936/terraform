resource "aws_instance" "myec2vm" {
  ami = data.aws_ami.amzlinux2.id
  # instance_type = var.instance_type
  # instance_type = var.instance_type_list[0]  //reference List value
  instance_type = var.instance_type_map["dev"] //reference map value
  user_data = file("${path.module}/nginx-install.sh")
  key_name = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  count = 2     # 一次性创建两个ec2实例
  tags = {
    "Name" = "EC2 Demo-${count.index}"   #count.index指的是count的0，1两个ec2实例
  }
}