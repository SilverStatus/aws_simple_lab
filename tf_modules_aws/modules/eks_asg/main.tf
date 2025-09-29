resource "aws_eks_node_group" "eks_workers_spot" {
  cluster_name    = var.aws_eks_cluster_name
  node_group_name = "eks-${var.aws_eks_cluster_name}-worker-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  capacity_type   = "SPOT"

  scaling_config {
    desired_size = var.desired_nodes_spot
    max_size     = var.max_nodes_spot
    min_size     = var.min_nodes_spot
  }

  ami_type       = var.os_instance_type
  instance_types = [var.node_instance_type_spot]
  disk_size      = 20

  labels = {
    "eks/worker-node-type" = "spot"
    "eks/worker-family" = "backend"
  }

  tags = {
    Name = "eks-worker-node_spot"
    ManagedBy = "Terraform"
  }
  # depends_on = [
  #   aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
  #   aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
  #   aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  # ]
}

resource "aws_eks_node_group" "eks_workers_on_demand" {
  cluster_name    = var.aws_eks_cluster_name
  node_group_name = "eks-${var.aws_eks_cluster_name}-worker-group-on-demand"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_nodes_on_demand
    max_size     = var.max_nodes_on_demand
    min_size     = var.min_nodes_on_demand
  }

  ami_type       = var.os_instance_type
  instance_types = [var.node_instance_type_on_demand]
  disk_size      = 20

  labels = {
    "eks/worker-node-type" = "on-demand"
    "eks/worker-family" = "backend"
  }

  tags = {
    Name = "eks-worker-node_on_demand"
    ManagedBy = "Terraform"
  }
  # depends_on = [
  #   aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
  #   aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
  #   aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  # ]
}
