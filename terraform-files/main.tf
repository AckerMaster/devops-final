provider "aws" {
  region = var.region
}

# the ssh key i generated to my local machine
resource "aws_key_pair" "liad_ssh_key_id" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_path)
}

# given VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-044604d0bfb707142"
}

# creating a security Group
resource "aws_security_group" "liad_security_group_id" {
  name        = var.security_group_name
  vpc_id      = data.aws_vpc.existing_vpc.id

  # alow ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow port 5001
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # this allows ping
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound for internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# creating EC2 Instance
resource "aws_instance" "builder" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.liad_ssh_key_id.key_name
  vpc_security_group_ids = [aws_security_group.liad_security_group_id.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = "builder"
  }
}

# in here we will remote exec and install docker & docker-compose using the script
resource "null_resource" "install_docker" {
  depends_on = [aws_instance.builder]

  triggers = {
    instance_id = aws_instance.builder.id
  }

  provisioner "file" {
    source      = "${path.module}/install_docker.sh"
    destination = "/tmp/install_docker.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/liad_ssh_key")
      host        = aws_instance.builder.public_ip
      timeout     = "5m"
      agent       = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh",
      "/tmp/install_docker.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/liad_ssh_key")
      host        = aws_instance.builder.public_ip
      timeout     = "5m"
      agent       = false
    }
  }
}