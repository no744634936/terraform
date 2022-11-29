# Get DNS information from AWS Route53
# 写下购买的domain
data "aws_route53_zone" "mydomain" {
  name = "zhang1123.link"
}

#打印 MyDomain name
output "mydomain_name" {
  description = " The Hosted Zone name of the desired Hosted Zone."
  value = data.aws_route53_zone.mydomain.name
}

#打印 MyDomain Zone ID
output "mydomain_zoneid" {
  description = "The Hosted Zone id of the desired Hosted Zone"
  value = data.aws_route53_zone.mydomain.zone_id
}