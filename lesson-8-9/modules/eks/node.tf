resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-eks-nodes"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.subnet_ids

  instance_types = [var.instance_type]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "ci-cd"
  }

  tags = {
    Name        = "${var.cluster_name}-eks-node-group"
    Environment = "ci-cd"
  }

  depends_on = [aws_iam_role_policy_attachment.worker_node_policies]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
