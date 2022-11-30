# Launch Template Resource
resource "aws_launch_template" "my_launch_template" {
  name_prefix = "my-launch-template"    // 
  image_id = data.aws_ami.amzlinux2.id //image id在12号文件中 
  instance_type = var.instance_type   //指定ec2 instance type

  vpc_security_group_ids = [ module.private_sg.security_group_id ] //private security group
  key_name = var.instance_keypair   //keypair，远程登录密匙的名称
  user_data = filebase64("${path.module}/app1-nginx-install.sh")//下载，修改nginx的命令
#   #default_version = 1
  update_default_version = true 
#   ebs_optimized = true  这个参数打开后么会报不支持这个参数的错误
#   // 配置硬盘的容量
#   // 这个硬盘的容量的设定好像有点问题，如果这样设定，ec2 instance 会报status check failed，不知道是不是因为是试用账号的缘故，所以配置不了
#   // 是不是device_name 要改为  /dev/xvda 才行？
#   block_device_mappings {
#     device_name = "/dev/sda1"
#     ebs {
#       #volume_size = 10
#       volume_size = 10  //20GB
#       delete_on_termination = true
#       volume_type = "gp2" # default  is gp2 
#     }
#    }
  monitoring {
    enabled = true
  }   
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "myasg"
    }
  }  

}
