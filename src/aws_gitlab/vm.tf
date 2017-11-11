variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "ssh_keypair_name" {}
variable "ami_name" {}
variable "ami_owner" {}

provider "aws" {
  access_key =  "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "gitlab_vpc" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "gitlab_vpc"
  }
}

resource "aws_subnet" "gitlab_subnet" {
  vpc_id = "${aws_vpc.gitlab_vpc.id}"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "gitlab_subnet"
  }
}

resource "aws_internet_gateway" "gitlab_internet_gateway" {
  vpc_id = "${aws_vpc.gitlab_vpc.id}"
  tags {
    Name = "gitlab_internet_gateway"
  }
}

resource "aws_route_table" "gitlab_route_table" {
  vpc_id = "${aws_vpc.gitlab_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gitlab_internet_gateway.id}"
  }

  tags {
    Name = "gitlab_route_table"
  }
}

resource "aws_route_table_association" "gitlab_internet_gateway" {
  subnet_id = "${aws_subnet.gitlab_subnet.id}"
  route_table_id = "${aws_route_table.gitlab_route_table.id}"
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH"
  vpc_id = "${aws_vpc.gitlab_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "gitlab_server" {
  ami                    = "${data.aws_ami.ubuntu_docker.id}"
  instance_type          = "t2.medium"
  subnet_id              = "${aws_subnet.gitlab_subnet.id}"
  key_name               = "${var.ssh_keypair_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_http_ssh.id}"]

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("../example_ssh_keypairs/ssh_private_key.pem")}"
  }

  provisioner "file" {
    source = "./gitlab"
    destination = "/home/ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/gitlab; export VM_PUBLIC_IP=\"${self.public_ip}\"; sudo -E docker-compose up -d; echo \"Gitlab URL: http://$VM_PUBLIC_IP\""
    ]
  }
}

