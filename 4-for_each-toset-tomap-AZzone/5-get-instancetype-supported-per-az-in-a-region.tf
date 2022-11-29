// 获取某个region下的所有 数据中心的名字，记住就好
data "aws_availability_zones" "my_azones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


# 如果 ap-northeast-1 下的数据库中心支持 t2.micro，就返回包含数据中心名的数组
# 如果 ap-northeast-1 下的某个数据库中心不支持 t2.micro，就返回空数组
data "aws_ec2_instance_type_offerings" "my_ins_type" {
    for_each=toset(data.aws_availability_zones.my_azones.names)
    filter {
        name   = "instance-type"
        values = ["t2.micro"]
    }
    filter {
        name   = "location"
        values = [each.value]
    }
    location_type = "availability-zone"
}


# 打印出所有数据中心名-->是否支持t2.micro
# 支持就会显示如 ap-northeast-1a => ["t2.micro"]
# 不支持就会显示如 ap-northeast-1b => []
output "output_v3_1" {
 value = { for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  az => details.instance_types }   
}

# 打印出去除不支持t2.micro的数据中心
output "output_v3_2" {
  value = { for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  az => details.instance_types if length(details.instance_types) != 0 }
}

#获取map的所有key，也就是获取所有支持t2.micro的数据中心名
output "output_v3_3" {
  value = keys({ for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  az => details.instance_types if length(details.instance_types) != 0 }) 
}