
module "alb" {
    source  = "terraform-aws-modules/alb/aws"
    version = "8.1.0"

    name = "${local.name}-alb"
    load_balancer_type = "application"
    vpc_id = module.vpc.vpc_id
    # 两个public subnets 里面都要有loadbalancer
    subnets = [
        module.vpc.public_subnets[0],
        module.vpc.public_subnets[1]
    ]
    security_groups = [module.loadbalancer_sg.security_group_id]

    # listener这个80 是 loadbalancer要监听的80端口，
    # 流程是这样的，请求使用 ( Load Balancer DNS：80) ---> loadbalancer监听到80端口  --> App1 target group的80端口----> ec2 instance 的80端口
    http_tcp_listeners = [
        {
            port               = 80
            protocol           = "HTTP"
            target_group_index = 0 # App1  target group associated to this listener
        }
    ]  

    # Target Groups,这里只建立了一个target group，放入两个ec2 instance
    target_groups = [
        # App1 Target Group - target group Index = 0
        {
            name_prefix          = "app1-"
            backend_protocol     = "HTTP"
            backend_port         = 80
            target_type          = "instance"
            deregistration_delay = 10
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/app1/index.html"  //health_check块里面只需要改这个就好，每隔30s检查一次/app1/index.html网页是否正常。
                port                = "traffic-port"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"
            }
            protocol_version = "HTTP1"    //默认地写HTTP1
            # App1 Target Group - Targets，这两个ec2 instance 包含在target group里面
            targets = {
                my_app1_vm1 = {
                    target_id = module.ec2_private.id[0]
                    port      = 80
                },
                my_app1_vm2 = {
                    target_id = module.ec2_private.id[1]
                    port      = 80
                }
            }
            tags =local.common_tags # Target Group Tags
        }  
    ]
    tags = local.common_tags # ALB Tags
}

