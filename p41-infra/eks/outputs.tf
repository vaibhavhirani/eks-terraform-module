
output "vpc_id" {
  value = module.my_eks_module.vpc_id
}

output "cluster_name" {
  value = module.my_eks_module.cluster_name
}