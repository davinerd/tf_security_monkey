data "aws_region" "current" {}

data "template_file" "name" {
  template = "$${name}"

  vars {
    name = "${var.monkey_name}-${var.environment}"
  }
}

data "template_file" "db_name" {
  template = "$${dbname}"

  vars {
    dbname = "${replace(data.template_file.name.rendered, "-", "")}"
  }
}

data "template_file" "confs_path" {
  template = "$${path}"

  vars {
    path = "${path.module}/confs"
  }
}

data "template_file" "userdata_worker" {
  template = "${file("${data.template_file.confs_path.rendered}/userdata_worker.tpl")}"

  vars {
    db_user = "${var.db_user}"
    db_passwd = "${var.db_pwd}"
    db_name = "${data.template_file.db_name.rendered}"
    db_hostname = "${module.rds.this_db_instance_address}"
    redis_hostname = "${aws_elasticache_replication_group.security_monkey_elasticache_replica_group.primary_endpoint_address}"
    ses_region = "${var.ses_region}"
    ses_mail_from = "${var.ses_email_address}"
  }
}

data "template_file" "userdata_scheduler" {
  template = "${file("${data.template_file.confs_path.rendered}/userdata_scheduler.tpl")}"

  vars {
    db_user = "${var.db_user}"
    db_passwd = "${var.db_pwd}"
    db_name = "${data.template_file.db_name.rendered}"
    db_hostname = "${module.rds.this_db_instance_address}"
    redis_hostname = "${aws_elasticache_replication_group.security_monkey_elasticache_replica_group.primary_endpoint_address}"
    ses_region = "${var.ses_region}"
    ses_mail_from = "${var.ses_email_address}"
  }
}

data "template_file" "userdata_webui" {
  template = "${file("${data.template_file.confs_path.rendered}/userdata_webui.tpl")}"

  vars {
    db_user = "${var.db_user}"
    db_passwd = "${var.db_pwd}"
    db_name = "${data.template_file.db_name.rendered}"
    db_hostname = "${module.rds.this_db_instance_address}"
    fqdn = "${var.dns_name}"
    sso_enabled = "${var.sso_enabled}"
    client_id = "${var.google_client_id}"
    auth_endpoint = "${var.google_auth_endpoint}"
    g_secret = "${var.google_secret}"
  }
}
