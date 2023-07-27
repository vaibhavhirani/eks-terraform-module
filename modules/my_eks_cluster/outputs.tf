output "vpc_id" {
  value       = aws_vpc.eks_vpc.id
  description = "VPC ID"
}

output "cluster_name" {
  value = aws_eks_cluster.eks.name
  description = "Cluster Name"
}

output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
  description = "endpoint"
}