# Define CloudWatch Alarms for Autoscaling Groups

# "SimpleScaling" - Scaling Policy for High CPU
resource "aws_autoscaling_policy" "high_cpu" {
  name                   = "high-cpu"
  policy_type            = "SimpleScaling"   
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity" //ASG 初始有两台服务器，scaling_adjustment为4，扩容后就是6台服务器
  cooldown               = 300   // Amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start.
  autoscaling_group_name = aws_autoscaling_group.my_asg.name 
}

# Cloud Watch Alarm to trigger the above scaling policy when CPU Utilization is above 80%
# Also send the notificaiton email to users present in SNS Topic Subscription
resource "aws_cloudwatch_metric_alarm" "app1_asg_cwa_cpu" {
  alarm_name          = "App1-ASG-CWA-CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"   //将数据与指定阈值进行比较的周期数。不太懂
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name 
  }

  alarm_description = "This metric monitors ec2 cpu utilization and triggers the ASG Scaling policy to scale-out if CPU is above 80%"
  //ok_actions 的含义  The list of actions to execute when this alarm transitions into an OK state from any other state. 
  ok_actions          = [aws_sns_topic.myasg_sns_topic.arn] 
  // alarm_actions的含义是，执行high_cpu 这个自动扩容，发送sns邮件
  alarm_actions     = [
    aws_autoscaling_policy.high_cpu.arn, 
    aws_sns_topic.myasg_sns_topic.arn
    ]
}