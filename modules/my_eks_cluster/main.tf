# virtual private cloud is isolation for resources
resource "aws_vpc" "eks_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  # EKS requires DNS Hostnames and DNS Resolution to be true otherwise nodes cannot register with your cluster.
  enable_dns_support   = true
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
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[0]
  availability_zone = var.az[0]
  #every instance deployed will get a public ip
  map_public_ip_on_launch = true
  tags = {
    Name = format("%s-%s-%s", "public", var.tag, "1")
    #below tags allows eks cluster to share the subnet & lets you deploy public elb
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }

}

resource "aws_subnet" "eks_public_sb_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[1]
  availability_zone = var.az[1]
  #every instance deployed will get a public ip
  map_public_ip_on_launch = true
  tags = {
    Name = format("%s-%s-%s", "public", var.tag, "2")
    #below tags allows eks cluster to share the subnet & lets you deploy public elb
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }

}

# creates  2 private and 2 public subnets 
resource "aws_subnet" "eks_private_sb_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[2]
  availability_zone = var.az[0]
  #every instance deployed will get a public ip
  # map_public_ip_on_launch = true 
  tags = {
    Name = format("%s-%s-%s", "private", var.tag, "1")
    #below tags allows eks cluster to share the subnet & lets you deploy private elb
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}

resource "aws_subnet" "eks_private_sb_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidr_blocks[3]
  availability_zone = var.az[1]
  #every instance deployed will get a public ip
  # map_public_ip_on_launch = true 
  tags = {
    Name = format("%s-%s-%s", "private", var.tag, "1")
    #below tags allows eks cluster to share the subnet & lets you deploy private elb
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}

# NAT gateways provides the a way to instances in private subnet to connect to internet.
resource "aws_nat_gateway" "eks_nat_1" {
  allocation_id = aws_eip.eks_nat_ip_1.id
  subnet_id     = aws_subnet.eks_public_sb_1.id
  tags = {
    Name = var.tag
  }
}


# NAT gateways provides the a way to instances in private subnet to connect to internet.
resource "aws_nat_gateway" "eks_nat_2" {
  allocation_id = aws_eip.eks_nat_ip_2.id
  subnet_id     = aws_subnet.eks_public_sb_2.id
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
    cidr_block     = "0.0.0.0/0" #All IPs
    nat_gateway_id = aws_nat_gateway.eks_nat_1.id
  }
  tags = {
    Name = format("%s-%s-%s", "private", var.tag, "1")
  }
}

resource "aws_route_table" "eks_private_2" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0" #All IPs
    nat_gateway_id = aws_nat_gateway.eks_nat_2.id
  }
  tags = {
    Name = format("%s-%s-%s", "private", var.tag, "2")
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



# IAM Role for EKS  cluster to create instances on our behalf
resource "aws_iam_role" "eks_cluster" {
  name               = var.tag
  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect" : "Allow",
            "Principal" : {
                "Service" : "eks.amazonaws.com"
            },
            "Action" : "sts:AssumeRole"
            }
        
    ]
}
EOF
}

# attaching policies to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# creating service-linked role
resource "aws_iam_service_linked_role" "AWSServiceRoleForAmazonEKSNodegroup" {
aws_service_name = "eks-nodegroup.amazonaws.com"
}

# Kubernetes Cluster - my_eks_cluster
resource "aws_eks_cluster" "eks" {
  name     = var.tag
  role_arn = aws_iam_role.eks_cluster.arn
  service_account_role_arn = aws_iam_service_linked_role.AWSServiceRoleForAmazonEKSNodegroup
  version  = "1.27"
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids = [
      aws_subnet.eks_private_sb_1.id,
      aws_subnet.eks_private_sb_2.id,
      aws_subnet.eks_public_sb_1.id,
      aws_subnet.eks_public_sb_2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}


# IAM Role for EC2  instances
resource "aws_iam_role" "eks_node" {
  name               = format("%s-%s", var.tag, "node")
  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect" : "Allow",
            "Principal" : {
                "Service" : "ec2.amazonaws.com"
            },
            "Action" : "sts:AssumeRole"
        }
    ]
}
EOF
}

# attaching policies to the node iam role
resource "aws_iam_role_policy_attachment" "eks_cluster_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

# attaching policies to the node iam role
resource "aws_iam_role_policy_attachment" "eks_cluster_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

# Lets you download private images
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

# uses public subnets to deploy lb
# instance group
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.id
  node_group_name = format("%s-%s-%s", var.tag, "nodes", "group")
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids = [
    aws_subnet.eks_private_sb_1.id,
    aws_subnet.eks_private_sb_2.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  capacity_type = "ON_DEMAND"

  instance_types = ["t3.micro"]

  labels = {
    role = format("%s-%s-%s", var.tag, "nodes", "group")
  }
  disk_size = 20

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_node_policy,
    aws_iam_role_policy_attachment.eks_cluster_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_policy,
  ]
}