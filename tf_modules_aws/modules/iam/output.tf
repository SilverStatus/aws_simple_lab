output "eks_cluster_iam_role" {
  value = aws_iam_role_policy_attachment.eks_cluster.role
}

output "eks_cluster_iam_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}