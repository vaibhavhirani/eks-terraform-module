# VPC is an network isolation for all the resouces residing in.
resource "aws_vpc" "eks_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  # EKS requires DNS Hostnames and DNS Resolution to be true otherwise nodes cannot register with your cluster.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = format("%s-%s", var.cluster_name, "vpc")
    BelongsTo = var.cluster_name
  }

}

# Internet Gateway enables VPC to connect to Internet
resource "aws_internet_gateway" "eks_ig" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name      = format("%s-%s", var.cluster_name, "ig")
    BelongsTo = var.cluster_name
  }
}


# Public Subnets will be used for LBs 
resource "aws_subnet" "eks_public_sb_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[0]
  availability_zone = var.az[0]
  # every instance deployed will get a public ip
  map_public_ip_on_launch = true
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "public-subnet", "1")
    BelongsTo = var.cluster_name
    # below tags allows eks cluster to share the subnet & lets you deploy public elb
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1

  }

}

resource "aws_subnet" "eks_public_sb_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[1]
  availability_zone = var.az[1]
  # every instance deployed will get a public ip
  map_public_ip_on_launch = true
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "public-subnet", "2")
    BelongsTo = var.cluster_name
    # below tags allows eks cluster to share the subnet & lets you deploy public elb
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }

}

# Private Subnets will be used for nodes 
resource "aws_subnet" "eks_private_sb_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[2]
  availability_zone = var.az[0]
  tags = {
    Name      = format("%s-%s-%s", "private", var.cluster_name, "1")
    BelongsTo = var.cluster_name
    # below tags allows eks cluster to share the subnet & lets you deploy private elb
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}

resource "aws_subnet" "eks_private_sb_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[3]
  availability_zone = var.az[1]
  tags = {
    Name      = format("%s-%s-%s", "private", var.cluster_name, "2")
    BelongsTo = var.cluster_name
    # below tags allows eks cluster to share the subnet & lets you deploy private elb
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}

# NAT gateways provides a way to instances in private subnet to connect to internet.
resource "aws_nat_gateway" "eks_nat_1" {
  allocation_id = aws_eip.eks_nat_ip_1.id
  subnet_id     = aws_subnet.eks_public_sb_1.id
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "nat", "1")
    BelongsTo = var.cluster_name
  }
}
resource "aws_nat_gateway" "eks_nat_2" {
  allocation_id = aws_eip.eks_nat_ip_2.id
  subnet_id     = aws_subnet.eks_public_sb_2.id
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "nat", "2")
    BelongsTo = var.cluster_name
  }
}


# IP address for NAT gateways
resource "aws_eip" "eks_nat_ip_1" {
  depends_on = [aws_internet_gateway.eks_ig]
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "nat-ip", "1")
    BelongsTo = var.cluster_name
  }
}
resource "aws_eip" "eks_nat_ip_2" {
  depends_on = [aws_internet_gateway.eks_ig]
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "nat-ip", "2")
    BelongsTo = var.cluster_name
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
    Name      = format("%s-%s", var.cluster_name, "public-rt")
    BelongsTo = var.cluster_name
  }
}

# Since we have nat gateway in two az, we have created two route tables for HA config
resource "aws_route_table" "eks_private_1" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0" #All IPs
    nat_gateway_id = aws_nat_gateway.eks_nat_1.id
  }
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "private-rt", "1")
    BelongsTo = var.cluster_name
  }
}

resource "aws_route_table" "eks_private_2" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0" #All IPs
    nat_gateway_id = aws_nat_gateway.eks_nat_2.id
  }
  tags = {
    Name      = format("%s-%s-%s", var.cluster_name, "private-rt", "2")
    BelongsTo = var.cluster_name
  }
}

# Route Table associations with Subnets
resource "aws_route_table_association" "eks_public_1" {
  subnet_id      = aws_subnet.eks_public_sb_1.id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route_table_association" "eks_public_2" {
  subnet_id      = aws_subnet.eks_public_sb_2.id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route_table_association" "eks_private_1" {
  subnet_id      = aws_subnet.eks_private_sb_1.id
  route_table_id = aws_route_table.eks_private_1.id
}

resource "aws_route_table_association" "eks_private_2" {
  subnet_id      = aws_subnet.eks_private_sb_2.id
  route_table_id = aws_route_table.eks_private_2.id
}

