# virtual private cloud is isolation for resources
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
    cidr_block = var.subnet_cidr_blocks[0]
    availability_zone = var.az[0]
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
    cidr_block = var.subnet_cidr_blocks[1]
    availability_zone = var.az[1]
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
    cidr_block = var.subnet_cidr_blocks[2]
    availability_zone = var.az[0]
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
    cidr_block = var.subnet_cidr_blocks[3]
    availability_zone = var.az[1]
    #every instance deployed will get a public ip
    # map_public_ip_on_launch = true 
     tags = {
        Name = format("%s-%s-%s","private", var.tag, "1")
        #below tags allows eks cluster to share the subnet & lets you deploy private elb
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }        

}

# NAT gateways provides the a way to instances in private subnet to connect to internet.
resource "aws_nat_gateway" "eks_nat_1" {
    allocation_id = aws_eip.eks_nat_ip_1.id
    subnet_id = aws_subnet.eks_public_sb_1.id
      tags = {
        Name = var.tag
    }  
}


# NAT gateways provides the a way to instances in private subnet to connect to internet.
resource "aws_nat_gateway" "eks_nat_2" {
    allocation_id = aws_eip.eks_nat_ip_2.id
    subnet_id = aws_subnet.eks_public_sb_2.id
      tags = {
        Name = var.tag
    }  
}


# IP address for NAT gateway
resource "aws_eip" "eks_nat_ip_1" {
    depends_on = [aws_internet_gateway.eks_ig]
    tags = {
        Name = var.tag
    }  
}

# IP address for NAT gateway
resource "aws_eip" "eks_nat_ip_2" {
    depends_on = [aws_internet_gateway.eks_ig]
    tags = {
        Name = var.tag
    }  
}

# Routes to determine traffic from your subnet or gateway
resource "aws_route_table" "eks_public" {
    vpc_id = aws_vpc.eks_vpc.id  
    route {
        cidr_block = "0.0.0.0/0" #All IPs
        gateway_id = aws_internet_gateway.eks_ig.id
    }
    tags = {
        Name = var.tag
    }  
} 

# Since we have nat gateway in two az, we have created two route tables for HA config
resource "aws_route_table" "eks_private_1" {
    vpc_id = aws_vpc.eks_vpc.id  
    route {
        cidr_block = "0.0.0.0/0" #All IPs
        nat_gateway_id = aws_nat_gateway.eks_nat_1.id
    }
    tags = {
        Name = format("%s-%s-%s","private", var.tag, "1")
    }  
} 

resource "aws_route_table" "eks_private_2" {
    vpc_id = aws_vpc.eks_vpc.id  
    route {
        cidr_block = "0.0.0.0/0" #All IPs
        nat_gateway_id = aws_nat_gateway.eks_nat_2.id
    }
    tags = {
         Name = format("%s-%s-%s","private", var.tag, "2")
    }  
} 

# Route Table associations with Subnets
 resource "aws_route_table_association" "eks_public_1" {
    subnet_id = aws_subnet.eks_public_sb_1.id
    route_table_id = aws_route_table.eks_public.id
 }

  resource "aws_route_table_association" "eks_public_2" {
    subnet_id = aws_subnet.eks_public_sb_2.id
    route_table_id = aws_route_table.eks_public.id
 }

 resource "aws_route_table_association" "eks_private_1" {
    subnet_id = aws_subnet.eks_private_sb_1.id
    route_table_id = aws_route_table.eks_private_1.id
 }

 resource "aws_route_table_association" "eks_private_2" {
    subnet_id = aws_subnet.eks_private_sb_2.id
    route_table_id = aws_route_table.eks_private_2.id
 }