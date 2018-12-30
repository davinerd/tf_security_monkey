#
# IAM resources for Security Monkey
#

resource "aws_iam_role" "security_monkey_role" {
  name = "${data.template_file.name.rendered}-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "security_monkey_launch_perms" {
  statement {
    effect = "Allow"
    actions = [
        "ses:SendEmail"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["arn:aws:iam::*:role/SecurityMonkey"]
  }
}

resource "aws_iam_policy" "security_monkey_launch_perms" {
  name   = "${data.template_file.name.rendered}-LaunchPerms"
  path   = "/"
  policy = "${data.aws_iam_policy_document.security_monkey_launch_perms.json}"
}

resource "aws_iam_policy_attachment" "security_monkey_launch_perms_attachments" {
  name        = "${data.template_file.name.rendered}-Attachment"
  roles       = ["${aws_iam_role.security_monkey_role.name}"]
  policy_arn  = "${aws_iam_policy.security_monkey_launch_perms.arn}"
}

# needed for Session Manager
resource "aws_iam_role_policy_attachment" "security_monkey_ssm_attach" {
  role       = "${aws_iam_role.security_monkey_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "security_monkey_instance_profile" {
  name = "${data.template_file.name.rendered}-InstanceProfile"
  role = "${aws_iam_role.security_monkey_role.name}"
}
