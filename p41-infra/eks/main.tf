#sets aws as provider for this module
#use terraform profile, which could be created with `aws configure --profile terraform` command
provider "aws" {
  profile = var.profile
  region  = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.21"
    }
  }
}

module "my_eks_module" {
  source = "../../modules/my_eks_cluster"
}
