terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Uses the AWS CLI's configured credentials (default profile or AWS_PROFILE).
# No access keys are written to any file in this repo.
provider "aws" {
  region = var.aws_region
}
