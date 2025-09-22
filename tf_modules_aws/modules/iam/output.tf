output "eks_cluster_iam_role" {
  value = aws_iam_role_policy_attachment.eks_cluster.role
}

output "eks_cluster_iam_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_arn" {
  value = aws_iam_role.eks_node_group.arn
}