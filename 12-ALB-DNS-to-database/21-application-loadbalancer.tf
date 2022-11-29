
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
    # HTTP 80端口 跳转到 HTTPS 443端口
    # 流程是这样的，请求使用 ( Load Balancer DNS：80) ---> loadbalancer监听到80端口  --> 跳转到https 443 端口
    http_tcp_listeners = [
        {
        port               = 80
        protocol           = "HTTP"
        action_type = "redirect"
        redirect = {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
        }
    ]  
    
    # 疑问 这个 fixed_response 在这里有何用？是否可以删除？
    # HTTPS Listener
    # 通过( Load Balancer DNS：443) 访问时，会得到一个fixed-response，当然也可以显示app1，或者app2的nginx主页
    https_listeners = [
        # HTTPS Listener Index = 0 for HTTPS 443
        {
            port               = 443
            protocol           = "HTTPS"
            certificate_arn    = module.acm.acm_certificate_arn
            action_type = "fixed-response"
            fixed_response = {
                content_type = "text/plain"
                message_body = "Fixed Static message - for Root Context"
                status_code  = "200"
            }
        }, 
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
                    target_id = module.ec2_private_app1.id[0]
                    port      = 80
                },
                my_app1_vm2 = {
                    target_id = module.ec2_private_app1.id[1]
                    port      = 80
                }
            }
            tags =local.common_tags # Target Group Tags
        },
        # App2 Target Group - TG Index = 1
        {
            name_prefix          = "app2-"
            backend_protocol     = "HTTP"
            backend_port         = 80
            target_type          = "instance"
            deregistration_delay = 10
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/app2/index.html"
                port                = "traffic-port"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"
            }
            protocol_version = "HTTP1"
            # App2 Target Group - Targets,这两个ec2 instance 包含在target group里面
            targets = {
                my_app2_vm1 = {
                    target_id = module.ec2_private_app2.id[0]
                    port      = 80
                },
                my_app2_vm2 = {
                    target_id = module.ec2_private_app2.id[1]
                    port      = 80
                }
            }
            tags =local.common_tags # Target Group Tags
        },
        # App3 Target Group - TG Index = 2
        {
            name_prefix          = "app3-"
            backend_protocol     = "HTTP"
            backend_port         = 8080
            target_type          = "instance"
            deregistration_delay = 10 
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/login"     //load balancer会向 dns-to-db.zhang1123.link/login发送一个请求，如果请求成功说明，这个服务器是health的状态，dns-to-db.zhang1123.link是在25-route53-DNSregistration.tf文件里定义的
                port                = "traffic-port"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"
            }
            #stickiness 的作用是，一天内，一个用户总是去向同一个ec2服务器，
            #这可能会让负载均衡失效慎用。
            stickiness = {
                enabled = true
                cookie_duration = 86400   //一天
                type = "lb_cookie"
            }
            protocol_version = "HTTP1"
            # App3 Target Group - Targets
            targets = {
                my_app3_vm1 = {
                    target_id = module.ec2_private_app3.id[0]
                    port      = 8080
                },
                my_app3_vm2 = {
                    target_id = module.ec2_private_app3.id[1]
                    port      = 8080
                }
            }
            tags =local.common_tags # Target Group Tags
        }        
    ]

    # HTTPS Listener Rules
    https_listener_rules = [
        # Rule-1: /app1* should go to App1 EC2 Instances
        { 
            https_listener_index = 0
            priority = 1  
            actions = [
                {
                    type               = "forward"    //forward to target_group_index=0
                    target_group_index = 0
                }
            ]
            conditions = [{
                path_patterns = ["/app1*"]
            }]
        },
        # Rule-2: /app2* should go to App2 EC2 Instances    
        {
            https_listener_index = 0
            priority = 2
            actions = [
                {
                    type               = "forward"  //forward to target_group_index=1
                    target_group_index = 1
                }
            ]
            conditions = [{
                path_patterns = ["/app2*"]
            }]
        },
        # Rule-3: /* should go to App3 - User-mgmt-WebApp EC2 Instances，这个rule应该要在最后    
        {
            https_listener_index = 0
            priority = 3      
            actions = [
                {
                type               = "forward"
                target_group_index = 2
                }
            ]
            conditions = [{
                path_patterns = ["/*"]
            }]
        },         
    ]
    tags = local.common_tags # ALB Tags
}

