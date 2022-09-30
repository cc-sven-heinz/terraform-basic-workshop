terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

variable "bucket-name" {
  type = "string"
  default = "my-depends-on-example-123212"
}

variable "region" {
  type = "string"
  default = "eu-central-1"
}

locals {
  ami = data.aws_ami.ubuntu.id
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket-name # bitte einen anderen Namen wählen, sonst gibt es einen Fehler
}

resource "aws_instance" "my_instance" {
  ami           = local.ami
  instance_type = "t2.micro"
  tags = {
    Name = "local-example"
  }
  depends_on = [
    aws_s3_bucket.bucket
  ]
}

resource "aws_instance" "my_next_instance" {
  ami           = local.ami
  instance_type = "t2.micro"
  tags = {
    Name = "local-example"
  }
  depends_on = [
    aws_s3_bucket.bucket
  ]
}

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

