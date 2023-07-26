#virtual private cloud is isolation for resources
resource "aws_vpc" "eks_vpc" {
    cidr_block = var.vpc_cidr_block
    instance_tenancy = "default"
    # EKS requires DNS Hostnames and DNS Resolution to be true otherwise nodes cannot register with your cluster.
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = var.tag
    }        

}

# internet gateway to connect vpc to the internet
resource "aws_internet_gateway" "eks_ig" {
    vpc_id = aws_vpc.eks_vpc.id    
    tags = {
        Name = var.tag
    }        
}


# creates  2 private and 2 public subnets 
re