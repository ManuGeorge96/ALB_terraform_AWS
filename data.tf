data "aws_ami" "AMI" {
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.*-hvm-2.*-x86_64-gp2"]
  }
  filter {
  name = "root-device-type"
  values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
}
