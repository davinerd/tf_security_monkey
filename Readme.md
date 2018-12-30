# Prerequisite
To successfully build the Security Monkey infrastructure you need to manually
create the following AWS resources:

* A Route53 zone ID
* An EC2 SSH key pair to use to login into the Security Monkey's instances (even though SSH is disabled. Session Manager is used instead)
* An AMI with Security Monkey already installed (this can be achieved by the
  packer template in the `packer` directory)
* SNS topic to associate to CloudWatch events
* [Optional] an email to use as SES delivery method for notification

# Building the AMI
If you want to specify another port to run the API instead of the default 5000,
you can setup the env variable `SECMONKEY_API_PORT`.

After that, you can type `bash build-ami.sh` inside the `packer` directory.

# HOW TO: Using the module
## Input
* `monkey_name` - Infrastructure's name
* `vpc_id` - ID of the VPC where to spin Security Monkey
* `public_subnets` - List of IDs of public subnets
* `private_subnets` - List of IDs of private subnets
* `environment` - Type of environment (prod, dev, stg, etc)
* `route53_zone_id` - Route53 ID to bind a DNS name
* `dns_name` - DNS name to use
* `keypair_name` - Keypair to access the instances
* `ami_id` - ID of the AMI where Security Monkey is installed
* `db_pwd` - Password for accessing the database
* `alarm_actions` - ARN SNS topic to alert in case of unhealthy hosts in the ALB
* `ok_actions` - ARN SNS topic to notify when the state goes back to OK from an alert

Optionals:
* `ses_email_address` - Email address to use as SES notification (default is `void@email.no` and not used)
* `ses_region` - SES region (used only in case `ses_email_address` is not set left default)
* `sso_enabled` - Boolean to set Security Monkey's Google SSO feature (default to `false`)
* `google_client_id` - Google client ID
* `google_auth_endpoint` - Google authentication endpoint (default to `https://accounts.google.com/o/oauth2/v2/auth`)
* `google_secret` - Google secret
* `db_size` - Size of the RDS (default `200`)
* `db_engine` - Database RDS engine (default to `postgres`)
* `rds_engine_version` - Database RDS engine version (default to `10.4`)
* `rds_family` - Database RDS family (default to `postgres10`)
* `rds_instance_class` - Database RDS instance class (default to `db.m4.large`)
* `db_user` - Database RDS user (default to `secmonkeyuser`)
* `db_port` - Database RDS port (default to `5432`)
* `skip_final_snapshot` - Database RDS skip final snapshot (default to `true`)
* `extra_tags` - Map of extra tags (default to empty)
* `cluster_extra_tags` - List of extra tags (default to empty)

## Output
* `redis` - Redis endpoint
* `alb` - ALB DNS name

## Code example

Here is an example on how to use this module:

```
module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "test_db-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a","us-west-2b","us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "public_subnet"
  }

  private_subnet_tags = {
    Name = "private_subnet"
  }
}

module "secmonkey" {
  source = "git::https://github.com/davinerd/tf_security_monkey.git"
  monkey_name = "test_sec_monkey"
  environment = "dev"

  route53_zone_id = "${var.route53_zone_id}"
  dns_name = "${var.dns_name}"

  keypair_name = "secmonkey_keypair"

  alarm_actions = "${var.alarm_actions}"
  ok_actions = "${var.ok_actions}"

  db_pwd = "ABC123"

  ami_id = "ami-XYZ"

  private_subnets = "${module.vpc.private_subnets}"
  public_subnets = "${module.vpc.public_subnets}"
  vpc_id = "${module.vpc.vpc_id}"
}
```

# License
This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.
