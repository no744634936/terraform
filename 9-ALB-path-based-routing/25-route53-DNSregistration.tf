# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id 
  name    = "apps.zhang1123.link"   //浏览器输入apps.zhang1123.link 就会走 Load Balancer DNS name：80
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name   // Load Balancer DNS name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }  
}