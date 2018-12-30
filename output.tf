output "redis" {
  value = "${aws_elasticache_replication_group.security_monkey_elasticache_replica_group.primary_endpoint_address}"
}

output "alb" {
  value = "${aws_alb.security_monkey_alb.dns_name}"
}
