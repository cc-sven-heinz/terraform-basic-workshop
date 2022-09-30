terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}



#<BLOCK TYPE> "BLOCK LABEL" "BLOCK LABEL"
resource "aws_instance" "my-instance" {
  provider = aws
  tags     = {
    Name = "test"
  }
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

#output "my-instance-ip" {
#  value = aws_instance.my-instance.public_ip
#}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
