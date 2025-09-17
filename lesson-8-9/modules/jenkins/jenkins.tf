# ---------- EBS CSI StorageClass ----------
resource "kubernetes_storage_class_v1" "jenkins_ebs_sc" {
  metadata {
    name = "jenkins-ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type = "gp3"
  }
}

# ---------- Namespace ----------
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

# ---------- IAM Role for Kaniko via IRSA ----------
resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:jenkins:jenkins-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_kaniko_ecr_policy" {
  name = "${var.cluster_name}-jenkins-kaniko-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories"
        ],
        Resource = "*"
      }
    ]
  })
}

# ---------- Service Account з підключеною IRSA ----------
resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = "jenkins-sa"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_role.arn
    }
  }
  depends_on = [kubernetes_namespace.jenkins]
}

# ---------- Helm Release Jenkins ----------
locals {
  jenkins_values = templatefile("${path.module}/values.yaml", {
    github_user     = var.github_user
    github_pat      = var.github_pat
    github_repo_url = var.github_repo_url
  })
}

resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = kubernetes_namespace.jenkins.metadata[0].name
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.8.27"
  create_namespace = false

  values = [local.jenkins_values]
  timeout = 600

  depends_on = [
    kubernetes_service_account.jenkins_sa,
    kubernetes_storage_class_v1.jenkins_ebs_sc
  ]
}
