module "s3_alb_log" {
  source = "git::https://github.com/Cimpress-MCP/terraform.git//s3_elb_access_logs"

  # name of bucket to create.  Must be unique within AWS
  bucket_name = "${data.template_file.name.rendered}-alb-logs"

  # extra tags
  extra_tags = "${var.extra_tags}"
}

# RDS module for the backend MySQL db.
module "rds" {
  source              = "git::https://github.com/terraform-aws-modules/terraform-aws-rds"
  identifier          = "${data.template_file.name.rendered}-rds"
  allocated_storage   = "${var.db_size}"

  engine              = "${var.db_engine}"
  engine_version      = "${var.rds_engine_version}"
  instance_class      = "${var.rds_instance_class}"
  family              = "${var.rds_family}"

  name                = "${data.template_file.db_name.rendered}"
  username            = "${var.db_user}"
  password            = "${var.db_pwd}"
  port                = "${var.db_port}"
  skip_final_snapshot = "${var.skip_final_snapshot}"

  multi_az = true
  copy_tags_to_snapshot = true
  storage_encrypted = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"


  vpc_security_group_ids    = ["${aws_security_group.security_monkey_rds_security_group.id}"]
  subnet_ids                = "${var.private_subnets}"
  timeouts   = {
    "create" = "15m"
  }

  tags               = "${var.extra_tags}"
}
