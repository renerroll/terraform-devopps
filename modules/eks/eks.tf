# IAM Role for the EKS Cluster Allowing It to Interact with Other AWS Services
resource "aws_iam_role" "eks" {
  name = "${var.cluster_name}-eks-cluster"      # IAM role name for the EKS cluster

  assume_role_policy = jsonencode({             # Trust policy allowing the EKS service to assume this IAM role
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AmazonEKSClusterPolicy to the EKS Cluster IAM Role
resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"   # ARN of AWS-managed policy providing basic permissions for managing an EKS cluster
  role = aws_iam_role.eks.name                                    # The IAM role to which the policy is attached
}

# Create the EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name        # Cluster name
  role_arn = aws_iam_role.eks.arn    # ARN of the IAM role required for managing the cluster
  #version  = "1.32"

  vpc_config {                       # VPC networking configuration
    endpoint_private_access = true   # Enables access to the API server via the private VPC network
    endpoint_public_access  = true   # Enables public access to the API server via the internet
    subnet_ids = var.subnet_ids      # List of public and private subnets in the VPC where EKS will run
  }

  access_config {                                        # EKS cluster access configuration
    authentication_mode                         = "API"  # Enables authentication via the API
    bootstrap_cluster_creator_admin_permissions = true   # Grants admin rights to the cluster creator (automatic admin access)
  }

  depends_on = [aws_iam_role_policy_attachment.eks]    # Ensures the IAM role and its policy are created before the cluster
}

data "aws_caller_identity" "current" {}         # Get Information About the Current AWS Account

# Create an EKS Access Entry for a User/Role
resource "aws_eks_access_entry" "eks_root_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:${var.eks_ui_username}"    # ARN of the user or role to grant access
  type          = "STANDARD"                                                                              # Access type: STANDARD / FEDERATED
}

# Associate an EKS Access Policy With the User/Role
resource "aws_eks_access_policy_association" "admin_policy" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:${var.eks_ui_username}"    # ARN of the user or role to which the policy will be attached
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"                    # Administrator policy for the EKS cluster
  access_scope {
    type = "cluster"                # The policy applies to the entire cluster
  }
}