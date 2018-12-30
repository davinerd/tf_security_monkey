variable "monkey_name" {
  description = "Infrastructure name"
}

variable "environment" {
  description = "Type of environment (e.g. prod, dev, stg, etc)"
}

variable "route53_zone_id" {
  description = "Route53 Public Zone ID"
}

variable "dns_name" {
  description = "The DNS name associated to the infrastructure"
}

variable "keypair_name" {
  description = "Keypair name for EC2 instances"
}

variable "ami_id" {
  description = "Security Monkey AMI ID"
}

variable "ses_region" {
  default = "us-west-2"
}

variable "ses_email_address" {
  description = "SES destination email address"
  default = "void@email.no"
}

variable "alarm_actions" {
  description = "Cloudwatch's metric alerts action. Usually a SNS topic"
}

variable "ok_actions" {
  description = "Cloudwatch's metric ok actions. Usually a SNS topic"
}

variable "vpc_id" {
  description = "VPC ID where to spin Security Monkey"
}

variable "public_subnets" {
  type = "list"
  description = "List of IDs of public subnets"
}

variable "private_subnets" {
  type = "list"
  description = "List of IDs of private subnets"
}

########### SSO ##############
#
#
variable "sso_enabled" {
  description = "Enable Security Monkey's SSO feature"
  default = false
}

variable "google_client_id" {
  description = "Google Cliend ID"
  default = "XXXXXXXXX"
}

variable "google_auth_endpoint" {
  description = "Google authentication endpoint (default: https://accounts.google.com/o/oauth2/v2/auth)"
  default = "https://accounts.google.com/o/oauth2/v2/auth"
}

variable "google_secret" {
  description = "Google secret"
  default = "YYYYYYYYYYYY"
}

########### RDS ############
#
#
variable "db_size" {
  default = "200"
}

variable "db_engine" {
  default = "postgres"
}

variable "rds_engine_version" {
  default = "10.4"
}

variable "rds_family" {
  default = "postgres10"
}

variable "rds_instance_class" {
  default = "db.m4.large"
}

variable "db_user" {
  default = "secmonkeyuser"
}

variable "db_pwd" {
  description = "Database password"
}

variable "db_port" {
  default = "5432"
}

variable "skip_final_snapshot" {
  default = "true"
}

######### TAGS ###########
#
#
variable "extra_tags" {
  type = "map"
  description = "A map of additional tags to add to ELBs and SGs. Each element in the map must have the key = value format"

  # example:
  # extra_tags = {
  #   "Environment" = "Dev",
  #   "Squad" = "Ops"
  # }

  default = {}
}

variable "cluster_extra_tags" {
  description = "A list of additional tags to add to each Instance in the ASG. Each element in the list must be a map with the keys key, value, and propagate_at_launch"
  type        = "list"

  #example:
  # default = [
  #   {
  #     key = "Environment"
  #     value = "Dev"
  #     propagate_at_launch = true
  #   }
  # ]
  default = []
}
