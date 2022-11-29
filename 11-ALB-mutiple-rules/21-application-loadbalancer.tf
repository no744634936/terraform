
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
        }    
    ]

    # HTTPS Listener Rules
    https_listener_rules = [
        # Rule-1: custom-header=my-app-1 should go to App1 EC2 Instances
        { 
            https_listener_index = 0
            priority = 1      // 优先级的意思是：如果有个url满足Rule-1 也满足 Rule-2，那么使用Rule-1就可以了，不用使用 Rule-2，因为Rule-1优先级最高，
            actions = [
                {
                    type               = "forward"
                    target_group_index = 0
                }
            ]
            conditions = [{ 
                http_headers = [{
                    http_header_name = "custom-header"
                    values           = ["app-1", "app1", "my-app-1"]
                }]
            }]
        },
        # Rule-2: custom-header=my-app-2 should go to App2 EC2 Instances    
        {
            https_listener_index = 0
            priority = 2      
            actions = [
                {
                    type               = "forward"
                    target_group_index = 1
                }
            ]
            conditions = [{
                http_headers = [{
                    http_header_name = "custom-header"
                    values           = ["app-2", "app2", "my-app-2"]
                }]        
            }]
        },   
        # Rule-3: When Query-String, website=aws-eks redirect to https://stacksimplify.com/aws-eks/
        { 
            https_listener_index = 0
            priority = 3
            actions = [{
                type        = "redirect"
                status_code = "HTTP_302"
                host        = "stacksimplify.com"
                path        = "/aws-eks/"
                query       = ""
                protocol    = "HTTPS"
            }]
            conditions = [{
                query_strings = [{
                    key   = "website"
                    value = "aws-eks"
                }]
            }]
        },
         # Rule-4: When Host Header = azure-aks.zhang1123.link, redirect to https://stacksimplify.com/azure-aks/azure-kubernetes-service-introduction/
        { 
            https_listener_index = 0
            priority = 4
            actions = [{
                type        = "redirect"
                status_code = "HTTP_302"
                host        = "stacksimplify.com"
                path        = "/azure-aks/azure-kubernetes-service-introduction/"
                query       = ""
                protocol    = "HTTPS"
            }]
            conditions = [{
                host_headers = ["azure-aks.zhang1123.link"]
            }]
        },   
    ]
    tags = local.common_tags # ALB Tags
}

