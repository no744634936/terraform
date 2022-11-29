# Resource: EC2 Instance是resource名，固定的不能改 "myec2vm" 是自己命的名
resource "aws_instance" "myec2vm" {
  ami = "ami-078296f82eb463377"
  instance_type = "t2.micro"
  user_data = file("${path.module}/nginx-install.sh")
  tags = {
    "Name" = "EC2 Demo"
  }
}