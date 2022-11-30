## Create Scheduled Actions
### Create Scheduled Action-1: Increase capacity during business hours
resource "aws_autoscaling_schedule" "increase_capacity_9am" {
  scheduled_action_name  = "increase-capacity-9am"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 5
  start_time             = "2030-12-11T09:00:00Z"    //注意这个开始时间是utc 时间，要将你自己时区的时间转换成utc时间，再写入
  recurrence             = "00 09 * * *"     //每天早上9点讲服务器数量增加到5台
  autoscaling_group_name = aws_autoscaling_group.my_asg.id  
}

### Create Scheduled Action-2: Decrease capacity during non-business hours
resource "aws_autoscaling_schedule" "decrease_capacity_9pm" {
  scheduled_action_name  = "decrease-capacity-9pm"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  start_time             = "2030-12-11T21:00:00Z"
  recurrence             = "00 21 * * *"      //每晚9点将服务器数减少到2
  autoscaling_group_name = aws_autoscaling_group.my_asg.id  
}