# Creating Launch template for Web tier AutoScaling Group
# Creating Launch template for Web tier AutoScaling Group

resource "aws_launch_template" "Web-LC" {
  name = var.launch-template-name
  image_id = "ami-0663b059c6536cac8"
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_security_group.web-sg.id]

  user_data = base64encode(replace(replace(file("../modules/aws-autoscaling/deploy.sh"), "$${web_dns}", "${var.web-alb-dns}"), "$${was_dns}", "${var.was-alb-dns}"))


  
  iam_instance_profile {
    
    name = data.aws_iam_instance_profile.instance-profile.name
  }
}


resource "aws_autoscaling_group" "Web-ASG" {
  name = var.asg-name
  vpc_zone_identifier  = [data.aws_subnet.private-subnet1.id, data.aws_subnet.private-subnet2.id]
  launch_template {
    id = aws_launch_template.Web-LC.id
    version = aws_launch_template.Web-LC.latest_version
  }

  min_size             = 2
  max_size             = 4
  desired_capacity = 2
  health_check_type    = "ELB"
  health_check_grace_period = 300
  target_group_arns    = [data.aws_lb_target_group.tg.arn]
  force_delete         = true
  
  tag {
    key                 = "Name"
    value               = "cli-Web-ASG"
    propagate_at_launch = true
  }

}


resource "aws_autoscaling_policy" "web-custom-cpu-policy" {
  name                   = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.Web-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "web-custom-cpu-alarm" {
  alarm_name          = "custom-cpu-alarm"
  alarm_description   = "alarm when cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Web-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.web-custom-cpu-policy.arn]
}


resource "aws_autoscaling_policy" "web-custom-cpu-policy-scaledown" {
  name                   = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.Web-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "web-custom-cpu-alarm-scaledown" {
  alarm_name          = "custom-cpu-alarm-scaledown"
  alarm_description   = "alarm when cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Web-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.web-custom-cpu-policy-scaledown.arn]
}


















resource "aws_launch_template" "Was-LC" {
  name = var.was-launch-template-name
  image_id = "ami-0663b059c6536cac8"
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_security_group.was-sg.id]

  user_data =  base64encode(replace(replace(file("../modules/aws-autoscaling/deploy2.sh"), "$${rds_dns}", "${var.rds-dns}"), "$${was_dns}", "${var.was-alb-dns}"))

  iam_instance_profile {
    name = data.aws_iam_instance_profile.instance-profile.name
  }
}


resource "aws_autoscaling_group" "Was-ASG" {
  name = var.was-asg-name
  vpc_zone_identifier  = [data.aws_subnet.private-subnet1.id, data.aws_subnet.private-subnet2.id]
  launch_template {
    id = aws_launch_template.Was-LC.id
    version = aws_launch_template.Was-LC.latest_version
  }

  min_size             = 2
  max_size             = 4
  desired_capacity = 2
  # health_check_type    = "ELB"
  # health_check_grace_period = 300
  target_group_arns    = [data.aws_lb_target_group.was-tg.arn]
  force_delete         = true
  
  tag {
    key                 = "Name"
    value               = "cli-Was-ASG"
    propagate_at_launch = true
  }

}


resource "aws_autoscaling_policy" "was-custom-cpu-policy" {
  name                   = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.Was-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "was-custom-cpu-alarm" {
  alarm_name          = "custom-cpu-alarm"
  alarm_description   = "alarm when cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Was-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.was-custom-cpu-policy.arn]
}


resource "aws_autoscaling_policy" "was-custom-cpu-policy-scaledown" {
  name                   = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.Was-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "was-custom-cpu-alarm-scaledown" {
  alarm_name          = "custom-cpu-alarm-scaledown"
  alarm_description   = "alarm when cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Was-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.was-custom-cpu-policy-scaledown.arn]
}
