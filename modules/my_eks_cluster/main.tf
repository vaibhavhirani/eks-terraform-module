
# Kubernetes Cluster 
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
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

# node instance group
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.id
  node_group_name = format("%s-%s-%s", var.cluster_name, "nodes", "group")
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

  instance_types = [var.node_instance_type]

  labels = {
    role = format("%s-%s-%s", var.cluster_name, "nodes", "group")
  }
  disk_size = var.node_instance_size

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