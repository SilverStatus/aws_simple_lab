output "eks_node_group_spot" {
  value = aws_eks_node_group.eks_workers_spot.node_group_name
}

output "eks_node_group_spot_min" {
  value = aws_eks_node_group.eks_workers_spot.node_group_min_size
}

output "eks_node_group_spot_max" {
  value = aws_eks_node_group.eks_workers_spot.node_group_max_size
}

output "eks_node_group_spot_desired" {
  value = aws_eks_node_group.eks_workers_spot.node_group_desired_size
}

output "eks_node_group_spot_instance_type" {
  value = aws_eks_node_group.eks_workers_spot.node_group_instance_types[0]
}
