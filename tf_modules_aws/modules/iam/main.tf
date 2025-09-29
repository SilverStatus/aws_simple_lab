resource "aws_iam_role" "eks_cluster" {
  name = "eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" # Optional but recommended
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "eks_node_group" {
  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# Create access entries and policy associations for admin user
resource "aws_eks_access_entry" "admin" {
  cluster_name      = var.cluster_name
  principal_arn     = "arn:aws:iam::084828586638:root"
  kubernetes_groups = ["eks-console-dashboard-full-access-group"]
  type              = "STANDARD"

  depends_on = [module.eks_cluster]   # <--- This is critical

}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::084828586638:root"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.admin]
}

resource "aws_eks_access_entry" "adam" {
  cluster_name      = var.cluster_name
  principal_arn     = "arn:aws:iam::084828586638:user/adam"
  kubernetes_groups = ["eks-console-dashboard-full-access-group"]
  type              = "STANDARD"

  depends_on = [module.eks_cluster]   # <--- This is critical

}

resource "aws_eks_access_policy_association" "adam" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::084828586638:user/adam"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.admin]
}
