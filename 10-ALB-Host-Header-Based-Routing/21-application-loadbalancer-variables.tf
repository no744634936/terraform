

# We will be using these variables in two places
#    21-application-loadbalancer.tf
# 　　23-route53-dnsregistration.tf
# If we are using the values in more than one place its good to variablize that value

# App1 DNS Name
variable "app1_dns_name" {
  description = "App1 DNS Name"
}

# App2 DNS Name
variable "app2_dns_name" {
  description = "App2 DNS Name"
}