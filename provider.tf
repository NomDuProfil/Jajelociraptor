terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.19.0"
      configuration_aliases = [aws.acm_provider_frontend]
    }
    random = {}
  }
}

provider "aws" {
  region = "us-east-1"
}
