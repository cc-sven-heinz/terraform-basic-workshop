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
  alias = "eu-central"
}

provider "aws" {
  region = "eu-west-1"
  alias = "eu-west"
}

resource "aws_instance" "instance-in-eu-central" {
  provider = aws.eu-central
  tags = {
    Name = "My Tag"
  }
  ami           = "ami-0e2031728ef69a466"
  instance_type = "t2.micro"
}

resource "aws_instance" "instance-in-eu-west" {
  provider = aws.west
  tags = {
    Name = "My Tag"
  }
  ami           = "ami-0e2031728ef69a466"
  instance_type = "t2.micro"
}
