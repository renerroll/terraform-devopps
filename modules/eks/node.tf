# IAM Role for EC2 Worker Nodes
resource "aws_iam_role" "nodes" {
  name = "${var.cluster_name}-eks-nodes"      # IAM role name for the worker nodes

  assume_role_policy = jsonencode({           # Trust policy allowing EC2 worker nodes to assume this IAM role
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AmazonEKSWorkerNodePolicy to the EKS Worker Node IAM Role (Allows EC2 worker nodes to interact with the EKS API)
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Attach the Amazon VPC CNI Policy to the EKS Worker Node IAM Role (Grants EC2 worker nodes permissions to operate the Amazon VPC CNI plugin)
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Attach the Amazon ECR Read-Only Policy to the EKS Worker Node IAM Role (Allows EC2 worker nodes to pull container images from Amazon ECR)
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Create the EKS Node Group
resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name  # Name of the EKS cluster
  node_group_name = "general"                 # Node group name
  node_role_arn   = aws_iam_role.nodes.arn    # IAM role for the worker nodes
  subnet_ids      = var.subnet_ids            # Subnets where EC2 worker nodes will run
  ami_type        = var.ami_type              # Amazon Machine Image type for EC2 nodes
  capacity_type   = var.capacity_type         # Pricing model for EC2 nodes (ON_DEMAND / SPOT)
  instance_types  = ["${var.instance_type}"]  # EC2 instance type (e.g., t3.medium)

  scaling_config {                   # Auto-scaling configuration
    desired_size = var.desired_size  # Desired number of nodes
    max_size     = var.max_size      # Maximum number of nodes
    min_size     = var.min_size      # Minimum number of nodes
  }

  update_config {                   # Node update configuration
    max_unavailable = 1             # Max number of nodes that can be updated simultaneously
  }

  labels = {                        # Node labels for use in pod nodeSelector
    role = "general"                # Label "role" with the value "general"
  }

  depends_on = [                     # Dependencies that must be created before the Node Group
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  lifecycle {                                             # Controls Terraform’s behavior on changes
    ignore_changes = [scaling_config[0].desired_size]     # Ignores changes to desired_size to avoid conflicts (prevents recreation of the Node Group if desired_size is changed manually)
  }
}

