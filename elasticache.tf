resource "aws_elasticache_subnet_group" "security_monkey_redis_subnet_group" {
  name          = "${data.template_file.name.rendered}-redis-subnet-group"
  subnet_ids    = ["${var.private_subnets}"]
}

resource "aws_elasticache_replication_group" "security_monkey_elasticache_replica_group" {
  replication_group_id          = "secmonkey-group-${var.environment}"
  replication_group_description = "Security Monkey Redis cluster"
  node_type                     = "cache.m3.medium"
  engine                        = "redis"
  port                          = 6379
  parameter_group_name          = "default.redis4.0"
  automatic_failover_enabled    = true
  transit_encryption_enabled    = false
  number_cache_clusters         = 2
  security_group_ids            = ["${aws_security_group.security_monkey_elasticache_security_group.id}"]
  subnet_group_name             = "${aws_elasticache_subnet_group.security_monkey_redis_subnet_group.name}"

  lifecycle {
    ignore_changes = ["number_cache_clusters"]
  }
}

resource "aws_elasticache_cluster" "security_monkey_elasticache_replica" {
  cluster_id           = "secmonkey-repl-${var.environment}"
  replication_group_id = "${aws_elasticache_replication_group.security_monkey_elasticache_replica_group.id}"
}

resource "aws_elasticache_cluster" "security_monkey_redis" {
  cluster_id           = "secmonkey-redis-${var.environment}"
  replication_group_id = "${aws_elasticache_replication_group.security_monkey_elasticache_replica_group.id}"
}
