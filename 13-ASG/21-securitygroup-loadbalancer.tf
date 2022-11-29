module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  name = "loadbalancer-sg"
  description = "Security Group with HTTP open for entire Internet (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  # inbound，aws提供的安全组管理页面中可以选择的端口可以用这种方法打开，比如这个http 80 端口就是安全组管理页面可以选择的端口
  # 打开http的80端口和https的443端口
  ingress_rules = ["http-80-tcp","https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # inbound自定义端口的时候用这种方法来自定义，81端口是自定义的，所以用下面这种方法
  ingress_with_cidr_blocks = [
    {
      from_port   = 81
      to_port     = 81
      protocol    = 6   //6 代表 tcp
      description = "Allow Port 81 from internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  # outbound， Egress Rule - all-all 
  egress_rules = ["all-all"]
  tags = local.common_tags
}
