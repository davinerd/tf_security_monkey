#
# Load Balancer
#
resource "aws_alb" "security_monkey_alb" {
  name                       = "${data.template_file.name.rendered}-alb"
  internal                   = false
  security_groups            = ["${aws_security_group.security_monkey_alb_security_group.id}"]
  subnets                    = ["${var.public_subnets}"]
  enable_deletion_protection = false

  access_logs {
    bucket  = "${module.s3_alb_log.bucket_name}"
    enabled = true
 }
 tags = "${merge(map("Name", "${data.template_file.name.rendered}-alb"), var.extra_tags)}"

}

resource "aws_alb_target_group" "security_monkey_alb_target_group" {
  name        = "${data.template_file.name.rendered}"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(map("Name", "${data.template_file.name.rendered}-target-group"), var.extra_tags)}"
}

resource "aws_alb_listener" "security_monkey_alb_listener" {
  load_balancer_arn = "${aws_alb.security_monkey_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${aws_acm_certificate_validation.cert.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.security_monkey_alb_target_group.arn}"
    type = "forward"
  }
}
