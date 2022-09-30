terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.59.0"
      configuration_aliases = [ aws.central, aws.west]
    }
  }
}


data "aws_vpc" "main" {
  id = "vpc-038ec89b97114311c"
  provider = aws.central
}

data "template_file" "user_data" {
 template = file("${path.module}/userdata.yaml")
}


resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyServer Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["62.216.209.116/32"] // Die IP Adresse des Internet Anschluss
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups = []
      self = false
    }

  ]

  egress = [
    {
      description      = "outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  provider = aws.central
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUlp1VijyFe028k3VB55Sg40zaU5NSR/6olHPf8l4bpZ2Exekl5oBML6dIfcuAMorMejlnlOYXNN/8axIA0ToaoQmsnOxWrQmPbvvmKCwryp0y8poApx1TaAteMwLfG7D4i7p7WsMIz+c1pcaxkzqxhardwrCWe7QZ7AgljtC1vNh8f/OPaUTC0povqnzCFtd4Nwo5meFmEYu7rg334TiOqQqyY8pT1zlW8k2zW12t6Riv1vQeyisdBZ0oNU80ckjkI8m+8cFosLx24D1ubT9mC6Gxq7ltwL2QjHmtAhic/ALCAVtK18WzRjt1nLFBYhFqs+PkGvQ/nUe2ItYCU1Mx8xg27H7r15KHhba2SCdsTSIzTSvK0X3P1tW/ThTQYTG3ZUKRjuwDknxf8DKOU19GlYwV39H3i24T0PSrpbiffU40nDFVc5hzthS3M2GtEBm7NhhFZKZncVr/OKunhMcIu5KaGhKEzaCBdqWCoz0bMiRUYofLJsa63wJBPf2HiqU= sheinz@localhost"
  provider = aws.central
}

resource "aws_instance" "my_server" {
  ami                    = local.ami
  instance_type          = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = data.template_file.user_data.rendered
  tags                   = {
    Name = "MyServer"
  }
  provider = aws.central
}

resource "aws_instance" "west_instance" {
  ami                    = local.ami-west
  instance_type          = "t2.micro"
  tags                   = {
    Name = "West Instance"
  }
  provider = aws.west
}

resource "aws_instance" "central_instance" {
  ami                    = local.ami
  instance_type          = "t2.micro"
  tags                   = {
    Name = "Central Instance"
  }
  provider = aws.central
}

locals {
  ami-west = data.aws_ami.ubuntu-west.id
  ami = data.aws_ami.ubuntu.id
}

data "aws_ami" "ubuntu-west" {
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
  provider = aws.west
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
  provider = aws.central
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
