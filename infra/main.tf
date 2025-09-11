terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }

  backend "s3" {
    bucket       = "tf-state-backend-35471530"
    key          = "tf-state-alsidneio"
    use_lockfile = true
    region       = "us-east-2"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = "exercise"
    }
  }
}
