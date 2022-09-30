terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.59.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-west-1"
  alias = "west"
}

provider "aws" {
  # Configuration options
  region = "eu-central-1"
  alias = "central"
}


module "webserver" {
  source = "./modules/webserver"

  providers = {
    aws.central = aws.central
    aws.west = aws.west
  }
}

output "pulic_ip" {
  value = module.webserver.public_ip
}
