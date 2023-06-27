// creates and validates ACM certificate,也就是给domain添加ssl证书

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.1.0"

  //为了防止域名可能不是「test.com」而是 「test.com.」　这种internal domain，可以用trimsuffix去除最后面的点，记住就好了
  domain_name = trimsuffix(data.aws_route53_zone.mydomain.name, ".") 
  zone_id     = data.aws_route53_zone.mydomain.id

  //　这句话的意思是 zhang1123.link，app1.zhang1123.link 跟 app2.zhang1123.link 等都拥有同一个ssl证书
  subject_alternative_names = [
    "*.zhang1123.link"
  ]
  tags = local.common_tags 
}

# 打印一下，Output ACM Certificate ARN，这个应该https的证书编号
output "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  value = module.acm.acm_certificate_arn
}