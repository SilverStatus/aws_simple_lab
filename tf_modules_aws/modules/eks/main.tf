resource "aws_eks_cluster" "eks_cluster" {
    name = var.cluster_name
    role_arn = var.role_arn
    version = var.eks_version
    vpc_config {
        subnet_ids = var.subnet_ids 
        endpoint_private_access = true
        endpoint_public_access = true
        public_access_cidrs = ["0.0.0.0/0"]  
    }

    depends_on = [
        var.eks_cluster_iam_role  # Use the variable instead of module reference
    ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.14.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.27.3-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "coredns"
  addon_version     = "v1.10.3-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}
