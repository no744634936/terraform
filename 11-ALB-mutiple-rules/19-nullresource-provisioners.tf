# 1,terraform-setting.tf 文件里写入null resource provider

# 2,Create a Null Resource and Provisioners
resource "null_resource" "name" {
  # public ec2 instance 建立后才能进行连接
  depends_on = [module.ec2_public]
  # Connection Block for Provisioners to ssh connect to public EC2 Instance
  connection {
    type     = "ssh"
    host     = aws_eip.bastion_eip.public_ip //这个ip是elastic ip   
    user     = "ec2-user"
    password = ""
    private_key = file("zhanghaifeng.pem")
  }  

  # File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem of public ec2 instance
  provisioner "file" {
    source      = "zhanghaifeng.pem"
    destination = "/tmp/zhanghaifeng.pem"
  }

  # Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/zhanghaifeng.pem"
    ]
  }

  ## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  # local-exec-output-files 要自己提前建立，用来保存记录
  provisioner "local-exec" {
    command = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "local-exec-output-files/"
  }
} 

