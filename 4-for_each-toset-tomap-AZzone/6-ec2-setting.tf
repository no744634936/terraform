resource "aws_instance" "myec2vm" {
  ami = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type_map["dev"] //reference map value
  user_data = file("${path.module}/nginx-install.sh")
  key_name = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  
  # 在一个region下的每一个支持t2.mirco的数据中心，都各自创建一个实例
  for_each = toset( keys({ for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  az => details.instance_types if length(details.instance_types) != 0 }) )
  
  availability_zone = each.key # You can also use each.value because for list items each.key == each.value
  
  tags = {
    "Name" = "For-Each-Demo-${each.key}"
  }
}