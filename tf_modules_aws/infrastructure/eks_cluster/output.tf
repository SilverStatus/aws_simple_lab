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

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
}

output "region" {
  description = "AWS region"
  value       = var.region
}




