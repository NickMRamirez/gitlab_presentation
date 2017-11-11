data "aws_ami" "ubuntu_docker" {
  most_recent = true

  filter = {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  owners = ["${var.ami_owner}"]
}