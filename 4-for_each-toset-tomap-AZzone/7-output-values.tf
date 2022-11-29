# EC2 Instance Public IP with TOSET
output "instance_publicip" {
  description = "EC2 Instance Public IP"
  #value = aws_instance.myec2vm[*].public_ip  # Latest Splat
  value = toset([ for myec2vm in aws_instance.myec2vm : myec2vm.public_ip])  
}

# EC2 Instance Public DNS with TOSET
output "instance_publicdns" {
  description = "EC2 Instance Public DNS"
  #value = aws_instance.myec2vm[*].public_dns  # Latest Splat
  value = toset([for myec2vm in aws_instance.myec2vm : myec2vm.public_dns])    
}

# EC2 Instance Public DNS with MAPS
output "instance_publicdns2" {
  value = tomap({
    #for az, myec2vm in aws_instance.myec2vm : az => myec2vm.public_dns
    # az intends to be ability zone
    for s, myec2vm in aws_instance.myec2vm : s => myec2vm.public_dns
    # s intends to be a subnet ID

  })
}