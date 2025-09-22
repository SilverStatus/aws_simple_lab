output "eks_node_group_spot" {
  value = aws_eks_node_group.eks_workers_spot.node_group_name
}

