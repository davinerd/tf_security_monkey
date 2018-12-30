#
# RDS Security Group
#
resource "aws_security_group" "security_monkey_rds_security_group" {
  name = "${data.template_file.name.rendered}-RDSSecurityGroup"
  description = "Security Monkey RDS"
  vpc_id   = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    security_groups = ["${aws_security_group.security_monkey_instance_security_group.id}", "${aws_security_group.security_monkey_worker_scheduler_security_group.id}"]
  }

  tags = "${merge(map("Name", "${data.template_file.name.rendered}-rds-sg"), var.extra_tags)}"
}

#
# Instance Security Group
#
resource "aws_security_group" "security_monkey_instance_security_group" {
  name = "${data.template_file.name.rendered}-InstanceSecurityGroup"
  description = "Security Monkey Instances"
  vpc_id   = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    security_groups = ["${aws_security_group.security_monkey_alb_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${data.template_file.name.rendered}-ec2-sg"), var.extra_tags)}"
}

#
# Worker and Scheduler Security Group
#
resource "aws_security_group" "security_monkey_worker_scheduler_security_group" {
  name = "${data.template_file.name.rendered}-WorkSchedSecurityGroup"
  description = "Security Monkey Worker&Scheduler"
  vpc_id   = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${data.template_file.name.rendered}-work-sched-sg"), var.extra_tags)}"
}


#
# ALB Security Group
#
resource "aws_security_group" "security_monkey_alb_security_group" {
  name = "${data.template_file.name.rendered}-ALBSecurityGroup"
  description = "Security Monkey ALB"
  vpc_id   = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${data.template_file.name.rendered}-alb-sg"), var.extra_tags)}"
}

#
# ElastiCache Security Group
#
resource "aws_security_group" "security_monkey_elasticache_security_group" {
  name = "${data.template_file.name.rendered}-ElastiCacheSecurityGroup"
  description = "Security Monkey ElastiCache"
  vpc_id   = "${var.vpc_id}"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = ["${aws_security_group.security_monkey_instance_security_group.id}", "${aws_security_group.security_monkey_worker_scheduler_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${data.template_file.name.rendered}-elasticache-sg"), var.extra_tags)}"
}
