module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.2.1"

  name = "complete-nlb-${random_pet.this.id}"
  load_balancer_type = "network"
  vpc_id = module.vpc.vpc_id

  # 也可以写成  subnets = module.vpc.public_subnets,
  subnets = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]

#   #TCP_UDP, UDP, TCP
#   http_tcp_listeners = [
#     {
#       port               = 81
#       protocol           = "TCP_UDP"
#       target_group_index = 0
#     },
#     {
#       port               = 82
#       protocol           = "UDP"
#       target_group_index = 1
#     },
#     {
#       port               = 83
#       protocol           = "TCP"
#       target_group_index = 2
#     },
#   ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
  ]
  #  TLS设定   跟SSL差不多，都是加密
  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0    //下面target_groups 的 index
    },
  ]

  target_groups = [
    {
      name_prefix          = "app1-"
      backend_protocol     = "TCP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
  ]

  tags = local.common_tags # NLB Tags
}