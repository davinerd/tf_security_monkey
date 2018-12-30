#
# Scheduler Autoscaling Group
#
resource "aws_autoscaling_group" "security_monkey_scheduler_autoscaling_group" {
  name                      = "${data.template_file.name.rendered}-scheduler-ASG"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.security_monkey_scheduler_launch_configuration.name}"
  vpc_zone_identifier       = ["${var.private_subnets}"]
  enabled_metrics           = ["GroupInServiceInstances", "GroupTotalInstances"]

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${data.template_file.name.rendered}-scheduler", "propagate_at_launch", true)
    ),
    var.cluster_extra_tags)
  }"]
}


#
# Scheduler Auto Scaling Policy
#
resource "aws_autoscaling_policy" "security_monkey_scheduler_autoscaling_policy" {
  autoscaling_group_name = "${aws_autoscaling_group.security_monkey_scheduler_autoscaling_group.name}"
  name                   = "${data.template_file.name.rendered}-scheduler-DefaultASGPolicy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  scaling_adjustment     = 1
}


#
# Scheduler Launch Configuration
#
resource "aws_launch_configuration" "security_monkey_scheduler_launch_configuration" {
  name_prefix          = "${data.template_file.name.rendered}-scheduler-"
  image_id             = "${var.ami_id}"
  instance_type        = "m4.xlarge"
  iam_instance_profile = "${aws_iam_instance_profile.security_monkey_instance_profile.id}"
  security_groups      = ["${aws_security_group.security_monkey_worker_scheduler_security_group.id}"]
  key_name             = "${var.keypair_name}"
  user_data            = "${data.template_file.userdata_scheduler.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}
