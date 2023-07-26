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
resource "aws_subnet" "eks_public_sb_1" {
    vpc_id = aws_vpc.eks_vpc.id  
    cidr_block = "192.168.0.0/18"
    availability_zone = "ap-south-1a"
    #every instance deployed will get a public ip
    map_public_ip_on_launch = true 
     tags = {
        Name = format("%s-%s-%s","public", var.tag, "1")
        #below tags allows eks cluster to share the subnet & lets you deploy public elb
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb" = 1
    }        

}

resource "aws_subnet" "eks_public_sb_2" {
    vpc_id = aws_vpc.eks_vpc.id  
    cidr_block = "192.168.64.0/18"
    availability_zone = "ap-south-1b"
    #every instance deployed will get a public ip
    map_public_ip_on_launch = true 
     tags = {
        Name = format("%s-%s-%s","public", var.tag, "2")
        #below tags allows eks cluster to share the subnet & lets you deploy public elb
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb" = 1
    }        

}

# creates  2 private and 2 public subnets 
resource "aws_subnet" "eks_private_sb_1" {
    vpc_id = aws_vpc.eks_vpc.id  
    cidr_block = "192.168.128.0/18"
    availability_zone = "ap-south-1a"
    #every instance deployed will get a public ip
    # map_public_ip_on_launch = true 
     tags = {
        Name = format("%s-%s-%s","private", var.tag, "1")
        #below tags allows eks cluster to share the subnet & lets you deploy private elb
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }        

}

resource "aws_subnet" "eks_private_sb_2" {
    vpc_id = aws_vpc.eks_vpc.id  
    cidr_block = "192.168.192.0/18"
    availability_zone = "ap-south-1b"
    #every instance deployed will get a public ip
    # map_public_ip_on_launch = true 
     tags = {
        Name = format("%s-%s-%s","private", var.tag, "1")
        #below tags allows eks cluster to share the subnet & lets you deploy private elb
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }        

}