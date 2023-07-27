variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "cluster_name" {
  default = "my-eks-cluster"
}

variable "az" {
  type    = list(any)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "subnet_cidr_blocks" {
  type    = list(any)
  default = ["192.168.0.0/18", "192.168.64.0/18", "192.168.128.0/18", "192.168.192.0/18"]
}

variable "node_instance_type" {
  default = "t3.micro"
}

variable "node_instance_size" {
  default = 20
}

