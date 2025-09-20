output "eks_cluster_name" {
  value = module.eks_cluster.cluster_name
}
output "eks_cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}
output "eks_cluster_version" {
  value = module.eks_cluster.cluster_version
}
output "eks_cluster_ca_certificate" {
  value = module.eks_cluster.cluster_ca_certificate
}
output "eks_node_group_role_arn" {
  value = module.eks_cluster.node_group_role_arn
}

