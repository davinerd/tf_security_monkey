#
# CloudWatch Alarms
#

resource "aws_cloudwatch_metric_alarm" "web_healthy_instances" {
  alarm_name          = "${data.template_file.name.rendered}-web-ALBHTTPSTargetGroupLowHealthyHosts"
  alarm_description   = "No healthy hosts for security_monkey ALB HTTP target group."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"

  dimensions {
     LoadBalancer = "${aws_alb.security_monkey_alb.arn_suffix}"
     TargetGroup = "${aws_alb_target_group.security_monkey_alb_target_group.arn_suffix}"
  }

  alarm_actions = ["${split(",", var.alarm_actions)}"]
  ok_actions = ["${split(",", var.ok_actions)}"]
}

resource "aws_cloudwatch_metric_alarm" "worker_healthy_instances" {
  alarm_name          = "${data.template_file.name.rendered}-worker-ASGLowHealthyHosts"
  alarm_description   = "No healthy hosts for security_monkey worker auto-scaling group."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"

  dimensions {
     AutoScalingGroupName = "${aws_autoscaling_group.security_monkey_worker_autoscaling_group.name}"
  }

  alarm_actions = ["${split(",", var.alarm_actions)}"]
  ok_actions = ["${split(",", var.ok_actions)}"]
}

resource "aws_cloudwatch_metric_alarm" "scheduler_healthy_instances" {
  alarm_name          = "${data.template_file.name.rendered}-scheduler-ASGLowHealthyHosts"
  alarm_description   = "No healthy hosts for security_monkey worker auto-scaling group."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"

  dimensions {
     AutoScalingGroupName = "${aws_autoscaling_group.security_monkey_scheduler_autoscaling_group.name}"
  }

  alarm_actions = ["${split(",", var.alarm_actions)}"]
  ok_actions = ["${split(",", var.ok_actions)}"]
}
