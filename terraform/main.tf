provider "aws" {
  region = var.region
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  required_version = ">= 1.6"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}
