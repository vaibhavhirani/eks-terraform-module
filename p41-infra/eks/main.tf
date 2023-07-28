#sets aws as provider for this module
#use terraform profile, which could be created with `aws configure --profile terraform` command
provider "aws" {
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
  vpc_cidr_block = "192.168.0.0/16"
  cluster_name = "my_eks_cluster"
  az = ["ap-south-1a", "ap-south-1b"] #provide any two availability zones in the selected region
  subnet_cidr_blocks = ["192.168.0.0/18", "192.168.64.0/18", "192.168.128.0/18", "192.168.192.0/18"] # first 2 public and last 2 private
  node_instance_type = "t3.micro"
  node_instance_size = 20
}
