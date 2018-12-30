resource "aws_route53_record" "security_monkey-public" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.dns_name}"
  type    = "A"

  alias {
    name = "${lower(aws_alb.security_monkey_alb.dns_name)}"
    zone_id = "${aws_alb.security_monkey_alb.zone_id}"
    evaluate_target_health = true
  }
}
