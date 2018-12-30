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

## License
This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.
